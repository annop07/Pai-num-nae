const express = require('express');
const { protect, requireAdmin } = require('../middlewares/auth');
const chatController = require('../controllers/chat.controller');
const { uploadChat } = require('../middlewares/upload.middleware');
const asyncHandler = require('express-async-handler');
const { uploadToCloudinary } = require('../utils/cloudinary');
const router = express.Router();

// GET /api/chat/rooms - ดู chat rooms ทั้งหมดของตัวเอง
router.get('/rooms', protect, chatController.getMyChatRooms);

// GET /api/chat/rooms/:id - ดู chat + messages
router.get('/rooms/:id', protect, chatController.getChatRoomById);

// POST /api/chat/rooms/:id/messages - ส่งข้อความ
router.post('/rooms/:id/messages', protect, chatController.sendMessage);

// POST /api/chat/rooms/:id/upload - upload ไฟล์/รูป (ใช้ Cloudinary)
router.post(
  '/rooms/:id/upload',
  protect,
  uploadChat.array('files', 5), // อนุญาตสูงสุด 5 ไฟล์ (รูปภาพ + วิดีโอ สูงสุด 50MB/ไฟล์)
  asyncHandler(async (req, res) => {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, message: 'No files uploaded' });
    }

    // Upload แต่ละไฟล์ไปยัง Cloudinary
    const uploadPromises = req.files.map(file => 
      uploadToCloudinary(file.buffer, 'chat-attachments')
    );

    const results = await Promise.all(uploadPromises);
    const urls = results.map(r => r.url);

    res.status(200).json({ success: true, data: { urls } });
  })
);

// PATCH /api/chat/rooms/:id/close - ปิด chat (Admin only)
router.patch('/rooms/:id/close', protect, requireAdmin, chatController.closeChatRoom);

// PATCH /api/chat/rooms/:id/assign - assign Admin
router.patch('/rooms/:id/assign', protect, requireAdmin, chatController.assignAdmin);

module.exports = router;
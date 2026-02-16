const express = require('express');
const { protect, requireAdmin } = require('../middlewares/auth');
const chatController = require('../controllers/chat.controller');
const upload = require('../middlewares/upload.middleware');
const asyncHandler = require('express-async-handler');
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
  upload.array('files', 5), // อนุญาตสูงสุด 5 ไฟล์
  asyncHandler(async (req, res) => {
    const urls = req.files.map(f => f.path); // Cloudinary URLs
    res.status(200).json({ success: true, data: { urls } });
  })
);

// PATCH /api/chat/rooms/:id/close - ปิด chat (Admin only)
router.patch('/rooms/:id/close', protect, requireAdmin, chatController.closeChatRoom);

// PATCH /api/chat/rooms/:id/assign - assign Admin
router.patch('/rooms/:id/assign', protect, requireAdmin, chatController.assignAdmin);

module.exports = router;
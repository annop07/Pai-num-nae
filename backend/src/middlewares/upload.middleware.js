const multer = require('multer');
const ApiError = require('../utils/ApiError');

// กำหนดค่า Multer ให้เก็บไฟล์ใน memoryชั่วคราวเพื่อรอส่งต่อไปยัง Cloudinary
const storage = multer.memoryStorage();

const upload = multer({
    storage: storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // เพิ่มเป็น 50 MB เพื่อรองรับรูป/วิดีโอคุณภาพสูง
    fileFilter: (req, file, cb) => {
        // อนุญาตเฉพาะไฟล์รูปภาพ (jpeg, jpg, png)
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new ApiError(400, 'Only image files are allowed!'), false);
        }
    },
});

// สำหรับ Chat: อนุญาตรูปภาพ + วิดีโอ + เอกสาร (หลักฐาน) ขนาดสูงสุด 50MB
const uploadChat = multer({
    storage: storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50 MB สำหรับวิดีโอจากกล้องมือถือ
    fileFilter: (req, file, cb) => {
        const allowed = file.mimetype.startsWith('image/') ||
            file.mimetype.startsWith('video/') ||
            file.mimetype === 'application/pdf' ||
            file.mimetype === 'application/msword' || // .doc
            file.mimetype === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; // .docx
        if (allowed) {
            cb(null, true);
        } else {
            cb(new ApiError(400, 'อนุญาตเฉพาะไฟล์รูปภาพ วิดีโอ และเอกสาร (PDF, DOC, DOCX) เท่านั้น'), false);
        }
    },
});

module.exports = upload;
module.exports.uploadChat = uploadChat;

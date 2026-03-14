const multer = require('multer');
const ApiError = require('../utils/ApiError');

// กำหนดค่า Multer ให้เก็บไฟล์ใน memoryชั่วคราวเพื่อรอส่งต่อไปยัง Cloudinary
const storage = multer.memoryStorage();

const ALLOWED_MIMETYPES = [
    // Images
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/heic',
    // Videos
    'video/mp4',
    'video/quicktime',
    // Audio
    'audio/mpeg',
    // Documents (บาง browser/OS ส่ง PDF เป็น x-pdf)
    'application/pdf',
    'application/x-pdf',
];

const upload = multer({
    storage: storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50 MB เพื่อรองรับรูป/วิดีโอ/เอกสารคุณภาพสูง
    fileFilter: (req, file, cb) => {
        // อนุญาตเฉพาะ image, video/mp4, video/quicktime, PDF
        if (ALLOWED_MIMETYPES.includes(file.mimetype) || file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new ApiError(400, 'Only image, video (MP4/MOV), audio (MP3), and PDF files are allowed!'), false);
        }
    },
});

module.exports = upload;

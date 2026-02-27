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

module.exports = upload;

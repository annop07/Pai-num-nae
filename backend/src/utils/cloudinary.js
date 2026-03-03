const cloudinary = require('cloudinary').v2
const ApiError = require("./ApiError");

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
    secure: true,
});

// รายการ mimetype ที่ถือว่าเป็น PDF (บาง browser/OS ส่งค่าต่างกัน)
const PDF_MIMETYPES = ['application/pdf', 'application/x-pdf'];

const uploadToCloudinary = (fileBuffer, folder, mimetype = '', originalname = '') => {
    // PDF ต้องใช้ resource_type 'raw' เพื่อให้ Cloudinary เก็บและ serve ไฟล์ต้นฉบับได้ถูกต้อง
    // (ถ้าใช้ 'image' หรือ 'auto' Cloudinary อาจ transform/convert ทำให้เปิด PDF ไม่ได้)
    const isPdf = PDF_MIMETYPES.includes(mimetype);
    const resourceType = isPdf ? 'raw' : 'auto';

    const options = { folder, resource_type: resourceType };

    // สำหรับ raw files (PDF) ต้องใส่นามสกุล .pdf ใน public_id
    // เพื่อให้ URL มีนามสกุล .pdf → เบราว์เซอร์เปิด/ดาวน์โหลดได้ถูกต้อง
    if (resourceType === 'raw') {
        const ext = originalname && originalname.includes('.')
            ? originalname.substring(originalname.lastIndexOf('.')).toLowerCase()
            : '';
        const hasPdfExt = ext === '.pdf';
        const uniqueSuffix = `${Date.now()}_${Math.round(Math.random() * 1e6)}`;
        options.public_id = hasPdfExt ? `${uniqueSuffix}${ext}` : `${uniqueSuffix}.pdf`;
    }

    return new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
            options,
            (error, result) => {
                if (error) {
                    console.error("Cloudinary Upload Error:", error);
                    return reject(new ApiError(500, "Cloudinary upload failed."));
                }
                resolve({ url: result.secure_url, public_id: result.public_id });
            }
        );
        uploadStream.end(fileBuffer);
    });
};

const deleteFromCloudinary = (publicId) => {
    return new Promise((resolve, reject) => {
        cloudinary.uploader.destroy(publicId, (error, result) => {
            if (error) {
                console.error("Cloudinary Delete Error:", error);
                return reject(new ApiError(500, "Cloudinary deletion failed."));
            }
            resolve(result);
        });
    });
};

module.exports = {
    uploadToCloudinary,
    deleteFromCloudinary,
};
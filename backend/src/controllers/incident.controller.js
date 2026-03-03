const asyncHandler = require("express-async-handler");
const axios = require("axios");
const incidentService = require("../services/incident.service");
const { uploadToCloudinary } = require("../utils/cloudinary");
const ApiError = require("../utils/ApiError");

const createIncident = asyncHandler(async (req, res) => {
    const reporterId = req.user.sub;

    // อัปโหลดไฟล์หลักฐานไปยัง Cloudinary 
    if (req.files && req.files.length > 0) {
        const uploadResults = await Promise.all(
            req.files.map(file => uploadToCloudinary(file.buffer, 'painamnae/incidents', file.mimetype, file.originalname))
        );
        req.body.evidenceUrls = uploadResults.map(r => r.url);
    }

    // แปลง location จาก JSON string กลับเป็น object 
    if (req.body.location && typeof req.body.location === 'string') {
        try {
            req.body.location = JSON.parse(req.body.location);
        } catch (e) {
            throw new ApiError(400, 'รูปแบบข้อมูลตำแหน่งไม่ถูกต้อง');
        }
    }

    const incident = await incidentService.createIncident(req.body, reporterId);
    res.status(201).json({ success: true, data: incident });
});

const getMyIncidents = asyncHandler(async (req, res) => {
    const userId = req.user.sub;
    const incidents = await incidentService.getMyIncidents(userId);
    res.status(200).json({ success: true, data: incidents });
});

const getIncidentById = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const incident = await incidentService.getIncidentById(id);
    if (!incident) throw new ApiError(404, 'ไม่พบรายงานเหตุการณ์');

    const userId = req.user.sub;
    if (incident.reporterId !== userId && incident.reportedUserId !== userId) {
        throw new ApiError(403, 'ไม่มีสิทธิ์ดูรายงานนี้');
    }

    res.status(200).json({ success: true, data: incident });
});

const adminListIncidents = asyncHandler(async (req, res) => {
    const result = await incidentService.searchIncidentsAdmin(req.query);
    res.status(200).json({ success: true, message: 'ดึงข้อมูลรายการเหตุการณ์สำเร็จ', ...result });
});

const adminGetIncidentById = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const incident = await incidentService.getIncidentById(id);
    if (!incident) throw new ApiError(404, 'ไม่พบรายงานเหตุการณ์');
    res.status(200).json({ success: true, data: incident });
});

const adminUpdateIncident = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const adminId = req.user.sub;
    const updated = await incidentService.updateIncidentStatus(id, req.body, adminId);
    res.status(200).json({ success: true, data: updated });
});

const adminDeleteIncident = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const result = await incidentService.deleteIncident(id);
    res.status(200).json({ success: true, data: result });
});

const adminReopenIncident = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const adminId = req.user.sub;
    const newIncident = await incidentService.reopenIncident(id, req.body, adminId);
    res.status(201).json({ success: true, data: newIncident });
});

const getIncidentLogs = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const requesterId = req.user.sub;
    const requesterRole = req.user.role;
    const logs = await incidentService.getIncidentLogs(id, requesterId, requesterRole);
    res.status(200).json({ success: true, data: logs });
});

// โปรกซีดาวน์โหลดหลักฐาน (PDF/ไฟล์) จาก Cloudinary ผ่าน backend เพื่อหลีกเลี่ยง CORS และการบล็อกของเบราว์เซอร์
const proxyEvidence = asyncHandler(async (req, res) => {
    const rawUrl = req.query.url;
    if (!rawUrl || typeof rawUrl !== 'string') {
        throw new ApiError(400, 'ต้องส่ง query url');
    }
    let targetUrl;
    try {
        targetUrl = decodeURIComponent(rawUrl.trim());
    } catch {
        throw new ApiError(400, 'รูปแบบ url ไม่ถูกต้อง');
    }
    if (!targetUrl.startsWith('https://res.cloudinary.com/')) {
        throw new ApiError(400, 'อนุญาตเฉพาะ URL จาก Cloudinary');
    }
    const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
    if (cloudName && !targetUrl.includes(`res.cloudinary.com/${cloudName}/`)) {
        throw new ApiError(400, 'อนุญาตเฉพาะ Cloudinary ของโปรเจกต์นี้');
    }

    let axiosRes;
    try {
        axiosRes = await axios.get(targetUrl, {
            responseType: 'arraybuffer',
            maxContentLength: 50 * 1024 * 1024,
            timeout: 30000,
        });
    } catch (err) {
        if (err.response?.status === 403) {
            throw new ApiError(502, 'Cloudinary ไม่อนุญาตให้ส่งไฟล์นี้ (เปิด "Allow delivery of PDF and ZIP files" ใน Security)');
        }
        if (err.response?.status === 404) {
            throw new ApiError(404, 'ไม่พบไฟล์');
        }
        throw new ApiError(502, 'ดึงไฟล์จาก Cloudinary ไม่สำเร็จ');
    }

    const buffer = Buffer.from(axiosRes.data);
    const contentType = axiosRes.headers['content-type'] || 'application/pdf';
    const nameFromUrl = targetUrl.split('/').pop()?.split('?')[0] || 'evidence.pdf';
    const filename = decodeURIComponent(nameFromUrl) || 'evidence.pdf';

    res.setHeader('Content-Type', contentType);
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.setHeader('Content-Length', buffer.length);
    res.send(buffer);
});

module.exports = {
    createIncident,
    getMyIncidents,
    getIncidentById,
    adminListIncidents,
    adminGetIncidentById,
    adminUpdateIncident,
    adminReopenIncident,
    adminDeleteIncident,
    getIncidentLogs,
    proxyEvidence,
};

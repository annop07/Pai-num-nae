const asyncHandler = require("express-async-handler");
const incidentService = require("../services/incident.service");
const ApiError = require("../utils/ApiError");

const createIncident = asyncHandler(async (req, res) => {
    const reporterId = req.user.sub;
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
    res.status(200).json({ success: true, message: 'Incidents retrieved', ...result });
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

module.exports = {
    createIncident,
    getMyIncidents,
    getIncidentById,
    adminListIncidents,
    adminGetIncidentById,
    adminUpdateIncident,
    adminDeleteIncident,
};

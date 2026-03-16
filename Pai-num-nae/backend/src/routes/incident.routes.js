const express = require('express');
const validate = require('../middlewares/validate');
const { protect, requireAdmin } = require('../middlewares/auth');
const upload = require('../middlewares/upload.middleware');
const incidentController = require('../controllers/incident.controller');
const {
    createIncidentSchema,
    idParamSchema,
    updateIncidentSchema,
    listIncidentsQuerySchema,
} = require('../validations/incident.validation');

const router = express.Router();

// POST /api/incidents/admin
router.get(
    '/admin',
    protect,
    requireAdmin,
    validate({ query: listIncidentsQuerySchema }),
    incidentController.adminListIncidents
);

// GET /api/incidents/admin/:id
router.get(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    incidentController.adminGetIncidentById
);

// PATCH /api/incidents/admin/:id
router.patch(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema, body: updateIncidentSchema }),
    incidentController.adminUpdateIncident
);

// DELETE /api/incidents/admin/:id
router.delete(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    incidentController.adminDeleteIncident
);

// POST /api/incidents
router.post(
    '/',
    protect,
    upload.array('evidences', 5),
    validate({ body: createIncidentSchema }),
    incidentController.createIncident
);

// GET /api/incidents/me
router.get(
    '/me',
    protect,
    incidentController.getMyIncidents
);

// GET /api/incidents/:id
router.get(
    '/:id',
    protect,
    validate({ params: idParamSchema }),
    incidentController.getIncidentById
);

module.exports = router;

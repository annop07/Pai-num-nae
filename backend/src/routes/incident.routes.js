const express = require('express');
const validate = require('../middlewares/validate');
const { protect, requireAdmin } = require('../middlewares/auth');
const incidentController = require('../controllers/incident.controller');
const {
    createIncidentSchema,
    idParamSchema,
    updateIncidentSchema,
    listIncidentsQuerySchema,
} = require('../validations/incident.validation');

const router = express.Router();

router.get(
    '/admin',
    protect,
    requireAdmin,
    validate({ query: listIncidentsQuerySchema }),
    incidentController.adminListIncidents
);

router.get(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    incidentController.adminGetIncidentById
);

router.patch(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema, body: updateIncidentSchema }),
    incidentController.adminUpdateIncident
);

router.delete(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    incidentController.adminDeleteIncident
);

router.post(
    '/',
    protect,
    validate({ body: createIncidentSchema }),
    incidentController.createIncident
);

router.get(
    '/me',
    protect,
    incidentController.getMyIncidents
);

router.get(
    '/:id',
    protect,
    validate({ params: idParamSchema }),
    incidentController.getIncidentById
);

module.exports = router;

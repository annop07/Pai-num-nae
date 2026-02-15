const { z } = require('zod');
const { IncidentType, IncidentStatus, IncidentPriority } = require('@prisma/client');

const createIncidentSchema = z.object({
    type: z.nativeEnum(IncidentType, {
        required_error: 'ประเภทเหตุการณ์จำเป็นต้องระบุ',
        invalid_type_error: 'ประเภทเหตุการณ์ไม่ถูกต้อง',
    }),
    title: z.string().trim().min(1, 'กรุณาระบุหัวข้อ').max(200),
    description: z.string().trim().min(1, 'กรุณาระบุรายละเอียด'),
    reportedUserId: z.string().cuid({ message: 'Invalid user ID format' }).optional(),
    routeId: z.string().cuid({ message: 'Invalid route ID format' }).optional(),
    bookingId: z.string().cuid({ message: 'Invalid booking ID format' }).optional(),
    location: z.any().optional(),
    evidenceUrls: z.array(z.string().url()).optional().default([]),
    metadata: z.any().optional(),
});

const idParamSchema = z.object({
    id: z.string().cuid({ message: 'Invalid incident ID format' }),
});

const updateIncidentSchema = z.object({
    status: z.nativeEnum(IncidentStatus).optional(),
    priority: z.nativeEnum(IncidentPriority).optional(),
    resolution: z.string().trim().min(1).optional(),
}).refine(obj => Object.keys(obj).length > 0, { message: 'No fields to update' });

const listIncidentsQuerySchema = z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
    status: z.nativeEnum(IncidentStatus).optional(),
    type: z.nativeEnum(IncidentType).optional(),
    priority: z.nativeEnum(IncidentPriority).optional(),
    q: z.string().trim().min(1).optional(),
    sortBy: z.enum(['createdAt', 'status', 'priority', 'type']).default('createdAt'),
    sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

module.exports = {
    createIncidentSchema,
    idParamSchema,
    updateIncidentSchema,
    listIncidentsQuerySchema,
};

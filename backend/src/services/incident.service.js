const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const notificationService = require('./notification.service');

const INCIDENT_INCLUDE = {
    reporter: {
        select: { id: true, username: true, firstName: true, lastName: true, email: true, role: true },
    },
    reportedUser: {
        select: { id: true, username: true, firstName: true, lastName: true, email: true, role: true },
    },
    resolver: {
        select: { id: true, firstName: true, lastName: true, email: true },
    },
    route: {
        select: { id: true, startLocation: true, endLocation: true, departureTime: true },
    },
    booking: {
        select: { id: true, status: true, numberOfSeats: true },
    },
};

// Incident types that are directed AT a specific person (auto-assign reportedUserId)
const PERSON_RELATED_TYPES = [
    'INAPPROPRIATE_BEHAVIOR',
    'HARASSMENT',
    'FRAUD',
    'NO_SHOW_DRIVER',
    'NO_SHOW_PASSENGER',
    'LICENSE_PLATE_MISMATCH',
    'SAFETY_CONCERN',
    'PAYMENT_DISPUTE',
    'LOST_ITEM',
];

// Incident types that are general situation reports (do NOT auto-assign reportedUserId)
// ACCIDENT, VEHICLE_ISSUE, ROUTE_ISSUE, OTHER
const SITUATION_RELATED_TYPES = [
    'ACCIDENT',
    'VEHICLE_ISSUE',
    'ROUTE_ISSUE',
    'OTHER',
];

//Allowed status transitions
const ALLOWED_TRANSITIONS = {
    PENDING: ['INVESTIGATING', 'DISMISSED'],
    INVESTIGATING: ['RESOLVED', 'DISMISSED', 'ESCALATED'],
    ESCALATED: ['RESOLVED', 'DISMISSED'],
    RESOLVED: [],
    DISMISSED: [],
};

// Human-readable status labels for notifications
const STATUS_LABELS = {
    PENDING: 'รอดำเนินการ',
    INVESTIGATING: 'กำลังตรวจสอบ',
    RESOLVED: 'แก้ไขแล้ว',
    DISMISSED: 'ปฏิเสธ',
    ESCALATED: 'ส่งต่อผู้รับผิดชอบ',
};

// User Functions
async function createIncident(data, reporterId) {
    let routeIdToUse = data.routeId || null;
    let reportedUserIdToUse = data.reportedUserId || null;

    if (data.bookingId) {
        const booking = await prisma.booking.findUnique({
            where: { id: data.bookingId },
            select: { id: true, routeId: true, passengerId: true, route: { select: { driverId: true } } },
        });
        if (!booking) throw new ApiError(404, 'ไม่พบการจอง');
        // ดึง routeId จาก booking อัตโนมัติเมื่อไม่ได้ส่งมา (ทุก type)
        if (!routeIdToUse) routeIdToUse = booking.routeId;
        // auto-assign reportedUserId เฉพาะ type ที่เกี่ยวข้องกับบุคคล (PERSON_RELATED_TYPES)
        // type ที่เป็นการรายงานสถานการณ์ทั่วไป (SITUATION_RELATED_TYPES) จะไม่ assign target
        if (!reportedUserIdToUse && PERSON_RELATED_TYPES.includes(data.type)) {
            if (reporterId === booking.route?.driverId) {
                // ผู้แจ้งเป็นคนขับ → target คือผู้โดยสารของ booking นี้
                reportedUserIdToUse = booking.passengerId;
            } else if (reporterId === booking.passengerId) {
                // ผู้แจ้งเป็นผู้โดยสาร → target คือคนขับ
                reportedUserIdToUse = booking.route?.driverId || null;
            }
        }
        // SITUATION_RELATED_TYPES: ไม่ auto-assign reportedUserId (null) แม้จะมี bookingId
    }

    if (routeIdToUse) {
        const route = await prisma.route.findUnique({ where: { id: routeIdToUse } });
        if (!route) throw new ApiError(404, 'ไม่พบเส้นทาง');
    }

    if (reportedUserIdToUse) {
        const user = await prisma.user.findUnique({ where: { id: reportedUserIdToUse } });
        if (!user) throw new ApiError(404, 'ไม่พบผู้ใช้ที่ถูกรายงาน');
        if (user.id === reporterId) throw new ApiError(400, 'ไม่สามารถรายงานตัวเองได้');
    }

    return prisma.incident.create({
        data: {
            reporterId,
            reportedUserId: reportedUserIdToUse,
            routeId: routeIdToUse,
            bookingId: data.bookingId || null,
            type: data.type,
            priority: data.priority || 'NORMAL',
            title: data.title,
            description: data.description,
            location: data.location || null,
            evidenceUrls: data.evidenceUrls || [],
            metadata: data.metadata || null,
        },
        include: INCIDENT_INCLUDE,
    }).then((result) => {
        // แจ้งเตือน Admin ทุกคนเมื่อมี Incident ใหม่ (ทำงานในพื้นหลัง ไม่หน่วง response)
        notifyAdminsNewIncident(result).catch((err) =>
            console.error('Failed to notify admins of new incident:', err)
        );
        return result;
    });
}

async function notifyAdminsNewIncident(incident) {
    const admins = await prisma.user.findMany({
        where: { role: 'ADMIN' },
        select: { id: true },
    });
    const reporter = incident.reporter;
    const reporterName = reporter
        ? `${reporter.firstName || ''} ${reporter.lastName || ''}`.trim() || reporter.email
        : 'ผู้ใช้';
    for (const admin of admins) {
        await notificationService.createNotificationByAdmin({
            userId: admin.id,
            type: 'INCIDENT',
            title: `แจ้งเหตุการณ์ใหม่: ${incident.title}`,
            body: `${reporterName} แจ้งเหตุการณ์ "${incident.title}" กรุณาตรวจสอบและดำเนินการ`,
            link: `/admin/incidents/${incident.id}`,
            metadata: { incidentId: incident.id },
        });
    }
}

async function getMyIncidents(userId) {
    return prisma.incident.findMany({
        where: {
            OR: [
                { reporterId: userId },
                { reportedUserId: userId },
            ],
            isArchived: false,    // ซ่อนเคสเก่าที่ถูก archive หลัง reopen
        },
        include: INCIDENT_INCLUDE,
        orderBy: { createdAt: 'desc' },
    });
}

async function getIncidentById(id) {
    const incident = await prisma.incident.findUnique({
        where: { id },
        include: INCIDENT_INCLUDE,
    });
    return incident;
}

// Admin Functions
async function searchIncidentsAdmin(opts = {}) {
    const {
        page = 1,
        limit = 20,
        status,
        type,
        priority,
        q,
        sortBy = 'createdAt',
        sortOrder = 'desc',
    } = opts;

    const where = { isArchived: false };

    if (status) where.status = status;
    if (type) where.type = type;
    if (priority) where.priority = priority;

    if (q) {
        where.OR = [
            { title: { contains: q, mode: 'insensitive' } },
            { description: { contains: q, mode: 'insensitive' } },
            {
                reporter: {
                    OR: [
                        { firstName: { contains: q, mode: 'insensitive' } },
                        { lastName: { contains: q, mode: 'insensitive' } },
                        { email: { contains: q, mode: 'insensitive' } },
                    ]
                }
            },
        ];
    }

    const [total, data] = await Promise.all([
        prisma.incident.count({ where }),
        prisma.incident.findMany({
            where,
            include: INCIDENT_INCLUDE,
            orderBy: { [sortBy]: sortOrder },
            skip: (page - 1) * limit,
            take: limit,
        }),
    ]);

    return {
        data,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit),
        },
    };
}

async function updateIncidentStatus(id, data, adminId) {
    const incident = await prisma.incident.findUnique({ where: { id } });
    if (!incident) throw new ApiError(404, 'ไม่พบรายงานเหตุการณ์');

    // Block archived incidents
    if (incident.isArchived) throw new ApiError(400, 'ไม่สามารถแก้ไขเหตุการณ์ที่ถูก archive แล้ว');

    // Validate transition
    const allowed = ALLOWED_TRANSITIONS[incident.status] || [];
    if (!allowed.includes(data.status)) {
        throw new ApiError(400, `ไม่สามารถเปลี่ยนสถานะจาก ${incident.status} ไปเป็น ${data.status} ได้`);
    }

    const updateData = {
        status: data.status,
        ...(data.priority && { priority: data.priority }),
        ...(data.resolution && { resolution: data.resolution }),
        ...(data.status === 'RESOLVED' && { resolvedBy: adminId, resolvedAt: new Date() }),
    };

    const [updated] = await prisma.$transaction([
        prisma.incident.update({
            where: { id },
            data: updateData,
            include: INCIDENT_INCLUDE,
        }),
        prisma.incidentStatusLog.create({
            data: {
                incidentId: id,
                fromStatus: incident.status,
                toStatus: data.status,
                reason: data.reason,
                note: data.note,
                changedById: adminId,
            },
        }),
    ]);

    // Notify reporter (background, non-blocking)
    if (incident.reporterId) {
        const statusLabel = STATUS_LABELS[data.status] || data.status;
        notificationService.createNotificationByAdmin({
            userId: incident.reporterId,
            type: 'INCIDENT',
            title: `อัปเดตสถานะ: ${updated.title}`,
            body: `สถานะรายงาน "${updated.title}" เปลี่ยนเป็น "${statusLabel}"\nหมายเหตุ: ${data.note}`,
            link: `/myIncidents`,
            metadata: { incidentId: updated.id, status: data.status },
        }).catch(err => console.error('Failed to notify reporter:', err));
    }

    return updated;
}


async function getIncidentLogs(id, requesterId, requesterRole) {
    const incident = await prisma.incident.findUnique({ where: { id } });
    if (!incident) throw new ApiError(404, 'ไม่พบรายงานเหตุการณ์');

    // Allow only reporter or admin
    if (requesterRole !== 'ADMIN' && incident.reporterId !== requesterId) {
        throw new ApiError(403, 'ไม่มีสิทธิ์ดู log นี้');
    }

    return prisma.incidentStatusLog.findMany({
        where: { incidentId: id },
        orderBy: { createdAt: 'asc' },
        include: {
            changedBy: {
                select: { id: true, firstName: true, lastName: true, role: true },
            },
        },
    });
}

async function deleteIncident(id) {
    const incident = await prisma.incident.findUnique({ where: { id } });
    if (!incident) throw new ApiError(404, 'ไม่พบรายงานเหตุการณ์');

    await prisma.incident.delete({ where: { id } });
    return { message: 'ลบรายงานเหตุการณ์สำเร็จ' };
}

module.exports = {
    createIncident,
    getMyIncidents,
    getIncidentById,
    searchIncidentsAdmin,
    updateIncidentStatus,
    getIncidentLogs,
    deleteIncident,
};

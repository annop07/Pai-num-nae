const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const INCIDENT_INCLUDE = {
    reporter: {
        select: { id: true, firstName: true, lastName: true, email: true, role: true },
    },
    reportedUser: {
        select: { id: true, firstName: true, lastName: true, email: true, role: true },
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

// User Functions

async function createIncident(data, reporterId) {
    if (data.reportedUserId) {
        const user = await prisma.user.findUnique({ where: { id: data.reportedUserId } });
        if (!user) throw new ApiError(404, 'ไม่พบผู้ใช้ที่ถูกรายงาน');
        if (user.id === reporterId) throw new ApiError(400, 'ไม่สามารถรายงานตัวเองได้');
    }

    if (data.routeId) {
        const route = await prisma.route.findUnique({ where: { id: data.routeId } });
        if (!route) throw new ApiError(404, 'ไม่พบเส้นทาง');
    }

    if (data.bookingId) {
        const booking = await prisma.booking.findUnique({ where: { id: data.bookingId } });
        if (!booking) throw new ApiError(404, 'ไม่พบการจอง');
    }

    const incident = await prisma.incident.create({
        data: {
            reporterId,
            reportedUserId: data.reportedUserId || null,
            routeId: data.routeId || null,
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
    });

    return incident;
}

async function getMyIncidents(userId) {
    const incidents = await prisma.incident.findMany({
        where: {
            OR: [
                { reporterId: userId },
                { reportedUserId: userId },
            ],
        },
        include: INCIDENT_INCLUDE,
        orderBy: { createdAt: 'desc' },
    });
    return incidents;
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

    const where = {};

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

    const updateData = {};

    if (data.status) {
        updateData.status = data.status;
        if (data.status === 'RESOLVED') {
            updateData.resolvedBy = adminId;
            updateData.resolvedAt = new Date();
        }
    }

    if (data.priority) updateData.priority = data.priority;
    if (data.resolution) updateData.resolution = data.resolution;

    const updated = await prisma.incident.update({
        where: { id },
        data: updateData,
        include: INCIDENT_INCLUDE,
    });

    return updated;
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
    deleteIncident,
};

const incidentService = require('../../src/services/incident.service');
const prisma = require('../../src/utils/prisma');
const notificationService = require('../../src/services/notification.service');
const { updateIncidentSchema, reopenIncidentSchema } = require('../../src/validations/incident.validation');

// Mock Prisma
jest.mock('../../src/utils/prisma', () => ({
    incident: {
        create: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        count: jest.fn(),
    },
    incidentStatusLog: {
        create: jest.fn(),
        findMany: jest.fn(),
    },
    user: {
        findUnique: jest.fn(),
        findMany: jest.fn(),
    },
    route: {
        findUnique: jest.fn(),
    },
    booking: {
        findUnique: jest.fn(),
    },
    $transaction: jest.fn(),
}));

jest.mock('../../src/services/notification.service', () => ({
    createNotificationByAdmin: jest.fn().mockResolvedValue(true),
}));

// ============================================================
// Test Data
// ============================================================
const ADMIN_ID = 'admin-001';
const REPORTER_ID = 'reporter-001';
const REPORTED_USER_ID = 'reported-001';
const ROUTE_ID = 'route-001';
const BOOKING_ID = 'booking-001';

const baseMockIncident = {
    id: 'inc-001',
    reporterId: REPORTER_ID,
    reportedUserId: REPORTED_USER_ID,
    routeId: ROUTE_ID,
    bookingId: BOOKING_ID,
    type: 'SAFETY_CONCERN',
    priority: 'NORMAL',
    title: 'ทดสอบรายงานเหตุการณ์',
    description: 'รายละเอียดทดสอบ',
    status: 'PENDING',
    isArchived: false,
    revisionNumber: 1,
    evidenceUrls: [],
    location: null,
    metadata: null,
    reporter: { id: REPORTER_ID, firstName: 'Test', lastName: 'Reporter', email: 'reporter@test.com' },
};

// ============================================================
// Admin Incident Tests
// ============================================================
describe('Unit Test: Admin จัดการเหตุการณ์ (Incident Management)', () => {
    beforeEach(() => {
        prisma.user.findMany.mockResolvedValue([]);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    // ----------------------------------------------------------
    // searchIncidentsAdmin
    // ----------------------------------------------------------
    describe('searchIncidentsAdmin — Admin ค้นหารายการเหตุการณ์', () => {
        it('ควรคืนค่ารายการเหตุการณ์แบบแบ่งหน้า (default page=1, limit=20)', async () => {
            const mockData = [baseMockIncident];
            prisma.incident.count.mockResolvedValue(1);
            prisma.incident.findMany.mockResolvedValue(mockData);

            const result = await incidentService.searchIncidentsAdmin({});

            expect(result.data).toEqual(mockData);
            expect(result.pagination).toEqual({
                page: 1,
                limit: 20,
                total: 1,
                totalPages: 1,
            });
            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: { isArchived: false },
                orderBy: { createdAt: 'desc' },
                skip: 0,
                take: 20,
            }));
        });

        it('ควร filter ด้วย status ได้', async () => {
            prisma.incident.count.mockResolvedValue(0);
            prisma.incident.findMany.mockResolvedValue([]);

            await incidentService.searchIncidentsAdmin({ status: 'INVESTIGATING' });

            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: expect.objectContaining({ status: 'INVESTIGATING', isArchived: false }),
            }));
        });

        it('ควร filter ด้วย type ได้', async () => {
            prisma.incident.count.mockResolvedValue(0);
            prisma.incident.findMany.mockResolvedValue([]);

            await incidentService.searchIncidentsAdmin({ type: 'HARASSMENT' });

            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: expect.objectContaining({ type: 'HARASSMENT', isArchived: false }),
            }));
        });

        it('ควร filter ด้วย priority ได้', async () => {
            prisma.incident.count.mockResolvedValue(0);
            prisma.incident.findMany.mockResolvedValue([]);

            await incidentService.searchIncidentsAdmin({ priority: 'URGENT' });

            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: expect.objectContaining({ priority: 'URGENT', isArchived: false }),
            }));
        });

        it('ควรค้นหาด้วย keyword (q) ใน title, description, reporter', async () => {
            prisma.incident.count.mockResolvedValue(0);
            prisma.incident.findMany.mockResolvedValue([]);

            await incidentService.searchIncidentsAdmin({ q: 'ขับเร็ว' });

            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: expect.objectContaining({
                    isArchived: false,
                    OR: expect.arrayContaining([
                        { title: { contains: 'ขับเร็ว', mode: 'insensitive' } },
                        { description: { contains: 'ขับเร็ว', mode: 'insensitive' } },
                    ]),
                }),
            }));
        });

        it('ควรแบ่งหน้าถูกต้อง (page=2, limit=5)', async () => {
            prisma.incident.count.mockResolvedValue(12);
            prisma.incident.findMany.mockResolvedValue([]);

            const result = await incidentService.searchIncidentsAdmin({ page: 2, limit: 5 });

            expect(result.pagination).toEqual({
                page: 2,
                limit: 5,
                total: 12,
                totalPages: 3,
            });
            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                skip: 5,
                take: 5,
            }));
        });

        it('ควรเรียงลำดับตาม sortBy และ sortOrder ได้', async () => {
            prisma.incident.count.mockResolvedValue(0);
            prisma.incident.findMany.mockResolvedValue([]);

            await incidentService.searchIncidentsAdmin({ sortBy: 'priority', sortOrder: 'asc' });

            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                orderBy: { priority: 'asc' },
            }));
        });
    });

    // ----------------------------------------------------------
    // updateIncidentStatus
    // ----------------------------------------------------------
    describe('updateIncidentStatus — Admin อัปเดตสถานะเหตุการณ์', () => {
        it('ควรเปลี่ยนสถานะ PENDING → INVESTIGATING สำเร็จ', async () => {
            const existingIncident = { ...baseMockIncident, status: 'PENDING' };
            const updatedIncident = { ...existingIncident, status: 'INVESTIGATING', priority: 'HIGH' };

            prisma.incident.findUnique.mockResolvedValue(existingIncident);
            prisma.$transaction.mockResolvedValue([updatedIncident]);

            const result = await incidentService.updateIncidentStatus('inc-001', {
                status: 'INVESTIGATING',
                priority: 'HIGH',
                reason: 'EVIDENCE_REVIEWED',
                note: 'กำลังตรวจสอบหลักฐาน',
            }, ADMIN_ID);

            expect(result.status).toBe('INVESTIGATING');
            expect(prisma.$transaction).toHaveBeenCalled();
        });

        it('ควรเปลี่ยนสถานะ PENDING → DISMISSED สำเร็จ', async () => {
            const existingIncident = { ...baseMockIncident, status: 'PENDING' };
            const updatedIncident = { ...existingIncident, status: 'DISMISSED' };

            prisma.incident.findUnique.mockResolvedValue(existingIncident);
            prisma.$transaction.mockResolvedValue([updatedIncident]);

            const result = await incidentService.updateIncidentStatus('inc-001', {
                status: 'DISMISSED',
                reason: 'INSUFFICIENT_EVIDENCE',
                note: 'หลักฐานไม่เพียงพอ',
            }, ADMIN_ID);

            expect(result.status).toBe('DISMISSED');
        });

        it('ควรเปลี่ยนสถานะ INVESTIGATING → RESOLVED พร้อมบันทึก resolvedBy และ resolvedAt', async () => {
            const existingIncident = { ...baseMockIncident, status: 'INVESTIGATING' };
            const updatedIncident = {
                ...existingIncident,
                status: 'RESOLVED',
                resolution: 'ตักเตือนผู้ขับแล้ว',
                resolvedBy: ADMIN_ID,
                resolvedAt: new Date(),
            };

            prisma.incident.findUnique.mockResolvedValue(existingIncident);
            prisma.$transaction.mockResolvedValue([updatedIncident]);

            const result = await incidentService.updateIncidentStatus('inc-001', {
                status: 'RESOLVED',
                resolution: 'ตักเตือนผู้ขับแล้ว',
                reason: 'MATTER_RESOLVED',
                note: 'ดำเนินการตักเตือนเรียบร้อย',
            }, ADMIN_ID);

            expect(result.status).toBe('RESOLVED');
            expect(result.resolvedBy).toBe(ADMIN_ID);
            expect(result.resolvedAt).not.toBeNull();
        });

        it('ควรเปลี่ยนสถานะ INVESTIGATING → ESCALATED สำเร็จ', async () => {
            const existingIncident = { ...baseMockIncident, status: 'INVESTIGATING' };
            const updatedIncident = { ...existingIncident, status: 'ESCALATED' };

            prisma.incident.findUnique.mockResolvedValue(existingIncident);
            prisma.$transaction.mockResolvedValue([updatedIncident]);

            const result = await incidentService.updateIncidentStatus('inc-001', {
                status: 'ESCALATED',
                reason: 'REQUIRES_ESCALATION',
                note: 'ต้องส่งต่อผู้รับผิดชอบ',
            }, ADMIN_ID);

            expect(result.status).toBe('ESCALATED');
        });

        it('ควรเปลี่ยนสถานะ ESCALATED → RESOLVED สำเร็จ', async () => {
            const existingIncident = { ...baseMockIncident, status: 'ESCALATED' };
            const updatedIncident = { ...existingIncident, status: 'RESOLVED', resolvedBy: ADMIN_ID };

            prisma.incident.findUnique.mockResolvedValue(existingIncident);
            prisma.$transaction.mockResolvedValue([updatedIncident]);

            const result = await incidentService.updateIncidentStatus('inc-001', {
                status: 'RESOLVED',
                reason: 'MATTER_RESOLVED',
                note: 'แก้ไขแล้ว',
            }, ADMIN_ID);

            expect(result.status).toBe('RESOLVED');
        });

        it('ควรแจ้ง 400 ถ้า transition ไม่ถูกต้อง (PENDING → RESOLVED)', async () => {
            const existingIncident = { ...baseMockIncident, status: 'PENDING' };
            prisma.incident.findUnique.mockResolvedValue(existingIncident);

            await expect(
                incidentService.updateIncidentStatus('inc-001', {
                    status: 'RESOLVED',
                    reason: 'MATTER_RESOLVED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('ไม่สามารถเปลี่ยนสถานะจาก PENDING ไปเป็น RESOLVED ได้');
        });

        it('ควรแจ้ง 400 ถ้า transition ไม่ถูกต้อง (RESOLVED → INVESTIGATING)', async () => {
            const existingIncident = { ...baseMockIncident, status: 'RESOLVED' };
            prisma.incident.findUnique.mockResolvedValue(existingIncident);

            await expect(
                incidentService.updateIncidentStatus('inc-001', {
                    status: 'INVESTIGATING',
                    reason: 'EVIDENCE_REVIEWED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('ไม่สามารถเปลี่ยนสถานะจาก RESOLVED ไปเป็น INVESTIGATING ได้');
        });

        it('ควรแจ้ง 400 ถ้า transition ไม่ถูกต้อง (DISMISSED → INVESTIGATING)', async () => {
            const existingIncident = { ...baseMockIncident, status: 'DISMISSED' };
            prisma.incident.findUnique.mockResolvedValue(existingIncident);

            await expect(
                incidentService.updateIncidentStatus('inc-001', {
                    status: 'INVESTIGATING',
                    reason: 'EVIDENCE_REVIEWED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('ไม่สามารถเปลี่ยนสถานะจาก DISMISSED ไปเป็น INVESTIGATING ได้');
        });

        it('ควรแจ้ง 400 ถ้าเหตุการณ์ถูก archive แล้ว', async () => {
            const archivedIncident = { ...baseMockIncident, isArchived: true };
            prisma.incident.findUnique.mockResolvedValue(archivedIncident);

            await expect(
                incidentService.updateIncidentStatus('inc-001', {
                    status: 'INVESTIGATING',
                    reason: 'EVIDENCE_REVIEWED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('ไม่สามารถแก้ไขเหตุการณ์ที่ถูก archive แล้ว');
        });

        it('ควรแจ้ง 404 ถ้าไม่พบเหตุการณ์', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.updateIncidentStatus('non-existent', {
                    status: 'INVESTIGATING',
                    reason: 'EVIDENCE_REVIEWED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });

        it('ควรส่งแจ้งเตือนไปยัง reporter เมื่ออัปเดตสถานะสำเร็จ', async () => {
            const existingIncident = { ...baseMockIncident, status: 'PENDING' };
            const updatedIncident = { ...existingIncident, status: 'INVESTIGATING' };

            prisma.incident.findUnique.mockResolvedValue(existingIncident);
            prisma.$transaction.mockResolvedValue([updatedIncident]);

            await incidentService.updateIncidentStatus('inc-001', {
                status: 'INVESTIGATING',
                reason: 'EVIDENCE_REVIEWED',
                note: 'กำลังตรวจสอบ',
            }, ADMIN_ID);

            expect(notificationService.createNotificationByAdmin).toHaveBeenCalledWith(expect.objectContaining({
                userId: REPORTER_ID,
                type: 'INCIDENT',
                metadata: expect.objectContaining({
                    incidentId: 'inc-001',
                    status: 'INVESTIGATING',
                }),
            }));
        });
    });

    // ----------------------------------------------------------
    // reopenIncident
    // ----------------------------------------------------------
    describe('reopenIncident — Admin เปิดเหตุการณ์ใหม่', () => {
        it('ควร archive เหตุการณ์เดิมและสร้างเหตุการณ์ใหม่จาก RESOLVED สำเร็จ', async () => {
            const resolvedIncident = { ...baseMockIncident, status: 'RESOLVED', revisionNumber: 1 };
            const newIncident = {
                ...baseMockIncident,
                id: 'inc-002',
                status: 'PENDING',
                parentIncidentId: 'inc-001',
                revisionNumber: 2,
            };

            prisma.incident.findUnique.mockResolvedValue(resolvedIncident);
            prisma.$transaction.mockImplementation(async (callback) => {
                const tx = {
                    incident: {
                        update: jest.fn().mockResolvedValue({ ...resolvedIncident, isArchived: true }),
                        create: jest.fn().mockResolvedValue(newIncident),
                    },
                    incidentStatusLog: {
                        create: jest.fn().mockResolvedValue({}),
                    },
                };
                return callback(tx);
            });

            const result = await incidentService.reopenIncident('inc-001', {
                reason: 'REOPENED',
                note: 'ต้องตรวจสอบเพิ่มเติม',
            }, ADMIN_ID);

            expect(result.id).toBe('inc-002');
            expect(result.status).toBe('PENDING');
            expect(result.parentIncidentId).toBe('inc-001');
            expect(result.revisionNumber).toBe(2);
        });

        it('ควร reopen จากสถานะ DISMISSED ได้', async () => {
            const dismissedIncident = { ...baseMockIncident, status: 'DISMISSED', revisionNumber: 1 };
            const newIncident = {
                ...baseMockIncident,
                id: 'inc-003',
                status: 'PENDING',
                parentIncidentId: 'inc-001',
                revisionNumber: 2,
            };

            prisma.incident.findUnique.mockResolvedValue(dismissedIncident);
            prisma.$transaction.mockImplementation(async (callback) => {
                const tx = {
                    incident: {
                        update: jest.fn().mockResolvedValue({ ...dismissedIncident, isArchived: true }),
                        create: jest.fn().mockResolvedValue(newIncident),
                    },
                    incidentStatusLog: {
                        create: jest.fn().mockResolvedValue({}),
                    },
                };
                return callback(tx);
            });

            const result = await incidentService.reopenIncident('inc-001', {
                reason: 'REOPENED',
                note: 'พบหลักฐานใหม่',
            }, ADMIN_ID);

            expect(result.status).toBe('PENDING');
        });

        it('ควรส่งแจ้งเตือนไปยัง reporter เมื่อ reopen สำเร็จ', async () => {
            const resolvedIncident = { ...baseMockIncident, status: 'RESOLVED', revisionNumber: 1 };
            const newIncident = {
                ...baseMockIncident,
                id: 'inc-004',
                status: 'PENDING',
                parentIncidentId: 'inc-001',
                revisionNumber: 2,
                title: 'ทดสอบรายงานเหตุการณ์',
            };

            prisma.incident.findUnique.mockResolvedValue(resolvedIncident);
            prisma.$transaction.mockImplementation(async (callback) => {
                const tx = {
                    incident: {
                        update: jest.fn().mockResolvedValue({}),
                        create: jest.fn().mockResolvedValue(newIncident),
                    },
                    incidentStatusLog: {
                        create: jest.fn().mockResolvedValue({}),
                    },
                };
                return callback(tx);
            });

            await incidentService.reopenIncident('inc-001', {
                reason: 'REOPENED',
                note: 'ต้องตรวจสอบใหม่',
            }, ADMIN_ID);

            expect(notificationService.createNotificationByAdmin).toHaveBeenCalledWith(expect.objectContaining({
                userId: REPORTER_ID,
                type: 'INCIDENT',
                metadata: expect.objectContaining({
                    incidentId: 'inc-004',
                    parentIncidentId: 'inc-001',
                }),
            }));
        });

        it('ควรแจ้ง 400 ถ้าสถานะไม่ใช่ terminal (PENDING)', async () => {
            const pendingIncident = { ...baseMockIncident, status: 'PENDING' };
            prisma.incident.findUnique.mockResolvedValue(pendingIncident);

            await expect(
                incidentService.reopenIncident('inc-001', {
                    reason: 'REOPENED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('สามารถ Reopen ได้เฉพาะเหตุการณ์ที่ RESOLVED หรือ DISMISSED เท่านั้น');
        });

        it('ควรแจ้ง 400 ถ้าสถานะไม่ใช่ terminal (INVESTIGATING)', async () => {
            const investigatingIncident = { ...baseMockIncident, status: 'INVESTIGATING' };
            prisma.incident.findUnique.mockResolvedValue(investigatingIncident);

            await expect(
                incidentService.reopenIncident('inc-001', {
                    reason: 'REOPENED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('สามารถ Reopen ได้เฉพาะเหตุการณ์ที่ RESOLVED หรือ DISMISSED เท่านั้น');
        });

        it('ควรแจ้ง 400 ถ้าสถานะไม่ใช่ terminal (ESCALATED)', async () => {
            const escalatedIncident = { ...baseMockIncident, status: 'ESCALATED' };
            prisma.incident.findUnique.mockResolvedValue(escalatedIncident);

            await expect(
                incidentService.reopenIncident('inc-001', {
                    reason: 'REOPENED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('สามารถ Reopen ได้เฉพาะเหตุการณ์ที่ RESOLVED หรือ DISMISSED เท่านั้น');
        });

        it('ควรแจ้ง 404 ถ้าไม่พบเหตุการณ์', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.reopenIncident('non-existent', {
                    reason: 'REOPENED',
                    note: 'test',
                }, ADMIN_ID)
            ).rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });
    });

    // ----------------------------------------------------------
    // deleteIncident
    // ----------------------------------------------------------
    describe('deleteIncident — Admin ลบเหตุการณ์', () => {
        it('ควรลบเหตุการณ์สำเร็จ', async () => {
            prisma.incident.findUnique.mockResolvedValue(baseMockIncident);
            prisma.incident.delete.mockResolvedValue(baseMockIncident);

            const result = await incidentService.deleteIncident('inc-001');

            expect(result.message).toBe('ลบรายงานเหตุการณ์สำเร็จ');
            expect(prisma.incident.delete).toHaveBeenCalledWith({ where: { id: 'inc-001' } });
        });

        it('ควรแจ้ง 404 ถ้าไม่พบเหตุการณ์', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.deleteIncident('non-existent')
            ).rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });
    });

    // ----------------------------------------------------------
    // getIncidentLogs — Admin
    // ----------------------------------------------------------
    describe('getIncidentLogs — Admin ดู Log ของทุกเหตุการณ์', () => {
        it('ควรคืน logs สำหรับ Admin ได้แม้ไม่ใช่ reporter', async () => {
            const mockIncident = { id: 'inc-001', reporterId: REPORTER_ID };
            const mockLogs = [
                { id: 'log-1', incidentId: 'inc-001', fromStatus: null, toStatus: 'PENDING', changedBy: { id: ADMIN_ID } },
                { id: 'log-2', incidentId: 'inc-001', fromStatus: 'PENDING', toStatus: 'INVESTIGATING', changedBy: { id: ADMIN_ID } },
                { id: 'log-3', incidentId: 'inc-001', fromStatus: 'INVESTIGATING', toStatus: 'RESOLVED', changedBy: { id: ADMIN_ID } },
            ];

            prisma.incident.findUnique.mockResolvedValue(mockIncident);
            prisma.incidentStatusLog.findMany.mockResolvedValue(mockLogs);

            const result = await incidentService.getIncidentLogs('inc-001', ADMIN_ID, 'ADMIN');

            expect(result).toEqual(mockLogs);
            expect(result).toHaveLength(3);
            expect(prisma.incidentStatusLog.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: { incidentId: 'inc-001' },
                orderBy: { createdAt: 'asc' },
            }));
        });

        it('ควรแจ้ง 404 ถ้า incident ไม่พบ', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.getIncidentLogs('non-existent', ADMIN_ID, 'ADMIN')
            ).rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });
    });

    // ----------------------------------------------------------
    // Validation — updateIncidentSchema (Zod)
    // ----------------------------------------------------------
    describe('Validation — updateIncidentSchema (ข้อมูลอัปเดตสถานะ)', () => {
        it('ควร reject ถ้าไม่ส่ง status', () => {
            const data = {
                reason: 'EVIDENCE_REVIEWED',
                note: 'หมายเหตุทดสอบ',
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('status'))).toBe(true);
        });

        it('ควร reject ถ้า status ไม่ถูกต้อง (ค่านอก enum)', () => {
            const data = {
                status: 'INVALID_STATUS',
                reason: 'EVIDENCE_REVIEWED',
                note: 'หมายเหตุทดสอบ',
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('status'))).toBe(true);
        });

        it('ควร reject ถ้าไม่ส่ง reason', () => {
            const data = {
                status: 'INVESTIGATING',
                note: 'หมายเหตุทดสอบ',
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('reason'))).toBe(true);
        });

        it('ควร reject ถ้า reason ไม่ถูกต้อง (ค่านอก enum)', () => {
            const data = {
                status: 'INVESTIGATING',
                reason: 'INVALID_REASON',
                note: 'หมายเหตุทดสอบ',
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('reason'))).toBe(true);
        });

        it('ควร reject ถ้า note เป็นค่าว่าง', () => {
            const data = {
                status: 'INVESTIGATING',
                reason: 'EVIDENCE_REVIEWED',
                note: '',
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues[0].message).toBe('กรุณาระบุหมายเหตุ');
        });

        it('ควร reject ถ้าไม่ส่ง note', () => {
            const data = {
                status: 'INVESTIGATING',
                reason: 'EVIDENCE_REVIEWED',
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('note'))).toBe(true);
        });

        it('ควร reject ถ้า note ยาวเกิน 1000 ตัวอักษร', () => {
            const data = {
                status: 'INVESTIGATING',
                reason: 'EVIDENCE_REVIEWED',
                note: 'A'.repeat(1001),
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('note'))).toBe(true);
        });

        it('ควรผ่านเมื่อข้อมูลถูกต้องครบถ้วน', () => {
            const data = {
                status: 'INVESTIGATING',
                reason: 'EVIDENCE_REVIEWED',
                note: 'กำลังตรวจสอบหลักฐาน',
            };

            const result = updateIncidentSchema.safeParse(data);

            expect(result.success).toBe(true);
        });
    });

    // ----------------------------------------------------------
    // Validation — reopenIncidentSchema (Zod)
    // ----------------------------------------------------------
    describe('Validation — reopenIncidentSchema (ข้อมูล Reopen)', () => {
        it('ควร reject ถ้าไม่ส่ง reason', () => {
            const data = {
                note: 'ต้องตรวจสอบใหม่',
            };

            const result = reopenIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('reason'))).toBe(true);
        });

        it('ควร reject ถ้า reason ไม่ถูกต้อง', () => {
            const data = {
                reason: 'INVALID_REASON',
                note: 'ต้องตรวจสอบใหม่',
            };

            const result = reopenIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
        });

        it('ควร reject ถ้า note เป็นค่าว่าง', () => {
            const data = {
                reason: 'REOPENED',
                note: '',
            };

            const result = reopenIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues[0].message).toBe('กรุณาระบุหมายเหตุ');
        });

        it('ควร reject ถ้าไม่ส่ง note', () => {
            const data = {
                reason: 'REOPENED',
            };

            const result = reopenIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('note'))).toBe(true);
        });

        it('ควร reject ถ้า note ยาวเกิน 1000 ตัวอักษร', () => {
            const data = {
                reason: 'REOPENED',
                note: 'A'.repeat(1001),
            };

            const result = reopenIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
        });

        it('ควรผ่านเมื่อข้อมูลถูกต้องครบถ้วน', () => {
            const data = {
                reason: 'REOPENED',
                note: 'พบหลักฐานเพิ่มเติม ต้องตรวจสอบใหม่',
            };

            const result = reopenIncidentSchema.safeParse(data);

            expect(result.success).toBe(true);
        });
    });
});

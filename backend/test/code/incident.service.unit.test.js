const incidentService = require('../../src/services/incident.service');
const prisma = require('../../src/utils/prisma');
const notificationService = require('../../src/services/notification.service');
const ApiError = require('../../src/utils/ApiError');

// Mock external dependencies
jest.mock('../../src/utils/prisma', () => ({
    incident: {
        create: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        count: jest.fn(),
    },
    chatRoom: {
        create: jest.fn(),
    },
    user: {
        findUnique: jest.fn(),
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
    createNotificationByAdmin: jest.fn(),
}));

describe('การทดสอบ Unit Test ของ Incident Service', () => {
    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('createIncident (สร้างรายงานเหตุการณ์)', () => {
        it('ควรสร้างรายงานเหตุการณ์และห้องแชทสำเร็จ', async () => {
            const data = {
                type: 'SAFETY_CONCERN',
                title: 'Test Incident',
                description: 'Description',
                priority: 'HIGH'
            };
            const reporterId = 'reporter-1';
            const mockIncident = { id: 'inc-1', ...data, reporterId };

            // Mock transaction to execute callback immediately with prisma mock
            prisma.$transaction.mockImplementation(async (callback) => {
                return callback(prisma);
            });

            prisma.incident.create.mockResolvedValue(mockIncident);
            prisma.chatRoom.create.mockResolvedValue({ id: 'room-1', incidentId: 'inc-1' });

            const result = await incidentService.createIncident(data, reporterId);

            expect(prisma.$transaction).toHaveBeenCalled();
            expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                data: expect.objectContaining({
                    reporterId,
                    type: 'SAFETY_CONCERN',
                    priority: 'HIGH'
                })
            }));
            expect(prisma.chatRoom.create).toHaveBeenCalledWith(expect.objectContaining({
                data: { incidentId: 'inc-1' }
            }));
            expect(result).toMatchObject(mockIncident);
            expect(result).toHaveProperty('chatRoom');
        });

        it('ควรแจ้ง error 404 ถ้าไม่พบผู้ใช้ที่ถูกรายงาน', async () => {
            const data = { reportedUserId: 'missing-user', type: 'HARASSMENT' };
            prisma.user.findUnique.mockResolvedValue(null);

            await expect(incidentService.createIncident(data, 'reporter-1'))
                .rejects.toThrow('ไม่พบผู้ใช้ที่ถูกรายงาน');
        });

        it('ควรแจ้ง error 400 ถ้ารายงานตัวเอง', async () => {
            const data = { reportedUserId: 'reporter-1', type: 'HARASSMENT' };
            prisma.user.findUnique.mockResolvedValue({ id: 'reporter-1' });

            await expect(incidentService.createIncident(data, 'reporter-1'))
                .rejects.toThrow('ไม่สามารถรายงานตัวเองได้');
        });
    });

    describe('getMyIncidents (ดึงรายงานของฉัน)', () => {
        it('ควรคืนค่ารายการเหตุการณ์สำหรับผู้ใช้', async () => {
            const userId = 'user-1';
            const mockIncidents = [{ id: 'inc-1', title: 'Test' }];
            prisma.incident.findMany.mockResolvedValue(mockIncidents);

            const result = await incidentService.getMyIncidents(userId);

            expect(result).toEqual(mockIncidents);
            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: {
                    OR: [
                        { reporterId: userId },
                        { reportedUserId: userId },
                    ]
                }
            }));
        });
    });

    describe('getIncidentById (ดึงรายงานตาม ID)', () => {
        it('ควรคืนค่ารายงานเหตุการณ์ตาม ID', async () => {
            const id = 'inc-1';
            const mockIncident = { id, title: 'Test' };
            prisma.incident.findUnique.mockResolvedValue(mockIncident);

            const result = await incidentService.getIncidentById(id);

            expect(result).toEqual(mockIncident);
            expect(prisma.incident.findUnique).toHaveBeenCalledWith(expect.objectContaining({ where: { id } }));
        });
    });

    describe('searchIncidentsAdmin (ค้นหาสำหรับ Admin)', () => {
        it('ควรคืนค่ารายการเหตุการณ์แบบแบ่งหน้าพร้อมคำค้นหา', async () => {
            const opts = { q: 'test', status: 'PENDING', page: 1, limit: 10 };
            const mockData = [{ id: 'inc-1', title: 'Test Incident' }];
            const mockTotal = 1;

            prisma.incident.count.mockResolvedValue(mockTotal);
            prisma.incident.findMany.mockResolvedValue(mockData);

            const result = await incidentService.searchIncidentsAdmin(opts);

            expect(result.data).toEqual(mockData);
            expect(result.pagination.total).toBe(mockTotal);
            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: expect.objectContaining({
                    status: 'PENDING',
                    OR: expect.arrayContaining([
                        { title: { contains: 'test', mode: 'insensitive' } }
                    ])
                })
            }));
        });
    });

    describe('updateIncidentStatus (อัปเดตสถานะ)', () => {
        it('ควรอัปเดตสถานะและส่งแจ้งเตือนเมื่อ Admin อัปเดต', async () => {
            const mockIncidentId = 'incident-123';
            const mockAdminId = 'admin-123';
            const mockData = { status: 'INVESTIGATING', priority: 'HIGH' };
            
            const existingIncident = {
                id: mockIncidentId,
                title: 'Test Incident',
                reporterId: 'reporter-123',
                status: 'PENDING'
            };

            const updatedIncident = {
                ...existingIncident,
                status: 'INVESTIGATING',
                priority: 'HIGH'
            };

            prisma.incident.findUnique.mockResolvedValue(existingIncident);
            prisma.incident.update.mockResolvedValue(updatedIncident);
            notificationService.createNotificationByAdmin.mockResolvedValue(true);

            const result = await incidentService.updateIncidentStatus(mockIncidentId, mockData, mockAdminId);

            expect(prisma.incident.update).toHaveBeenCalledWith(expect.objectContaining({
                where: { id: mockIncidentId },
                data: expect.objectContaining({
                    status: 'INVESTIGATING',
                    priority: 'HIGH'
                })
            }));

            expect(notificationService.createNotificationByAdmin).toHaveBeenCalledWith(expect.objectContaining({
                userId: 'reporter-123',
                metadata: { incidentId: mockIncidentId, status: 'INVESTIGATING' }
            }));

            expect(result).toEqual(updatedIncident);
        });

        it('ควรแจ้ง error 404 ถ้าไม่พบรายงานเหตุการณ์', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            await expect(incidentService.updateIncidentStatus('non-existent', {}, 'admin'))
                .rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });
    });

    describe('deleteIncident (ลบรายงาน)', () => {
        it('ควรลบรายงานเหตุการณ์สำเร็จ', async () => {
            const id = 'inc-1';
            prisma.incident.findUnique.mockResolvedValue({ id });
            prisma.incident.delete.mockResolvedValue({ id });

            const result = await incidentService.deleteIncident(id);

            expect(result.message).toBe('ลบรายงานเหตุการณ์สำเร็จ');
            expect(prisma.incident.delete).toHaveBeenCalledWith({ where: { id } });
        });

        it('ควรแจ้ง error 404 ถ้าไม่พบรายงานเหตุการณ์', async () => {
             prisma.incident.findUnique.mockResolvedValue(null);
             await expect(incidentService.deleteIncident('inc-1')).rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });
    });
});

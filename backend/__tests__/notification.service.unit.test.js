const notificationService = require('../src/services/notification.service');
const prisma = require('../src/utils/prisma');
const ApiError = require('../src/utils/ApiError');

// Mock Prisma
jest.mock('../src/utils/prisma', () => ({
    notification: {
        create: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
        delete: jest.fn(),
    },
    user: {
        findUnique: jest.fn(),
    },
    $transaction: jest.fn((promises) => Promise.all(promises)),
}));

describe('การทดสอบ Unit Test ของ Notification Service', () => {
    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('createNotificationByAdmin (สร้างการแจ้งเตือนโดย Admin)', () => {
        it('ควรสร้างการแจ้งเตือนสำเร็จ', async () => {
            const payload = {
                userId: 'user-1',
                type: 'INCIDENT',
                title: 'Test',
                body: 'Body'
            };

            prisma.user.findUnique.mockResolvedValue({ id: 'user-1' });
            prisma.notification.create.mockResolvedValue({ ...payload, id: 'notif-1' });

            const result = await notificationService.createNotificationByAdmin(payload);

            expect(prisma.user.findUnique).toHaveBeenCalledWith({ where: { id: 'user-1' }, select: { id: true } });
            expect(prisma.notification.create).toHaveBeenCalledWith({
                data: payload,
                select: expect.any(Object)
            });
            expect(result).toHaveProperty('id', 'notif-1');
        });

        it('ควรแจ้ง error 404 ถ้าไม่พบผู้ใช้', async () => {
            prisma.user.findUnique.mockResolvedValue(null);

            await expect(notificationService.createNotificationByAdmin({ userId: 'user-99' }))
                .rejects.toThrow(ApiError);
        });
    });

    describe('listMyNotifications (ดึงการแจ้งเตือนของฉัน)', () => {
        it('ควรคืนค่ารายการแจ้งเตือน', async () => {
            const userId = 'user-1';
            const mockData = [{ id: 'n1', title: 'Test' }];
            const mockTotal = 1;

            prisma.notification.count.mockResolvedValue(mockTotal);
            prisma.notification.findMany.mockResolvedValue(mockData);

            const result = await notificationService.listMyNotifications(userId, { page: 1, limit: 10 });

            expect(result.data).toEqual(mockData);
            expect(result.pagination.total).toBe(mockTotal);
            expect(prisma.notification.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: expect.objectContaining({ userId }),
                take: 10,
                skip: 0
            }));
        });
    });

    describe('markRead (อ่านการแจ้งเตือน)', () => {
        it('ควรอัปเดตว่าอ่านแล้ว', async () => {
            const notifId = 'n1';
            const userId = 'user-1';
            const mockNotif = { id: notifId, userId };

            prisma.notification.findUnique.mockResolvedValue(mockNotif);
            prisma.notification.update.mockResolvedValue({ ...mockNotif, readAt: new Date() });

            await notificationService.markRead(notifId, userId);

            expect(prisma.notification.update).toHaveBeenCalledWith(expect.objectContaining({
                where: { id: notifId },
                data: { readAt: expect.any(Date) }
            }));
        });

        it('ควรแจ้ง error 404 ถ้าไม่พบการแจ้งเตือนหรือไม่ได้เป็นเจ้าของ', async () => {
            prisma.notification.findUnique.mockResolvedValue(null);
            await expect(notificationService.markRead('n1', 'u1')).rejects.toThrow(ApiError);

            prisma.notification.findUnique.mockResolvedValue({ id: 'n1', userId: 'other' });
            await expect(notificationService.markRead('n1', 'u1')).rejects.toThrow(ApiError);
        });
    });

    describe('countUnread (นับจำนวนที่ยังไม่อ่าน)', () => {
        it('ควรคืนค่าจำนวนที่ยังไม่อ่าน', async () => {
            const userId = 'user-1';
            prisma.notification.count.mockResolvedValue(5);

            const result = await notificationService.countUnread(userId);

            expect(result.unread).toBe(5);
            expect(prisma.notification.count).toHaveBeenCalledWith({
                where: { userId, readAt: null }
            });
        });
    });

    describe('deleteMyNotification (ลบการแจ้งเตือนของฉัน)', () => {
        it('ควรลบการแจ้งเตือน', async () => {
             const notifId = 'n1';
            const userId = 'user-1';
            const mockNotif = { id: notifId, userId };

            prisma.notification.findUnique.mockResolvedValue(mockNotif);
            prisma.notification.delete.mockResolvedValue(mockNotif);

            await notificationService.deleteMyNotification(notifId, userId);

            expect(prisma.notification.delete).toHaveBeenCalledWith({ where: { id: notifId } });
        });
    });
});

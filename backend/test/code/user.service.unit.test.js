const userService = require('../../src/services/user.service');
const prisma = require('../../src/utils/prisma');
const ApiError = require('../../src/utils/ApiError');

// mock prisma
jest.mock('../../src/utils/prisma', () => ({
    user: {
        findUnique: jest.fn(),
        update: jest.fn()
    },
    booking: {
        findFirst: jest.fn()
    },
    route: {
        findFirst: jest.fn()
    },
    incident: {
        findFirst: jest.fn()
    }
}));

describe('การทดสอบ Unit Test ของ User Service (Delete Account)', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('Passenger Delete Account', () => {
        it('Passenger ควรลบบัญชีสำเร็จ เมื่อไม่มี booking และ incident', async () => {

            const userId = 'passenger-1';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'PASSENGER',
                deletedAt: null
            });

            prisma.booking.findFirst.mockResolvedValue(null);
            prisma.incident.findFirst.mockResolvedValue(null);

            prisma.user.update.mockResolvedValue({
                id: userId,
                deletedAt: new Date(),
                isActive: false
            });

            const result = await userService.deleteCurrentUser(userId);

            expect(prisma.user.update).toHaveBeenCalledWith({
                where: { id: userId },
                data: {
                    deletedAt: expect.any(Date),
                    isActive: false
                }
            });

            expect(result.isActive).toBe(false);

        });

        it('Passenger ไม่ควรลบบัญชีได้ เมื่อมี active booking', async () => {

            const userId = 'passenger-2';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'PASSENGER',
                deletedAt: null
            });

            prisma.booking.findFirst.mockResolvedValue({
                id: 'booking-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId)
            ).rejects.toThrow(
                'You cannot delete account while having active bookings.'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

        it('Passenger ไม่ควรลบบัญชีได้ เมื่อมี incident ที่ยังไม่ปิด', async () => {

            const userId = 'passenger-3';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'PASSENGER',
                deletedAt: null
            });

            prisma.booking.findFirst.mockResolvedValue(null);

            prisma.incident.findFirst.mockResolvedValue({
                id: 'incident-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId)
            ).rejects.toThrow(
                'You cannot delete account while having open incident cases.'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

    });

    describe('Driver Delete Account', () => {
                it('Driver ควรลบบัญชีสำเร็จ เมื่อไม่มี route booking และ incident', async () => {

            const userId = 'driver-4';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'DRIVER',
                deletedAt: null
            });

            prisma.route.findFirst.mockResolvedValue(null);

            prisma.booking.findFirst.mockResolvedValue(null);

            prisma.incident.findFirst.mockResolvedValue(null);

            prisma.user.update.mockResolvedValue({
                id: userId,
                deletedAt: new Date(),
                isActive: false
            });

            const result = await userService.deleteCurrentUser(userId);

            expect(prisma.user.update).toHaveBeenCalledWith({
                where: { id: userId },
                data: {
                    deletedAt: expect.any(Date),
                    isActive: false
                }
            });

            expect(result.isActive).toBe(false);

        });
        
        it('Driver ไม่ควรลบบัญชีได้ เมื่อมี active route', async () => {

            const userId = 'driver-1';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'DRIVER',
                deletedAt: null
            });

            prisma.route.findFirst.mockResolvedValue({
                id: 'route-1',
                status: 'AVAILABLE'
            });

            await expect(
                userService.deleteCurrentUser(userId)
            ).rejects.toThrow(
                'You cannot delete account while having active routes.'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

        it('Driver ไม่ควรลบบัญชีได้ เมื่อมี booking active บน route ของตน', async () => {

            const userId = 'driver-2';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'DRIVER',
                deletedAt: null
            });

            prisma.route.findFirst.mockResolvedValue(null);

            prisma.booking.findFirst.mockResolvedValue({
                id: 'booking-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId)
            ).rejects.toThrow(
                'You cannot delete account while having active bookings on their routes.'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

        it('Driver ไม่ควรลบบัญชีได้ เมื่อมี incident ที่ยังไม่ปิด', async () => {

            const userId = 'driver-3';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'DRIVER',
                deletedAt: null
            });

            prisma.route.findFirst.mockResolvedValue(null);

            prisma.booking.findFirst.mockResolvedValue(null);

            prisma.incident.findFirst.mockResolvedValue({
                id: 'incident-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId)
            ).rejects.toThrow(
                'You cannot delete account while having open incident cases.'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

    });

});
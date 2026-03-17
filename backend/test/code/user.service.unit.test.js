const userService = require('../../src/services/user.service');
const prisma = require('../../src/utils/prisma');
const ApiError = require('../../src/utils/ApiError');
const bcrypt = require('bcrypt');

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

// mock bcrypt
jest.mock('bcrypt', () => ({
    compare: jest.fn()
}));

const CORRECT_PASSWORD = '123456789Test';
const WRONG_PASSWORD = 'WrongPassword123';
const HASHED_PASSWORD = '$2b$10$hashedpassword';

describe('การทดสอบ Unit Test ของ User Service (Delete Account)', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('Password Validation', () => {
        it('ควร throw error เมื่อไม่ส่ง password มา', async () => {
            const userId = 'passenger-0';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'PASSENGER',
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            await expect(
                userService.deleteCurrentUser(userId, '')
            ).rejects.toThrow('กรุณากรอกรหัสผ่าน');

            expect(prisma.user.update).not.toHaveBeenCalled();
        });

        it('ควร throw error เมื่อ password ไม่ถูกต้อง', async () => {
            const userId = 'passenger-0b';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'PASSENGER',
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(false);

            await expect(
                userService.deleteCurrentUser(userId, WRONG_PASSWORD)
            ).rejects.toThrow('รหัสผ่านไม่ถูกต้อง');

            expect(prisma.user.update).not.toHaveBeenCalled();
        });
    });

    describe('Passenger Delete Account', () => {
        it('Passenger ควรลบบัญชีสำเร็จ เมื่อไม่มี booking และ incident', async () => {

            const userId = 'passenger-1';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'PASSENGER',
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.booking.findFirst.mockResolvedValue(null);
            prisma.incident.findFirst.mockResolvedValue(null);

            prisma.user.update.mockResolvedValue({
                id: userId,
                deletedAt: new Date(),
                isActive: false
            });

            const result = await userService.deleteCurrentUser(userId, CORRECT_PASSWORD);

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
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.booking.findFirst.mockResolvedValue({
                id: 'booking-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId, CORRECT_PASSWORD)
            ).rejects.toThrow(
                'ไม่สามารถลบบัญชีได้ เนื่องจากคุณยังมีการจองที่ยังไม่เสร็จสิ้นอยู่'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

        it('Passenger ไม่ควรลบบัญชีได้ เมื่อมี incident ที่ยังไม่ปิด', async () => {

            const userId = 'passenger-3';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'PASSENGER',
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.booking.findFirst.mockResolvedValue(null);

            prisma.incident.findFirst.mockResolvedValue({
                id: 'incident-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId, CORRECT_PASSWORD)
            ).rejects.toThrow(
                'ไม่สามารถลบบัญชีได้ เนื่องจากคุณยังมีเคสเหตุการณ์ที่ยังไม่ปิดอยู่'
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
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.route.findFirst.mockResolvedValue(null);
            prisma.booking.findFirst.mockResolvedValue(null);
            prisma.incident.findFirst.mockResolvedValue(null);

            prisma.user.update.mockResolvedValue({
                id: userId,
                deletedAt: new Date(),
                isActive: false
            });

            const result = await userService.deleteCurrentUser(userId, CORRECT_PASSWORD);

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
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.route.findFirst.mockResolvedValue({
                id: 'route-1',
                status: 'AVAILABLE'
            });

            await expect(
                userService.deleteCurrentUser(userId, CORRECT_PASSWORD)
            ).rejects.toThrow(
                'ไม่สามารถลบบัญชีได้ เนื่องจากคุณยังมีเส้นทางเดินรถที่กำลังเปิดใช้งานอยู่'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

        it('Driver ไม่ควรลบบัญชีได้ เมื่อมี booking active บน route ของตน', async () => {

            const userId = 'driver-2';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'DRIVER',
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.route.findFirst.mockResolvedValue(null);

            prisma.booking.findFirst.mockResolvedValue({
                id: 'booking-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId, CORRECT_PASSWORD)
            ).rejects.toThrow(
                'ไม่สามารถลบบัญชีได้ เนื่องจากยังมีการจองบนเส้นทางเดินรถของคุณที่ยังไม่เสร็จสิ้นอยู่'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

        it('Driver ไม่ควรถูก block โดย booking บน route ที่ COMPLETED แล้ว แต่ควร block โดย incident ที่ยังเปิดอยู่', async () => {

            const userId = 'driver-5';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'DRIVER',
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.route.findFirst.mockResolvedValue(null);
            prisma.booking.findFirst.mockResolvedValue(null); // route COMPLETED แล้ว booking ไม่ควรถูกนับ

            prisma.incident.findFirst.mockResolvedValue({
                id: 'incident-2',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId, CORRECT_PASSWORD)
            ).rejects.toThrow(
                'ไม่สามารถลบบัญชีได้ เนื่องจากคุณยังมีเคสเหตุการณ์ที่ยังไม่ปิดอยู่'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

        it('Driver ไม่ควรลบบัญชีได้ เมื่อมี incident ที่ยังไม่ปิด', async () => {

            const userId = 'driver-3';

            prisma.user.findUnique.mockResolvedValue({
                id: userId,
                role: 'DRIVER',
                password: HASHED_PASSWORD,
                deletedAt: null
            });

            bcrypt.compare.mockResolvedValue(true);
            prisma.route.findFirst.mockResolvedValue(null);
            prisma.booking.findFirst.mockResolvedValue(null);

            prisma.incident.findFirst.mockResolvedValue({
                id: 'incident-1',
                status: 'PENDING'
            });

            await expect(
                userService.deleteCurrentUser(userId, CORRECT_PASSWORD)
            ).rejects.toThrow(
                'ไม่สามารถลบบัญชีได้ เนื่องจากคุณยังมีเคสเหตุการณ์ที่ยังไม่ปิดอยู่'
            );

            expect(prisma.user.update).not.toHaveBeenCalled();

        });

    });

});
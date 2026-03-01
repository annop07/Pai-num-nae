const incidentService = require('../../src/services/incident.service');
const prisma = require('../../src/utils/prisma');
const notificationService = require('../../src/services/notification.service');

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
const DRIVER_ID = 'driver-001';
const PASSENGER_ID = 'passenger-001';
const ROUTE_ID = 'route-001';
const BOOKING_ID = 'booking-001';

const mockBooking = {
    id: BOOKING_ID,
    routeId: ROUTE_ID,
    passengerId: PASSENGER_ID,
    route: { driverId: DRIVER_ID },
};

const mockRoute = { id: ROUTE_ID };
const mockDriverUser = { id: DRIVER_ID, username: 'TestDriver_UAT' };

// ============================================================
// Passenger Incident Tests
// ============================================================
describe('Unit Test: Passenger รายงานเหตุการณ์ (Incident)', () => {
    beforeEach(() => {
        // Mock findMany ให้คืน array ว่าง เพื่อไม่ให้ notifyAdminsNewIncident error
        prisma.user.findMany.mockResolvedValue([]);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    // ----------------------------------------------------------
    // createIncident — Passenger ผ่าน bookingId
    // ----------------------------------------------------------
    describe('createIncident — Passenger รายงานผ่าน bookingId', () => {
        it('ควร auto-resolve routeId และ reportedUserId เป็นคนขับ เมื่อ Passenger รายงานผ่าน bookingId', async () => {
            const data = {
                bookingId: BOOKING_ID,
                type: 'SAFETY_CONCERN',
                title: 'คนขับขับรถเร็วเกินไป',
                description: 'คนขับขับรถเร็วเกิน 120 กม/ชม ในเขตเมือง',
            };

            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(mockRoute);
            prisma.user.findUnique.mockResolvedValue(mockDriverUser);
            prisma.incident.create.mockResolvedValue({
                id: 'inc-psg-1',
                ...data,
                reporterId: PASSENGER_ID,
                reportedUserId: DRIVER_ID,
                routeId: ROUTE_ID,
                status: 'PENDING',
                priority: 'NORMAL',
                reporter: { id: PASSENGER_ID },
            });

            const result = await incidentService.createIncident(data, PASSENGER_ID);

            // ตรวจสอบว่าดึง booking มาถูกต้อง
            expect(prisma.booking.findUnique).toHaveBeenCalledWith({
                where: { id: BOOKING_ID },
                select: {
                    id: true,
                    routeId: true,
                    passengerId: true,
                    route: { select: { driverId: true } },
                },
            });

            // ตรวจสอบว่า reportedUserId ถูก resolve เป็นคนขับ
            expect(prisma.user.findUnique).toHaveBeenCalledWith({ where: { id: DRIVER_ID } });

            // ตรวจสอบว่าสร้าง incident ด้วยข้อมูลที่ถูกต้อง
            expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                data: expect.objectContaining({
                    reporterId: PASSENGER_ID,
                    reportedUserId: DRIVER_ID,
                    routeId: ROUTE_ID,
                    bookingId: BOOKING_ID,
                    type: 'SAFETY_CONCERN',
                }),
            }));

            expect(result.id).toBe('inc-psg-1');
            expect(result.reportedUserId).toBe(DRIVER_ID);
        });

        it('ควรแจ้ง 404 เมื่อ bookingId ที่ส่งมาไม่พบ', async () => {
            prisma.booking.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.createIncident(
                    { bookingId: 'non-existent', type: 'HARASSMENT', title: 'test', description: 'desc' },
                    PASSENGER_ID
                )
            ).rejects.toThrow('ไม่พบการจอง');
        });

        it('ควรแจ้ง 404 เมื่อ routeId ที่ resolve จาก booking ไม่พบ', async () => {
            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.createIncident(
                    { bookingId: BOOKING_ID, type: 'SAFETY_CONCERN', title: 'test', description: 'desc' },
                    PASSENGER_ID
                )
            ).rejects.toThrow('ไม่พบเส้นทาง');
        });

        it('ควรสร้างสำเร็จพร้อม priority HIGH, location, evidenceUrls', async () => {
            const data = {
                bookingId: BOOKING_ID,
                type: 'HARASSMENT',
                priority: 'HIGH',
                title: 'คนขับมีพฤติกรรมไม่เหมาะสม',
                description: 'คนขับใช้คำพูดคุกคามระหว่างเดินทาง',
                location: { lat: 13.7563, lng: 100.5018 },
                evidenceUrls: ['https://example.com/evidence1.jpg', 'https://example.com/evidence2.jpg'],
            };

            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(mockRoute);
            prisma.user.findUnique.mockResolvedValue(mockDriverUser);
            prisma.incident.create.mockResolvedValue({
                id: 'inc-psg-2',
                ...data,
                reporterId: PASSENGER_ID,
                reportedUserId: DRIVER_ID,
                routeId: ROUTE_ID,
                status: 'PENDING',
                reporter: { id: PASSENGER_ID },
            });

            const result = await incidentService.createIncident(data, PASSENGER_ID);

            expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                data: expect.objectContaining({
                    priority: 'HIGH',
                    location: { lat: 13.7563, lng: 100.5018 },
                    evidenceUrls: ['https://example.com/evidence1.jpg', 'https://example.com/evidence2.jpg'],
                }),
            }));

            expect(result.priority).toBe('HIGH');
        });

        it('ควรใช้ default priority เป็น NORMAL เมื่อไม่ส่ง priority', async () => {
            const data = {
                bookingId: BOOKING_ID,
                type: 'NO_SHOW_DRIVER',
                title: 'คนขับไม่มาตามนัด',
                description: 'รอ 30 นาทีแล้วคนขับยังไม่มารับ',
            };

            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(mockRoute);
            prisma.user.findUnique.mockResolvedValue(mockDriverUser);
            prisma.incident.create.mockResolvedValue({
                id: 'inc-psg-3',
                ...data,
                reporterId: PASSENGER_ID,
                priority: 'NORMAL',
                status: 'PENDING',
                reporter: { id: PASSENGER_ID },
            });

            await incidentService.createIncident(data, PASSENGER_ID);

            expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                data: expect.objectContaining({
                    priority: 'NORMAL',
                }),
            }));
        });

        it('ควรสร้างสำเร็จโดยไม่ส่ง bookingId (รายงานทั่วไปจาก Passenger)', async () => {
            const data = {
                type: 'LOST_ITEM',
                title: 'ลืมของในรถ',
                description: 'ลืมกระเป๋าไว้ในรถ',
            };

            prisma.incident.create.mockResolvedValue({
                id: 'inc-psg-4',
                ...data,
                reporterId: PASSENGER_ID,
                reportedUserId: null,
                routeId: null,
                bookingId: null,
                status: 'PENDING',
                priority: 'NORMAL',
                reporter: { id: PASSENGER_ID },
            });

            const result = await incidentService.createIncident(data, PASSENGER_ID);

            expect(prisma.booking.findUnique).not.toHaveBeenCalled();
            expect(result.bookingId).toBeNull();
            expect(result.reportedUserId).toBeNull();
        });

        it('ควรแจ้ง 404 ถ้า reportedUserId (คนขับ) ที่ resolve ได้ไม่พบในระบบ', async () => {
            const bookingWithMissingDriver = {
                id: BOOKING_ID,
                routeId: ROUTE_ID,
                passengerId: PASSENGER_ID,
                route: { driverId: 'deleted-driver' },
            };

            prisma.booking.findUnique.mockResolvedValue(bookingWithMissingDriver);
            prisma.route.findUnique.mockResolvedValue(mockRoute);
            prisma.user.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.createIncident(
                    { bookingId: BOOKING_ID, type: 'LICENSE_PLATE_MISMATCH', title: 'ทะเบียนไม่ตรง', description: 'desc' },
                    PASSENGER_ID
                )
            ).rejects.toThrow('ไม่พบผู้ใช้ที่ถูกรายงาน');
        });

        it('ควรรองรับ IncidentType ทุกประเภทที่ Passenger อาจรายงาน', async () => {
            const passengerTypes = [
                'SAFETY_CONCERN',
                'HARASSMENT',
                'NO_SHOW_DRIVER',
                'LICENSE_PLATE_MISMATCH',
                'VEHICLE_ISSUE',
                'LOST_ITEM',
            ];

            for (const type of passengerTypes) {
                jest.clearAllMocks();

                const data = {
                    bookingId: BOOKING_ID,
                    type,
                    title: `ทดสอบ ${type}`,
                    description: `รายละเอียด ${type}`,
                };

                prisma.booking.findUnique.mockResolvedValue(mockBooking);
                prisma.route.findUnique.mockResolvedValue(mockRoute);
                prisma.user.findUnique.mockResolvedValue(mockDriverUser);
                prisma.incident.create.mockResolvedValue({
                    id: `inc-type-${type}`,
                    ...data,
                    reporterId: PASSENGER_ID,
                    reportedUserId: DRIVER_ID,
                    routeId: ROUTE_ID,
                    status: 'PENDING',
                    reporter: { id: PASSENGER_ID },
                });

                const result = await incidentService.createIncident(data, PASSENGER_ID);

                expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                    data: expect.objectContaining({ type }),
                }));
                expect(result.id).toBe(`inc-type-${type}`);
            }
        });
    });

    // ----------------------------------------------------------
    // getMyIncidents — Passenger
    // ----------------------------------------------------------
    describe('getMyIncidents — Passenger ดูรายงานของตัวเอง', () => {
        it('ควรคืนค่ารายการ incident ที่ Passenger เป็นผู้รายงานหรือถูกรายงาน', async () => {
            const mockIncidents = [
                { id: 'inc-1', title: 'รายงาน 1', reporterId: PASSENGER_ID },
                { id: 'inc-2', title: 'ถูกรายงาน', reportedUserId: PASSENGER_ID },
            ];

            prisma.incident.findMany.mockResolvedValue(mockIncidents);

            const result = await incidentService.getMyIncidents(PASSENGER_ID);

            expect(result).toEqual(mockIncidents);
            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: {
                    OR: [
                        { reporterId: PASSENGER_ID },
                        { reportedUserId: PASSENGER_ID },
                    ],
                    isArchived: false,
                },
                orderBy: { createdAt: 'desc' },
            }));
        });

        it('ควรคืนค่า array ว่างเมื่อไม่มี incident', async () => {
            prisma.incident.findMany.mockResolvedValue([]);

            const result = await incidentService.getMyIncidents(PASSENGER_ID);

            expect(result).toEqual([]);
        });
    });

    // ----------------------------------------------------------
    // getIncidentById — Passenger
    // ----------------------------------------------------------
    describe('getIncidentById — Passenger ดูรายละเอียด', () => {
        it('ควรคืนค่ารายงานตาม ID ที่ Passenger เป็นผู้รายงาน', async () => {
            const mockIncident = {
                id: 'inc-1',
                reporterId: PASSENGER_ID,
                title: 'คนขับขับรถเร็ว',
            };

            prisma.incident.findUnique.mockResolvedValue(mockIncident);

            const result = await incidentService.getIncidentById('inc-1');

            expect(result).toEqual(mockIncident);
            expect(prisma.incident.findUnique).toHaveBeenCalledWith(expect.objectContaining({
                where: { id: 'inc-1' },
            }));
        });

        it('ควรคืน null ถ้าไม่พบ incident', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            const result = await incidentService.getIncidentById('non-existent');

            expect(result).toBeNull();
        });
    });

    // ----------------------------------------------------------
    // getIncidentLogs — Passenger (reporter)
    // ----------------------------------------------------------
    describe('getIncidentLogs — Passenger ดู Log ในฐานะผู้รายงาน', () => {
        it('ควรคืน logs สำหรับ Passenger ที่เป็น reporter', async () => {
            const mockIncident = { id: 'inc-1', reporterId: PASSENGER_ID };
            const mockLogs = [
                { id: 'log-1', incidentId: 'inc-1', fromStatus: null, toStatus: 'PENDING' },
                { id: 'log-2', incidentId: 'inc-1', fromStatus: 'PENDING', toStatus: 'INVESTIGATING' },
                { id: 'log-3', incidentId: 'inc-1', fromStatus: 'INVESTIGATING', toStatus: 'RESOLVED' },
            ];

            prisma.incident.findUnique.mockResolvedValue(mockIncident);
            prisma.incidentStatusLog.findMany.mockResolvedValue(mockLogs);

            const result = await incidentService.getIncidentLogs('inc-1', PASSENGER_ID, 'PASSENGER');

            expect(result).toEqual(mockLogs);
            expect(result).toHaveLength(3);
            expect(prisma.incidentStatusLog.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: { incidentId: 'inc-1' },
                orderBy: { createdAt: 'asc' },
            }));
        });

        it('ควรแจ้ง 403 ถ้า Passenger ไม่ใช่ reporter ของ incident นี้', async () => {
            const mockIncident = { id: 'inc-1', reporterId: 'other-user' };
            prisma.incident.findUnique.mockResolvedValue(mockIncident);

            await expect(
                incidentService.getIncidentLogs('inc-1', PASSENGER_ID, 'PASSENGER')
            ).rejects.toThrow('ไม่มีสิทธิ์ดู log นี้');
        });

        it('ควรแจ้ง 404 ถ้า incident ไม่พบ', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.getIncidentLogs('non-existent', PASSENGER_ID, 'PASSENGER')
            ).rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });
    });
});

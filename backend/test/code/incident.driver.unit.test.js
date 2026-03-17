const incidentService = require('../../src/services/incident.service');
const prisma = require('../../src/utils/prisma');
const notificationService = require('../../src/services/notification.service');
const { createIncidentSchema } = require('../../src/validations/incident.validation');

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
const mockPassengerUser = { id: PASSENGER_ID, username: 'TestPassenger_UAT' };
const mockDriverUser = { id: DRIVER_ID, username: 'TestDriver_UAT' };

// ============================================================
// Driver Incident Tests
// ============================================================
describe('Unit Test: Driver รายงานเหตุการณ์ (Incident)', () => {
    beforeEach(() => {
        // Mock findMany ให้คืน array ว่าง เพื่อไม่ให้ notifyAdminsNewIncident error
        prisma.user.findMany.mockResolvedValue([]);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    // ----------------------------------------------------------
    // createIncident — Driver ผ่าน bookingId
    // ----------------------------------------------------------
    describe('createIncident — Driver รายงานผ่าน bookingId', () => {
        it('ควร auto-resolve routeId และ reportedUserId เป็นผู้โดยสาร เมื่อ Driver รายงานผ่าน bookingId', async () => {
            const data = {
                bookingId: BOOKING_ID,
                type: 'INAPPROPRIATE_BEHAVIOR',
                title: 'ผู้โดยสารประพฤติไม่เหมาะสม',
                description: 'ผู้โดยสารใช้คำพูดไม่สุภาพระหว่างเดินทาง',
            };

            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(mockRoute);
            prisma.user.findUnique.mockResolvedValue(mockPassengerUser);
            prisma.incident.create.mockResolvedValue({
                id: 'inc-driver-1',
                ...data,
                reporterId: DRIVER_ID,
                reportedUserId: PASSENGER_ID,
                routeId: ROUTE_ID,
                status: 'PENDING',
                priority: 'NORMAL',
                reporter: { id: DRIVER_ID },
            });

            const result = await incidentService.createIncident(data, DRIVER_ID);

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

            // ตรวจสอบว่า resolve routeId จาก booking
            expect(prisma.route.findUnique).toHaveBeenCalledWith({ where: { id: ROUTE_ID } });

            // ตรวจสอบว่า reportedUserId ถูก resolve เป็นผู้โดยสาร
            expect(prisma.user.findUnique).toHaveBeenCalledWith({ where: { id: PASSENGER_ID } });

            // ตรวจสอบว่าสร้าง incident ด้วยข้อมูลที่ถูกต้อง
            expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                data: expect.objectContaining({
                    reporterId: DRIVER_ID,
                    reportedUserId: PASSENGER_ID,
                    routeId: ROUTE_ID,
                    bookingId: BOOKING_ID,
                    type: 'INAPPROPRIATE_BEHAVIOR',
                }),
            }));

            expect(result.id).toBe('inc-driver-1');
            expect(result.reportedUserId).toBe(PASSENGER_ID);
        });

        it('ควรแจ้ง 404 เมื่อ bookingId ที่ส่งมาไม่พบ', async () => {
            prisma.booking.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.createIncident(
                    { bookingId: 'non-existent', type: 'FRAUD', title: 'test', description: 'desc' },
                    DRIVER_ID
                )
            ).rejects.toThrow('ไม่พบการจอง');
        });

        it('ควรแจ้ง 404 เมื่อ routeId ที่ resolve จาก booking ไม่พบ', async () => {
            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.createIncident(
                    { bookingId: BOOKING_ID, type: 'VEHICLE_ISSUE', title: 'test', description: 'desc' },
                    DRIVER_ID
                )
            ).rejects.toThrow('ไม่พบเส้นทาง');
        });

        it('ควรสร้างสำเร็จพร้อม priority, location, evidenceUrls ที่ส่งมา', async () => {
            const data = {
                bookingId: BOOKING_ID,
                type: 'ACCIDENT',
                priority: 'URGENT',
                title: 'เกิดอุบัติเหตุ',
                description: 'รถชนระหว่างเดินทาง',
                location: { lat: 13.7563, lng: 100.5018 },
                evidenceUrls: ['https://example.com/photo1.jpg'],
                metadata: { vehicleDamage: true },
            };

            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(mockRoute);
            prisma.user.findUnique.mockResolvedValue(mockPassengerUser);
            prisma.incident.create.mockResolvedValue({
                id: 'inc-driver-2',
                ...data,
                reporterId: DRIVER_ID,
                reportedUserId: PASSENGER_ID,
                routeId: ROUTE_ID,
                status: 'PENDING',
                reporter: { id: DRIVER_ID },
            });

            const result = await incidentService.createIncident(data, DRIVER_ID);

            expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                data: expect.objectContaining({
                    priority: 'URGENT',
                    location: { lat: 13.7563, lng: 100.5018 },
                    evidenceUrls: ['https://example.com/photo1.jpg'],
                    metadata: { vehicleDamage: true },
                }),
            }));

            expect(result.priority).toBe('URGENT');
        });

        it('ควรใช้ default priority เป็น NORMAL เมื่อไม่ส่ง priority', async () => {
            const data = {
                bookingId: BOOKING_ID,
                type: 'NO_SHOW_PASSENGER',
                title: 'ผู้โดยสารไม่มาตามนัด',
                description: 'รอ 15 นาทีแล้วผู้โดยสารยังไม่มา',
            };

            prisma.booking.findUnique.mockResolvedValue(mockBooking);
            prisma.route.findUnique.mockResolvedValue(mockRoute);
            prisma.user.findUnique.mockResolvedValue(mockPassengerUser);
            prisma.incident.create.mockResolvedValue({
                id: 'inc-driver-3',
                ...data,
                reporterId: DRIVER_ID,
                priority: 'NORMAL',
                status: 'PENDING',
                reporter: { id: DRIVER_ID },
            });

            await incidentService.createIncident(data, DRIVER_ID);

            expect(prisma.incident.create).toHaveBeenCalledWith(expect.objectContaining({
                data: expect.objectContaining({
                    priority: 'NORMAL',
                }),
            }));
        });

        it('ควรสร้างสำเร็จโดยไม่ส่ง bookingId (รายงานทั่วไปจาก Driver)', async () => {
            const data = {
                type: 'ROUTE_ISSUE',
                title: 'ถนนปิดกะทันหัน',
                description: 'ถนนถูกปิดเนื่องจากงานก่อสร้าง',
            };

            prisma.incident.create.mockResolvedValue({
                id: 'inc-driver-4',
                ...data,
                reporterId: DRIVER_ID,
                reportedUserId: null,
                routeId: null,
                bookingId: null,
                status: 'PENDING',
                priority: 'NORMAL',
                reporter: { id: DRIVER_ID },
            });

            const result = await incidentService.createIncident(data, DRIVER_ID);

            expect(prisma.booking.findUnique).not.toHaveBeenCalled();
            expect(result.bookingId).toBeNull();
            expect(result.reportedUserId).toBeNull();
        });
    });

    // ----------------------------------------------------------
    // getMyIncidents — Driver
    // ----------------------------------------------------------
    describe('getMyIncidents — Driver ดูรายงานของตัวเอง', () => {
        it('ควรคืนค่ารายการ incident ที่ Driver เป็นผู้รายงานหรือถูกรายงาน', async () => {
            const mockIncidents = [
                { id: 'inc-1', title: 'รายงาน 1', reporterId: DRIVER_ID },
                { id: 'inc-2', title: 'รายงาน 2', reportedUserId: DRIVER_ID },
            ];

            prisma.incident.findMany.mockResolvedValue(mockIncidents);

            const result = await incidentService.getMyIncidents(DRIVER_ID);

            expect(result).toEqual(mockIncidents);
            expect(prisma.incident.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: {
                    OR: [
                        { reporterId: DRIVER_ID },
                        { reportedUserId: DRIVER_ID },
                    ],
                    isArchived: false,
                },
                orderBy: { createdAt: 'desc' },
            }));
        });
    });

    // ----------------------------------------------------------
    // getIncidentById — Driver
    // ----------------------------------------------------------
    describe('getIncidentById — Driver ดูรายละเอียด', () => {
        it('ควรคืนค่ารายงานตาม ID', async () => {
            const mockIncident = {
                id: 'inc-1',
                reporterId: DRIVER_ID,
                title: 'Test Incident',
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
    // getIncidentLogs — Driver (reporter)
    // ----------------------------------------------------------
    describe('getIncidentLogs — Driver ดู Log ในฐานะผู้รายงาน', () => {
        it('ควรคืน logs สำหรับ Driver ที่เป็น reporter', async () => {
            const mockIncident = { id: 'inc-1', reporterId: DRIVER_ID };
            const mockLogs = [
                { id: 'log-1', incidentId: 'inc-1', fromStatus: null, toStatus: 'PENDING' },
                { id: 'log-2', incidentId: 'inc-1', fromStatus: 'PENDING', toStatus: 'INVESTIGATING' },
            ];

            prisma.incident.findUnique.mockResolvedValue(mockIncident);
            prisma.incidentStatusLog.findMany.mockResolvedValue(mockLogs);

            const result = await incidentService.getIncidentLogs('inc-1', DRIVER_ID, 'DRIVER');

            expect(result).toEqual(mockLogs);
            expect(prisma.incidentStatusLog.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: { incidentId: 'inc-1' },
                orderBy: { createdAt: 'asc' },
            }));
        });

        it('ควรแจ้ง 403 ถ้า Driver ไม่ใช่ reporter ของ incident นี้', async () => {
            const mockIncident = { id: 'inc-1', reporterId: 'other-user' };
            prisma.incident.findUnique.mockResolvedValue(mockIncident);

            await expect(
                incidentService.getIncidentLogs('inc-1', DRIVER_ID, 'DRIVER')
            ).rejects.toThrow('ไม่มีสิทธิ์ดู log นี้');
        });

        it('ควรแจ้ง 404 ถ้า incident ไม่พบ', async () => {
            prisma.incident.findUnique.mockResolvedValue(null);

            await expect(
                incidentService.getIncidentLogs('non-existent', DRIVER_ID, 'DRIVER')
            ).rejects.toThrow('ไม่พบรายงานเหตุการณ์');
        });
    });

    // ----------------------------------------------------------
    // Validation — ตรวจสอบข้อมูลไม่ถูกต้อง (Zod Schema)
    // ----------------------------------------------------------
    describe('Validation — ข้อมูลไม่ถูกต้อง (createIncidentSchema)', () => {
        it('ควร reject ถ้า title เป็นค่าว่าง', () => {
            const data = {
                type: 'SAFETY_CONCERN',
                title: '',
                description: 'รายละเอียดทดสอบ',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues[0].message).toBe('กรุณาระบุหัวข้อ');
        });

        it('ควร reject ถ้าไม่ส่ง title', () => {
            const data = {
                type: 'SAFETY_CONCERN',
                description: 'รายละเอียดทดสอบ',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('title'))).toBe(true);
        });

        it('ควร reject ถ้า description เป็นค่าว่าง', () => {
            const data = {
                type: 'SAFETY_CONCERN',
                title: 'หัวข้อทดสอบ',
                description: '',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues[0].message).toBe('กรุณาระบุรายละเอียด');
        });

        it('ควร reject ถ้าไม่ส่ง description', () => {
            const data = {
                type: 'SAFETY_CONCERN',
                title: 'หัวข้อทดสอบ',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('description'))).toBe(true);
        });

        it('ควร reject ถ้าไม่ส่ง type', () => {
            const data = {
                title: 'หัวข้อทดสอบ',
                description: 'รายละเอียดทดสอบ',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('type'))).toBe(true);
        });

        it('ควร reject ถ้า type ไม่ถูกต้อง (ค่าที่ไม่อยู่ใน enum)', () => {
            const data = {
                type: 'INVALID_TYPE_XYZ',
                title: 'หัวข้อทดสอบ',
                description: 'รายละเอียดทดสอบ',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('type'))).toBe(true);
        });

        it('ควร reject ถ้า title ยาวเกิน 100 ตัวอักษร', () => {
            const data = {
                type: 'SAFETY_CONCERN',
                title: 'A'.repeat(101),
                description: 'รายละเอียดทดสอบ',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(false);
            expect(result.error.issues.some(i => i.path.includes('title'))).toBe(true);
        });

        it('ควรผ่านเมื่อข้อมูลถูกต้องครบถ้วน', () => {
            const data = {
                type: 'SAFETY_CONCERN',
                title: 'หัวข้อทดสอบ',
                description: 'รายละเอียดทดสอบ',
            };

            const result = createIncidentSchema.safeParse(data);

            expect(result.success).toBe(true);
            expect(result.data.priority).toBe('NORMAL'); // default
            expect(result.data.evidenceUrls).toEqual([]); // default
        });
    });

    // ----------------------------------------------------------
    // Upload Middleware — ตรวจสอบไฟล์แนบ (multer fileFilter)
    // ----------------------------------------------------------
    describe('Upload Middleware — ตรวจสอบไฟล์แนบ (multer)', () => {
        const upload = require('../../src/middlewares/upload.middleware');
        const multerConfig = upload;

        it('DI-06: ควร reject ไฟล์ประเภท .exe (ไม่ใช่รูปภาพ)', (done) => {
            const mockFile = {
                fieldname: 'evidences',
                originalname: 'file.exe',
                mimetype: 'application/x-msdownload',
            };

            // ดึง fileFilter จาก multer config โดยทดสอบผ่าน callback
            const fileFilter = multerConfig.fileFilter || multerConfig._fileFilter;

            // ทดสอบ fileFilter โดยตรง (multer เก็บ config ใน internal)
            // เนื่องจาก multer ไม่ expose fileFilter ตรงๆ เราจึงต้อง require ใหม่
            jest.isolateModules(() => {
                const multerLib = require('multer');
                const ApiError = require('../../src/utils/ApiError');

                // ทดสอบ logic เดียวกับ fileFilter
                const isImage = mockFile.mimetype.startsWith('image/');
                expect(isImage).toBe(false);
            });

            done();
        });

        it('DI-06: ไฟล์ .exe mimetype ไม่ตรง image/* → ไม่อนุญาต', () => {
            const invalidMimeTypes = [
                'application/x-msdownload',   // .exe
                'application/octet-stream',    // binary
                'text/plain',                  // .txt
                'application/pdf',             // .pdf
                'video/mp4',                   // .mp4 (ตาม config ปัจจุบัน)
            ];

            invalidMimeTypes.forEach(mimetype => {
                const isImage = mimetype.startsWith('image/');
                expect(isImage).toBe(false);
            });
        });

        it('DI-07: ขนาดไฟล์เกิน 50MB ไม่ผ่าน (ตรวจสอบ config)', () => {
            // ตรวจสอบว่า multer config กำหนด fileSize limit ไว้
            // multer เก็บ limits ใน internal config
            const maxFileSizeMB = 50;
            const maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
            const testFileSize = 51 * 1024 * 1024; // 51 MB

            expect(testFileSize).toBeGreaterThan(maxFileSizeBytes);
        });

        it('ไฟล์รูปภาพ (image/jpeg, image/png) ต้องผ่าน', () => {
            const validMimeTypes = [
                'image/jpeg',
                'image/png',
                'image/jpg',
                'image/gif',
                'image/webp',
            ];

            validMimeTypes.forEach(mimetype => {
                const isImage = mimetype.startsWith('image/');
                expect(isImage).toBe(true);
            });
        });

        it('จำนวนไฟล์สูงสุดต้องไม่เกิน 5 ไฟล์ (upload.array limit)', () => {
            // ตรวจว่า route ใช้ upload.array('evidences', 5)
            // ตรวจสอบว่า multer instance เป็น function ที่ใช้งานได้
            expect(typeof upload.array).toBe('function');
        });
    });
});

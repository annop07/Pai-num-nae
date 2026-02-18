const request = require('supertest');
const app = require('../../server');
const prisma = require('../../src/utils/prisma');
const bcrypt = require('bcrypt');
const { signToken } = require('../../src/utils/jwt');

// Mock Cloudinary
jest.mock('../../src/utils/cloudinary', () => ({
    uploadToCloudinary: jest.fn().mockImplementation((buffer, folder) => {
        return Promise.resolve({
            url: `https://res.cloudinary.com/demo/image/upload/v1234567890/${folder}/sample.jpg`,
            public_id: 'sample_public_id'
        });
    }),
    deleteFromCloudinary: jest.fn().mockResolvedValue({ result: 'ok' })
}));

let userToken;
let adminToken;
let testUserId;
let createdIncidentId;
let createdRoomId;

beforeAll(async () => {
    // สร้าง test user
    const hashedPassword = await bcrypt.hash('password123', 10);
    const user = await prisma.user.upsert({
        where: { email: 'chatuser@test.com' },
        update: {},
        create: {
            email: 'chatuser@test.com',
            username: 'chatuser_test',
            password: hashedPassword,
            firstName: 'Test',
            lastName: 'User',
            phoneNumber: '0812345678',
            role: 'PASSENGER',
            isVerified: true,
        },
    });
    testUserId = user.id;
    userToken = signToken({ sub: user.id, role: user.role });

    // สร้าง admin user
    const admin = await prisma.user.upsert({
        where: { email: 'chatadmin@test.com' },
        update: {},
        create: {
            email: 'chatadmin@test.com',
            username: 'chatadmin_test',
            password: hashedPassword,
            firstName: 'Test',
            lastName: 'Admin',
            phoneNumber: '0812345679',
            role: 'ADMIN',
            isVerified: true,
        },
    });
    adminToken = signToken({ sub: admin.id, role: admin.role });

    // สร้าง incident
    const incident = await prisma.incident.create({
        data: {
            reporterId: user.id,
            type: 'SAFETY_CONCERN',
            title: '[TEST] Chat Test Incident',
            description: 'สร้างเพื่อทดสอบ chat',
            status: 'PENDING',
        },
    });
    createdIncidentId = incident.id;

    // สร้าง ChatRoom สำหรับ incident นี้
    const chatRoom = await prisma.chatRoom.create({
        data: {
            incidentId: incident.id,
        },
    });
    createdRoomId = chatRoom.id;
});

afterAll(async () => {
    // ลบ incident (cascade ลบ chatRoom + messages ด้วย)
    await prisma.incident.deleteMany({
        where: { title: { startsWith: '[TEST]' } },
    });
    // ลบ test users
    await prisma.user.deleteMany({
        where: { email: { in: ['chatuser@test.com', 'chatadmin@test.com'] } },
    });
    await prisma.$disconnect();
});

// ===== 1. GET /api/chat/rooms =====
describe('GET /api/chat/rooms - ดูรายการ chat rooms ทั้งหมดของตัวเอง', () => {
    it('ควรดูรายการ chat rooms ของตัวเองได้ (200)', async () => {
        const res = await request(app)
            .get('/api/chat/rooms')
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(Array.isArray(res.body.data)).toBe(true);
    });

    it('Admin ควรดูรายการ chat rooms ทั้งหมดได้ (200)', async () => {
        const res = await request(app)
            .get('/api/chat/rooms')
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(Array.isArray(res.body.data)).toBe(true);
    });

    it('ควร reject ถ้าไม่มี token (401)', async () => {
        const res = await request(app)
            .get('/api/chat/rooms');

        expect(res.status).toBe(401);
        expect(res.body.success).toBe(false);
    });
});

// ===== 2. GET /api/chat/rooms/:id =====
describe('GET /api/chat/rooms/:id - ดูรายละเอียด chat room', () => {
    it('เจ้าของ incident ควรดู chat room ได้ (200)', async () => {
        const res = await request(app)
            .get(`/api/chat/rooms/${createdRoomId}`)
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(res.body.data.id).toBe(createdRoomId);
        expect(res.body.data.incidentId).toBe(createdIncidentId);
        expect(Array.isArray(res.body.data.messages)).toBe(true);
    });

    it('ควร 404 ถ้า id ไม่มีจริง', async () => {
        const res = await request(app)
            .get('/api/chat/rooms/clxxxxxxxxxxxxxxxxxxxxxxxxx')
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(404);
    });
});

// ===== 3. POST /api/chat/rooms/:id/messages =====
describe('POST /api/chat/rooms/:id/messages - ส่งข้อความ', () => {
    it('ควรส่งข้อความ TEXT สำเร็จ (201)', async () => {
        const res = await request(app)
            .post(`/api/chat/rooms/${createdRoomId}/messages`)
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                messageType: 'TEXT',
                content: 'สวัสดีครับ ทดสอบข้อความ',
            });

        expect(res.status).toBe(201);
        expect(res.body.success).toBe(true);
        expect(res.body.data.content).toBe('สวัสดีครับ ทดสอบข้อความ');
        expect(res.body.data.senderId).toBe(testUserId);
    });

    it('ควรส่งข้อความ LOCATION สำเร็จ (201)', async () => {
        const res = await request(app)
            .post(`/api/chat/rooms/${createdRoomId}/messages`)
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                messageType: 'LOCATION',
                content: 'ตำแหน่งปัจจุบัน',
                location: {
                    lat: 13.7563,
                    lng: 100.5018,
                },
            });

        expect(res.status).toBe(201);
        expect(res.body.success).toBe(true);
        expect(res.body.data.messageType).toBe('LOCATION');
    });

    it('ควรส่งข้อความ FILE สำเร็จ (201)', async () => {
        const res = await request(app)
            .post(`/api/chat/rooms/${createdRoomId}/messages`)
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                messageType: 'FILE',
                attachments: ['https://res.cloudinary.com/demo/image/upload/v1234567890/chat-attachments/sample.jpg']
            });

        expect(res.status).toBe(201);
        expect(res.body.success).toBe(true);
        expect(res.body.data.messageType).toBe('FILE');
        expect(Array.isArray(res.body.data.attachments)).toBe(true);
        expect(res.body.data.attachments.length).toBe(1);
    });
});

// ===== 3.1 POST /api/chat/rooms/:id/upload =====
describe('POST /api/chat/rooms/:id/upload - อัปโหลดไฟล์', () => {
    it('ควร upload ไฟล์สำเร็จและได้ URL กลับมา (200)', async () => {
        const res = await request(app)
            .post(`/api/chat/rooms/${createdRoomId}/upload`)
            .set('Authorization', `Bearer ${userToken}`)
            .attach('files', Buffer.from('fake image content'), 'test-image.jpg');

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(res.body.data).toHaveProperty('urls');
        expect(Array.isArray(res.body.data.urls)).toBe(true);
        expect(res.body.data.urls.length).toBeGreaterThan(0);
        expect(res.body.data.urls[0]).toContain('cloudinary');
    });

    it('ควร reject ถ้าไม่มีไฟล์ (400)', async () => {
        const res = await request(app)
            .post(`/api/chat/rooms/${createdRoomId}/upload`)
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(400);
        expect(res.body.message).toBe('No files uploaded');
    });
});

// ===== 4. PATCH /api/chat/rooms/:id/assign =====
describe('PATCH /api/chat/rooms/:id/assign - มอบหมาย Admin', () => {
    it('Admin ควร assign ตัวเองดูแล chat room ได้ (200)', async () => {
        const admin = await prisma.user.findUnique({ where: { email: 'chatadmin@test.com' } });
        const res = await request(app)
            .patch(`/api/chat/rooms/${createdRoomId}/assign`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ adminId: admin.id });

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(res.body.data.adminId).toBe(admin.id);
    });

    it('User ธรรมดาไม่ควร assign ได้ (403)', async () => {
        const res = await request(app)
            .patch(`/api/chat/rooms/${createdRoomId}/assign`)
            .set('Authorization', `Bearer ${userToken}`)
            .send({ adminId: testUserId });

        expect(res.status).toBe(403);
    });
});

// ===== 5. PATCH /api/chat/rooms/:id/close =====
describe('PATCH /api/chat/rooms/:id/close - ปิด chat room', () => {
    it('User ธรรมดาไม่ควรปิด chat room ได้ (403)', async () => {
        const res = await request(app)
            .patch(`/api/chat/rooms/${createdRoomId}/close`)
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(403);
    });

    it('Admin ควรปิด chat room ได้ (200)', async () => {
        const res = await request(app)
            .patch(`/api/chat/rooms/${createdRoomId}/close`)
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(res.body.data.status).toBe('CLOSED');
    });

    it('ควรส่งข้อความใน chat ที่ปิดแล้วไม่ได้ (400)', async () => {
        const res = await request(app)
            .post(`/api/chat/rooms/${createdRoomId}/messages`)
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                messageType: 'TEXT',
                content: 'ข้อความหลังปิด chat',
            });

        expect(res.status).toBe(400);
    });
});

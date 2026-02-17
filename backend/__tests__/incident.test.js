const request = require('supertest');
const app = require('../server');
const prisma = require('../src/utils/prisma');
const bcrypt = require('bcrypt');
const { signToken } = require('../src/utils/jwt');

let userToken;
let adminToken;
let testUserId;
let createdIncidentId;

beforeAll(async () => {
    // Login admin
    const adminRes = await request(app)
        .post('/api/auth/login')
        .send({ email: 'admin@example.com', password: '123456789' });
    adminToken = adminRes.body.data.token;

    // สร้าง test user
    const hashedPassword = await bcrypt.hash('123456789test', 10);
    const testUser = await prisma.user.upsert({
        where: { email: 'suphakit@gmail.com' },
        update: {},
        create: {
            email: 'suphakit@gmail.com',
            username: 'suphakit',
            password: hashedPassword,
            firstName: 'Suphakit',
            lastName: 'Kaeokaemthong',
            role: 'PASSENGER',
        },
    });
    testUserId = testUser.id;
    userToken = signToken({ sub: testUser.id, role: testUser.role });
});

afterAll(async () => {
    // ลบ incident ที่สร้างระหว่างทดสอบ
    await prisma.incident.deleteMany({
        where: { title: { startsWith: '[TEST]' } },
    });
    // ลบ test user
    await prisma.user.deleteMany({
        where: { email: 'suphakit@gmail.com' },
    });
    await prisma.$disconnect();
});

//User Report Incident

describe('POST /api/incidents - สร้างรายงานเหตุการณ์', () => {
    it('ควรสร้าง incident สำเร็จ (201)', async () => {
        const res = await request(app)
            .post('/api/incidents')
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                type: 'SAFETY_CONCERN',
                title: '[TEST] ทดสอบรายงานเหตุการณ์',
                description: 'รายละเอียดทดสอบ',
            });

        expect(res.status).toBe(201);
        expect(res.body.success).toBe(true);
        expect(res.body.data).toHaveProperty('id');
        expect(res.body.data.type).toBe('SAFETY_CONCERN');
        expect(res.body.data.status).toBe('PENDING');
        expect(res.body.data.priority).toBe('NORMAL');

        createdIncidentId = res.body.data.id;
    });

    it('ควร reject ถ้าไม่มี token (401)', async () => {
        const res = await request(app)
            .post('/api/incidents')
            .send({
                type: 'SAFETY_CONCERN',
                title: '[TEST] No Auth',
                description: 'test',
            });

        expect(res.status).toBe(401);
        expect(res.body.success).toBe(false);
    });

    it('ควร reject ถ้าไม่ระบุ type (400)', async () => {
        const res = await request(app)
            .post('/api/incidents')
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                title: '[TEST] Missing type',
                description: 'test',
            });

        expect(res.status).toBe(400);
    });

    it('ควร reject ถ้าไม่ระบุ title (400)', async () => {
        const res = await request(app)
            .post('/api/incidents')
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                type: 'SAFETY_CONCERN',
                description: 'test',
            });

        expect(res.status).toBe(400);
    });

    it('ควร reject ถ้า type ไม่ถูกต้อง (400)', async () => {
        const res = await request(app)
            .post('/api/incidents')
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                type: 'INVALID_TYPE',
                title: '[TEST] Invalid type',
                description: 'test',
            });

        expect(res.status).toBe(400);
    });
});

//GET /api/incidents/me
describe('GET /api/incidents/me - ดูรายการของตัวเอง', () => {
    it('ควรดึงรายการ incidents ของตัวเองได้ (200)', async () => {
        const res = await request(app)
            .get('/api/incidents/me')
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(Array.isArray(res.body.data)).toBe(true);
    });

    it('ควร reject ถ้าไม่มี token (401)', async () => {
        const res = await request(app).get('/api/incidents/me');
        expect(res.status).toBe(401);
    });
});


//GET /api/incidents/:id
describe('GET /api/incidents/:id - ดูรายละเอียด', () => {
    it('ควรดึงรายละเอียด incident ได้ (200)', async () => {
        const res = await request(app)
            .get(`/api/incidents/${createdIncidentId}`)
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(res.body.data.id).toBe(createdIncidentId);
    });

    it('ควร 404 ถ้า id ไม่มีจริง', async () => {
        const res = await request(app)
            .get('/api/incidents/clxxxxxxxxxxxxxxxxxxxxxxxxx')
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(404);
    });
});

//Task 2.2 Admin incident

//GET /api/incidents/admin
describe('GET /api/incidents/admin - Admin ดูรายการทั้งหมด', () => {
    it('ควรดึงรายการทั้งหมดได้ (200)', async () => {
        const res = await request(app)
            .get('/api/incidents/admin')
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(Array.isArray(res.body.data)).toBe(true);
        expect(res.body.pagination).toHaveProperty('total');
        expect(res.body.pagination).toHaveProperty('totalPages');
    });

    it('ควร filter ด้วย status ได้', async () => {
        const res = await request(app)
            .get('/api/incidents/admin?status=PENDING')
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.status).toBe(200);
        res.body.data.forEach((incident) => {
            expect(incident.status).toBe('PENDING');
        });
    });

    it('ควร reject ถ้าไม่ใช่ Admin (403)', async () => {
        const res = await request(app)
            .get('/api/incidents/admin')
            .set('Authorization', `Bearer ${userToken}`);

        expect(res.status).toBe(403);
    });
});

describe('PATCH /api/incidents/admin/:id - Admin อัปเดตสถานะ', () => {
    it('ควรเปลี่ยนสถานะเป็น INVESTIGATING ได้ (200)', async () => {
        const res = await request(app)
            .patch(`/api/incidents/admin/${createdIncidentId}`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ status: 'INVESTIGATING', priority: 'HIGH' });

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
        expect(res.body.data.status).toBe('INVESTIGATING');
        expect(res.body.data.priority).toBe('HIGH');
    });

    it('ควรเปลี่ยนสถานะเป็น RESOLVED พร้อม resolution ได้', async () => {
        const res = await request(app)
            .patch(`/api/incidents/admin/${createdIncidentId}`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
                status: 'RESOLVED',
                resolution: 'ตรวจสอบและตักเตือนผู้ขับแล้ว',
            });

        expect(res.status).toBe(200);
        expect(res.body.data.status).toBe('RESOLVED');
        expect(res.body.data.resolution).toBe('ตรวจสอบและตักเตือนผู้ขับแล้ว');
        expect(res.body.data.resolvedAt).not.toBeNull();
    });

    it('ควร reject ถ้าไม่ส่ง body 400', async () => {
        const res = await request(app)
            .patch(`/api/incidents/admin/${createdIncidentId}`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({});

        expect(res.status).toBe(400);
    });

    it('ควร 404 ถ้า id ไม่มีจริง', async () => {
        const res = await request(app)
            .patch('/api/incidents/admin/cmlxxxxxxxxxxxxxxxxxxxxxxxxx')
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ status: 'INVESTIGATING' });

        expect(res.status).toBe(404);
    });
});

describe('DELETE /api/incidents/admin/:id - Admin ลบ', () => {
    it('ควรลบ incident ได้ 200', async () => {
        // สร้างอันใหม่เพื่อลบ
        const created = await request(app)
            .post('/api/incidents')
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                type: 'FRAUD',
                title: '[TEST] สำหรับลบ',
                description: 'จะถูกลบทันที',
            });

        const idToDelete = created.body.data.id;

        const res = await request(app)
            .delete(`/api/incidents/admin/${idToDelete}`)
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.status).toBe(200);
        expect(res.body.success).toBe(true);
    });

    it('ควรแสดง 404 ถ้า id ไม่มีจริง', async () => {
        const res = await request(app)
            .delete('/api/incidents/admin/cmlxxxxxxxxxxxxxxxxxxxxxxxxx')
            .set('Authorization', `Bearer ${adminToken}`);

        expect(res.status).toBe(404);
    });
});




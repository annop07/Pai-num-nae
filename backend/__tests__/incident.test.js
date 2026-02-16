const request = require('supertest');
const app = require('../server');
const prisma = require('../src/utils/prisma');

let userToken;
let adminToken;
let createdIncidentId;

beforeAll(async () => {
    // Login as admin
    const adminRes = await request(app)
        .post('/api/auth/login')
        .send({ email: 'admin@example.com', password: '123456789' });
    adminToken = adminRes.body.token;

    // Login as user (ใช้ admin token ไปก่อน ถ้ามี user อื่นให้เปลี่ยน)
    userToken = adminToken;
});

afterAll(async () => {
    // ลบ incident ที่สร้างระหว่างทดสอบ
    if (createdIncidentId) {
        await prisma.incident.deleteMany({
            where: { title: { startsWith: '[TEST]' } },
        });
    }
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
/*
*
*
*
*
*/
//GET /api/incidents/:id
/*
*
*
*
*
*/
//GET /api/incidents
/*
*
*
*
*
*/
//GET /api/incidents/admin
/*
*
*
*
*
*/


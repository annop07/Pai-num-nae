const request = require('supertest');
const app = require('../server');
const prisma = require('../src/utils/prisma');
const bcrypt = require('bcrypt');
const { signToken } = require('../src/utils/jwt');

let userToken;
let adminToken;
let userId;
let adminId;
let incidentId;

beforeAll(async () => {
    // 1. Create Admin
    const adminEmail = 'admin_notif_test@example.com';
    const existingAdmin = await prisma.user.findUnique({ where: { email: adminEmail } });
    
    if (existingAdmin) {
        adminId = existingAdmin.id;
    } else {
        const hashedPassword = await bcrypt.hash('123456', 10);
        const admin = await prisma.user.create({
            data: {
                email: adminEmail,
                username: 'admin_notif',
                password: hashedPassword,
                firstName: 'Admin',
                lastName: 'Notif',
                role: 'ADMIN',
            },
        });
        adminId = admin.id;
    }
    adminToken = signToken({ sub: adminId, role: 'ADMIN' });

    // 2. Create User
    const userEmail = 'user_notif_test@example.com';
    const existingUser = await prisma.user.findUnique({ where: { email: userEmail } });

    if (existingUser) {
        userId = existingUser.id;
    } else {
        const hashedPassword = await bcrypt.hash('123456', 10);
        const user = await prisma.user.create({
            data: {
                email: userEmail,
                username: 'user_notif',
                password: hashedPassword,
                firstName: 'User',
                lastName: 'Notif',
                role: 'PASSENGER',
            },
        });
        userId = user.id;
    }
    userToken = signToken({ sub: userId, role: 'PASSENGER' });
});

afterAll(async () => {
    // Cleanup
    if (incidentId) {
        await prisma.chatRoom.deleteMany({ where: { incidentId } }); // ChatRoom is auto-created
        await prisma.incident.delete({ where: { id: incidentId } });
    }
    await prisma.notification.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { email: { in: ['admin_notif_test@example.com', 'user_notif_test@example.com'] } } });
    await prisma.$disconnect();
});

describe('Notification Tests', () => {

    it('User should create an incident successfully', async () => {
        const res = await request(app)
            .post('/api/incidents')
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                type: 'SAFETY_CONCERN',
                title: '[TEST] Notification Incident',
                description: 'Testing notification on update',
            });

        expect(res.status).toBe(201);
        incidentId = res.body.data.id;
    });

    it('User should receive a notification when Admin updates the incident status', async () => {
        // Admin updates the incident
        const updateRes = await request(app)
            .patch(`/api/incidents/admin/${incidentId}`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
                status: 'INVESTIGATING',
                priority: 'HIGH'
            });

        expect(updateRes.status).toBe(200);
        expect(updateRes.body.data.status).toBe('INVESTIGATING');

        // Check for notification
        const notifRes = await request(app)
            .get('/api/notifications')
            .set('Authorization', `Bearer ${userToken}`);

        expect(notifRes.status).toBe(200);
        
        // Find the specific notification
        const notification = notifRes.body.data.find(n => 
            n.type === 'INCIDENT' && n.metadata && n.metadata.incidentId === incidentId
        );

        // Expect to find it 
        expect(notification).toBeDefined();
        if (notification) {
             expect(notification.title).toContain('อัปเดตสถานะ');
             expect(notification.readAt).toBeNull();
        }
    });

    it('User should be able to mark notification as read', async () => {
        // Get notifications again to find an ID 
        const notifListRes = await request(app)
            .get('/api/notifications')
            .set('Authorization', `Bearer ${userToken}`);
        
        const notification = notifListRes.body.data.find(n => 
            n.type === 'INCIDENT' && n.metadata && n.metadata.incidentId === incidentId
        );

        if (!notification) {
             return; 
        }

        const readRes = await request(app)
            .patch(`/api/notifications/${notification.id}/read`)
            .set('Authorization', `Bearer ${userToken}`);

        expect(readRes.status).toBe(200);
        expect(readRes.body.data.readAt).not.toBeNull();
    });
});

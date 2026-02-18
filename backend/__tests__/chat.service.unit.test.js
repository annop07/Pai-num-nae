const chatService = require('../src/services/chat.service');
const prisma = require('../src/utils/prisma');
const ApiError = require('../src/utils/ApiError');

// Mock Prisma
jest.mock('../src/utils/prisma', () => ({
    chatRoom: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
    },
    message: {
        create: jest.fn(),
    },
}));

describe('การทดสอบ Unit Test ของ Chat Service', () => {
    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('getMyChatRooms (ดึงห้องแชทของฉัน)', () => {
        it('ควรคืนค่าทุกห้องแชทสำหรับ Admin', async () => {
             const mockRooms = [{ id: 'room-1' }];
             prisma.chatRoom.findMany.mockResolvedValue(mockRooms);

             const result = await chatService.getMyChatRooms('admin-1', 'ADMIN');

             expect(result).toEqual(mockRooms);
             expect(prisma.chatRoom.findMany).toHaveBeenCalledWith(expect.objectContaining({
                 where: {}
             }));
        });

        it('ควรคืนค่าเฉพาะห้องแชทขอบผู้ใช้สำหรับ User', async () => {
            const userId = 'user-1';
            const mockRooms = [{ id: 'room-1' }];
            prisma.chatRoom.findMany.mockResolvedValue(mockRooms);

            const result = await chatService.getMyChatRooms(userId, 'PASSENGER');

            expect(result).toEqual(mockRooms);
            expect(prisma.chatRoom.findMany).toHaveBeenCalledWith(expect.objectContaining({
                where: { incident: { reporterId: userId } }
            }));
        });
    });

    describe('getChatRoomById (ดึงห้องแชทตาม ID)', () => {
        it('ควรคืนค่าห้องแชทถ้าผู้ใช้เป็นคนแจ้ง', async () => {
            const roomId = 'room-1';
            const userId = 'user-1';
            const mockRoom = { 
                id: roomId, 
                incident: { reporterId: userId } 
            };

            prisma.chatRoom.findUnique.mockResolvedValue(mockRoom);

            const result = await chatService.getChatRoomById(roomId, userId, 'PASSENGER');

            expect(result).toEqual(mockRoom);
        });

        it('ควรคืนค่าห้องแชทถ้าผู้ใช้เป็น Admin', async () => {
             const roomId = 'room-1';
            const adminId = 'admin-1';
            const mockRoom = { 
                id: roomId, 
                incident: { reporterId: 'other-user' } 
            };

            prisma.chatRoom.findUnique.mockResolvedValue(mockRoom);

            const result = await chatService.getChatRoomById(roomId, adminId, 'ADMIN');

            expect(result).toEqual(mockRoom);
        });

        it('ควรแจ้ง error 403 ถ้าไม่ใช่เจ้าของเรื่องและไม่ใช่ Admin', async () => {
            const roomId = 'room-1';
            const userId = 'user-2';
            const mockRoom = { 
                id: roomId, 
                incident: { reporterId: 'user-1' } 
            };

            prisma.chatRoom.findUnique.mockResolvedValue(mockRoom);

            await expect(chatService.getChatRoomById(roomId, userId, 'PASSENGER'))
                .rejects.toThrow('Access denied');
        });

        it('ควรแจ้ง error 404 ถ้าไม่พบห้องแชท', async () => {
            prisma.chatRoom.findUnique.mockResolvedValue(null);
            await expect(chatService.getChatRoomById('invalid', 'u1', 'ADMIN'))
                .rejects.toThrow('Chat room not found');
        });
    });

    describe('sendMessage (ส่งข้อความ)', () => {
         it('ควรสร้างข้อความถ้าห้องแชทมีอยู่จริง', async () => {
            const roomId = 'room-1';
            const userId = 'user-1';
            const payload = { messageType: 'TEXT', content: 'Hello' };
            const mockRoom = { id: roomId, status: 'OPEN' };
            const mockMessage = { id: 'msg-1', ...payload };

            prisma.chatRoom.findUnique.mockResolvedValue(mockRoom);
            prisma.message.create.mockResolvedValue(mockMessage);

            const result = await chatService.sendMessage(roomId, userId, payload);

            expect(result).toEqual(mockMessage);
            expect(prisma.message.create).toHaveBeenCalledWith({
                data: expect.objectContaining({
                    chatRoomId: roomId,
                    senderId: userId,
                    content: 'Hello'
                }),
                include: expect.any(Object)
            });
         });

         it('ควรแจ้ง error 400 ถ้าห้องแชทปิดอยู่', async () => {
            const roomId = 'room-1';
            prisma.chatRoom.findUnique.mockResolvedValue({ id: roomId, status: 'CLOSED' });

            await expect(chatService.sendMessage(roomId, 'u1', {}))
                .rejects.toThrow('Chat is closed');
         });
    });

    describe('closeChatRoom (ปิดห้องแชท)', () => {
        it('ควรปิดห้องแชทสำเร็จ', async () => {
            const roomId = 'room-1';
            const adminId = 'admin-1';

            prisma.chatRoom.update.mockResolvedValue({ id: roomId, status: 'CLOSED' });

            const result = await chatService.closeChatRoom(roomId, adminId);

            expect(result.status).toBe('CLOSED');
            expect(prisma.chatRoom.update).toHaveBeenCalledWith({
                where: { id: roomId },
                data: expect.objectContaining({
                    status: 'CLOSED',
                    closedBy: adminId
                })
            });
        });
    });

    describe('assignAdmin (มอบหมาย Admin)', () => {
         it('ควรมอบหมาย Admin ให้ดูแลห้องแชท', async () => {
            const roomId = 'room-1';
            const adminId = 'admin-1';

            prisma.chatRoom.update.mockResolvedValue({ id: roomId, adminId });

            const result = await chatService.assignAdmin(roomId, adminId);

            expect(result.adminId).toBe(adminId);
            expect(prisma.chatRoom.update).toHaveBeenCalledWith({
                where: { id: roomId },
                data: { adminId }
            });
         });
    });
});

const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const getMyChatRooms = async (userId, userRole) => {
  const where = userRole === 'ADMIN'
    ? {} // Admin เห็นทุก chat
    : { incident: { reporterId: userId } }; // User เห็นแค่ของตัวเอง

  return prisma.chatRoom.findMany({
    where,
    include: {
      incident: {
        select: { id: true, title: true, status: true, reporterId: true }
      },
      admin: {
        select: { id: true, firstName: true, lastName: true, profilePicture: true }
      },
      messages: {
        take: 1,
        orderBy: { createdAt: 'desc' }
      }
    },
    orderBy: { createdAt: 'desc' }
  });
};

const getChatRoomById = async (chatRoomId, userId, userRole) => {
  const room = await prisma.chatRoom.findUnique({
    where: { id: chatRoomId },
    include: {
      incident: true,
      admin: {
        select: { id: true, firstName: true, lastName: true, profilePicture: true }
      },
      messages: {
        include: {
          sender: {
            select: { id: true, firstName: true, lastName: true, profilePicture: true }
          }
        },
        orderBy: { createdAt: 'asc' }
      }
    }
  });

  if (!room) throw new ApiError(404, 'Chat room not found');

  // ตรวจสอบสิทธิ์
  const isReporter = room.incident.reporterId === userId;
  const isAdmin = userRole === 'ADMIN';
  if (!isReporter && !isAdmin) {
    throw new ApiError(403, 'Access denied');
  }

  return room;
};

const sendMessage = async (chatRoomId, userId, data) => {
  // ตรวจสอบว่า chat ยังเปิดอยู่
  const room = await prisma.chatRoom.findUnique({ where: { id: chatRoomId } });
  if (!room) throw new ApiError(404, 'Chat room not found');
  if (room.status === 'CLOSED') throw new ApiError(400, 'Chat is closed');

  return prisma.message.create({
    data: {
      chatRoomId,
      senderId: userId,
      messageType: data.messageType,
      content: data.content,
      attachments: data.attachments,
      location: data.location
    },
    include: {
      sender: {
        select: { id: true, firstName: true, lastName: true, profilePicture: true }
      }
    }
  });
};

const closeChatRoom = async (chatRoomId, adminId) => {
  return prisma.chatRoom.update({
    where: { id: chatRoomId },
    data: {
      status: 'CLOSED',
      closedAt: new Date(),
      closedBy: adminId
    }
  });
};

const assignAdmin = async (chatRoomId, adminId) => {
  return prisma.chatRoom.update({
    where: { id: chatRoomId },
    data: { adminId }
  });
};

module.exports = {
  getMyChatRooms,
  getChatRoomById,
  sendMessage,
  closeChatRoom,
  assignAdmin
};
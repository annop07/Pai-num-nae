const { Server } = require("socket.io");
const { verifyToken } = require("../utils/jwt");
const prisma = require("../utils/prisma");

function initializeSocket(server) {
  const io = new Server(server, {
    cors: {
      origin: ["http://localhost:3001", "https://cssekku3-5.cpkku.com"],
      credentials: true,
    },
  });

  //Middleware: ตรวจสอบ JWT
  io.use(async (socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error("Authentication error: No token provided"));
    }

    try {
      const decoded = verifyToken(token);
      socket.userId = decoded.sub;
      socket.userRole = decoded.role;
      next();
    } catch (err) {
      next(new Error("Invalid token"));
    }
  });

  io.on("connection", (socket) => {
    console.log(`User ${socket.userId} connected`);

    // เข้า chat room
    socket.on("join_chat", async (chatRoomId) => {
      const room = await prisma.chatRoom.findUnique({
        where: { id: chatRoomId },
        include: { incident: true },
      });

      // Reporter หรือ Admin เท่านั้นที่เข้าได้
      if (!room) {
        return socket.emit("error", "Chat room not found");
      }

      const isReporter = room.incident.reporterId === socket.userId;
      const isAdmin = socket.userRole === "ADMIN";

      if (!isReporter && !isAdmin) {
        return socket.emit(
          "error",
          "You are not allowed to join this chat room",
        );
      }

      socket.join(chatRoomId);
      socket.emit("joined", { chatRoomId });
    });

    // ส่งข้อความ
    socket.on("send_message", async (data) => {
        const { chatRoomId, messageType, content, attachments, location } = data;

      //บันทึกข้อความลง DB
      const message = await prisma.message.create({
        data: {
          chatRoomId,
          senderId: socket.userId,
          messageType,
          content,
          attachments,
          location,
        },
        include: {
          sender: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePicture: true,
            },
          },
        },
      });

      io.to(chatRoomId).emit("new_message", message);
    });

    // Typing แสดง
    socket.on("typing", (chatRoomId) => {
      socket.to(chatRoomId).emit("user_typing", socket.userId);
    });

    socket.on("disconnect", () => {
      console.log(`User ${socket.userId} disconnected`);
    });
  });

  return io;
}

module.exports = { initializeSocket };

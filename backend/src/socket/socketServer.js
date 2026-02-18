const { Server } = require("socket.io");
const { verifyToken } = require("../utils/jwt");
const prisma = require("../utils/prisma");
const notificationService = require("../services/notification.service");

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
              email: true,
            },
          },
        },
      });

      io.to(chatRoomId).emit("new_message", message);

      // แจ้งเตือนผู้รับเมื่อมีข้อความใหม่ (ถ้าไม่อยู่ในหน้าหรือไม่ได้เปิดแชทอยู่)
      notifyChatRecipients(chatRoomId, message, socket.userId, socket.userRole).catch((err) =>
        console.error("Failed to notify chat recipients:", err)
      );
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

async function notifyChatRecipients(chatRoomId, message, senderId, senderRole) {
  const room = await prisma.chatRoom.findUnique({
    where: { id: chatRoomId },
    include: { incident: { select: { id: true, title: true, reporterId: true } } },
  });
  if (!room?.incident) return;

  const sender = message.sender;
  const senderName = sender
    ? ([sender.firstName, sender.lastName].filter(Boolean).join(" ").trim() || sender.email || "ผู้ใช้")
    : "ผู้ใช้";

  let preview = "ส่งข้อความ";
  if (message.messageType === "FILE") preview = "ส่งไฟล์แนบ";
  else if (message.messageType === "LOCATION") preview = "ส่งตำแหน่ง";
  else if (message.content && typeof message.content === "string") {
    preview = message.content.length > 50 ? message.content.slice(0, 50) + "…" : message.content;
  }

  const title = `ข้อความใหม่ - ${room.incident.title}`;
  const body = `${senderName}: ${preview}`;
  const link = `/chat?room=${chatRoomId}`;

  if (senderRole === "ADMIN") {
    // Admin ส่ง → แจ้ง Reporter
    if (room.incident.reporterId) {
      await notificationService.createNotificationByAdmin({
        userId: room.incident.reporterId,
        type: "INCIDENT",
        title,
        body,
        link,
        metadata: { chatRoomId, incidentId: room.incident.id },
      });
    }
  } else {
    // Reporter ส่ง → แจ้ง Admin ทุกคน
    const admins = await prisma.user.findMany({
      where: { role: "ADMIN" },
      select: { id: true },
    });
    for (const admin of admins) {
      await notificationService.createNotificationByAdmin({
        userId: admin.id,
        type: "INCIDENT",
        title,
        body,
        link,
        metadata: { chatRoomId, incidentId: room.incident.id },
      });
    }
  }
}

module.exports = { initializeSocket };

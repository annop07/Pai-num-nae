const asyncHandler = require('express-async-handler');
const chatService = require('../services/chat.service');

const getMyChatRooms = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  const userRole = req.user.role;
  const rooms = await chatService.getMyChatRooms(userId, userRole);
  res.status(200).json({ success: true, data: rooms });
});

const getChatRoomById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const userId = req.user.sub;
  const userRole = req.user.role;
  const room = await chatService.getChatRoomById(id, userId, userRole);
  res.status(200).json({ success: true, data: room });
});

const sendMessage = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const userId = req.user.sub;
  const message = await chatService.sendMessage(id, userId, req.body);
  res.status(201).json({ success: true, data: message });
});

const closeChatRoom = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const adminId = req.user.sub;
  const room = await chatService.closeChatRoom(id, adminId);
  res.status(200).json({ success: true, data: room });
});

const assignAdmin = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { adminId } = req.body;
  const room = await chatService.assignAdmin(id, adminId);
  res.status(200).json({ success: true, data: room });
});

module.exports = {
  getMyChatRooms,
  getChatRoomById,
  sendMessage,
  closeChatRoom,
  assignAdmin
};
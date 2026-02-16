const { z } = require('zod');

const sendMessageSchema = z.object({
  messageType: z.enum(['TEXT', 'FILE', 'LOCATION']),
  content: z.string().optional(),
  attachments: z.array(z.string().url()).optional(),
  location: z.object({
    lat: z.number(),
    lng: z.number(),
    address: z.string().optional()
  }).optional()
});

const assignAdminSchema = z.object({
  adminId: z.string()
});

module.exports = {
  sendMessageSchema,
  assignAdminSchema
};
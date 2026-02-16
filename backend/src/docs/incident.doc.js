/**
 * @swagger
 * tags:
 *   name: Incidents
 *   description: ระบบรายงานเหตุการณ์ (Incident Reporting & Management)
 */

/**
 * @swagger
 * /api/incidents:
 *   post:
 *     summary: สร้างรายงานเหตุการณ์ใหม่
 *     description: |
 *       สำหรับผู้ขับขี่หรือผู้โดยสารสร้างรายงานเหตุการณ์ เช่น ปัญหาความปลอดภัย อุบัติเหตุ หรือพฤติกรรมไม่เหมาะสม
 *       สามารถแนบหลักฐาน (รูปภาพ/วิดีโอ) และระบุตำแหน่งที่เกิดเหตุได้
 *     tags: [Incidents]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [type, title, description]
 *             properties:
 *               type:
 *                 type: string
 *                 enum: [SAFETY_CONCERN, ACCIDENT, HARASSMENT, FRAUD, VEHICLE_ISSUE, ROUTE_ISSUE, PAYMENT_ISSUE, OTHER]
 *                 description: ประเภทของเหตุการณ์
 *                 example: "SAFETY_CONCERN"
 *               priority:
 *                 type: string
 *                 enum: [LOW, NORMAL, HIGH, URGENT]
 *                 description: ระดับความเร่งด่วน (default NORMAL)
 *                 example: "HIGH"
 *               title:
 *                 type: string
 *                 maxLength: 100
 *                 description: หัวข้อเหตุการณ์
 *                 example: "คนขับขับรถเร็วเกินกำหนด"
 *               description:
 *                 type: string
 *                 description: รายละเอียดเหตุการณ์
 *                 example: "คนขับขับรถเร็วเกิน 120 กม./ชม. บนทางหลวง ทำให้รู้สึกไม่ปลอดภัย"
 *               reportedUserId:
 *                 type: string
 *                 description: ID ของผู้ถูกรายงาน (optional)
 *                 example: "clxxxxxxxxxxxxxxxxxxxxxxxxx"
 *               routeId:
 *                 type: string
 *                 description: ID ของเส้นทางที่เกี่ยวข้อง (optional)
 *               bookingId:
 *                 type: string
 *                 description: ID ของการจองที่เกี่ยวข้อง (optional)
 *               location:
 *                 type: object
 *                 description: ตำแหน่งที่เกิดเหตุ (optional)
 *                 example:
 *                   lat: 16.4419
 *                   lng: 102.8360
 *                   address: "ถ.มิตรภาพ อ.เมือง จ.ขอนแก่น"
 *               evidenceUrls:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: URL รูปภาพ/วิดีโอหลักฐาน (Cloudinary)
 *                 example: ["https://res.cloudinary.com/xxx/image/upload/v123/evidence1.jpg"]
 *     responses:
 *       201:
 *         description: สร้างรายงานเหตุการณ์สำเร็จ
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 id: "clxxxxxxxxxxxxxxxxxxxxxxxxx"
 *                 type: "SAFETY_CONCERN"
 *                 status: "PENDING"
 *                 priority: "HIGH"
 *                 title: "คนขับขับรถเร็วเกินกำหนด"
 *                 description: "คนขับขับรถเร็วเกิน 120 กม./ชม."
 *                 reporter:
 *                   id: "clxxxxxxxxxxxxxxxxxxxxxxxxx"
 *                   firstName: "สมชาย"
 *                   lastName: "ใจดี"
 *                   email: "somchai@example.com"
 *                 createdAt: "2026-02-16T09:30:00.000Z"
 *       400:
 *         description: ข้อมูลไม่ครบหรือไม่ถูกต้อง
 *       401:
 *         description: ไม่ได้ Login หรือ Token หมดอายุ
 */

/**
 * @swagger
 * /api/incidents/me:
 *   get:
 *     summary: ดูรายการเหตุการณ์ของตัวเอง
 *     description: |
 *       ดึงรายการเหตุการณ์ทั้งหมดที่ผู้ใช้เป็นผู้แจ้ง หรือเป็นผู้ถูกรายงาน
 *       เรียงตามวันที่สร้างล่าสุดก่อน
 *     tags: [Incidents]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: ดึงรายการสำเร็จ
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: "clxxxxxxxxxxxxxxxxxxxxxxxxx"
 *                   type: "SAFETY_CONCERN"
 *                   status: "PENDING"
 *                   priority: "HIGH"
 *                   title: "คนขับขับรถเร็วเกินกำหนด"
 *                   createdAt: "2026-02-16T09:30:00.000Z"
 *       401:
 *         description: ไม่ได้ Login หรือ Token หมดอายุ
 */

/**
 * @swagger
 * /api/incidents/{id}:
 *   get:
 *     summary: ดูรายละเอียดเหตุการณ์
 *     description: |
 *       ดึงรายละเอียดเหตุการณ์ตาม ID โดยผู้ใช้ต้องเป็นผู้แจ้งหรือผู้ถูกรายงานเท่านั้น
 *     tags: [Incidents]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Incident ID
 *     responses:
 *       200:
 *         description: ดึงรายละเอียดสำเร็จ
 *       403:
 *         description: ไม่มีสิทธิ์ดูรายงานนี้
 *       404:
 *         description: ไม่พบรายงานเหตุการณ์
 */

/**
 * @swagger
 * /api/incidents/admin:
 *   get:
 *     summary: (Admin) ดูรายการเหตุการณ์ทั้งหมด
 *     description: |
 *       สำหรับ Admin ดึงรายการเหตุการณ์ทั้งหมดในระบบ
 *       รองรับการ filter ตาม status, type, priority และค้นหาด้วยข้อความ
 *       รองรับ pagination และ sorting
 *     tags: [Incidents]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: หน้าที่ต้องการ
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *           maximum: 100
 *         description: จำนวนรายการต่อหน้า
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, INVESTIGATING, RESOLVED, DISMISSED, ESCALATED]
 *         description: กรองตามสถานะ
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [SAFETY_CONCERN, ACCIDENT, HARASSMENT, FRAUD, VEHICLE_ISSUE, ROUTE_ISSUE, PAYMENT_ISSUE, OTHER]
 *         description: กรองตามประเภท
 *       - in: query
 *         name: priority
 *         schema:
 *           type: string
 *           enum: [LOW, NORMAL, HIGH, URGENT]
 *         description: กรองตามระดับความเร่งด่วน
 *       - in: query
 *         name: q
 *         schema:
 *           type: string
 *         description: ค้นหาจากหัวข้อ รายละเอียด หรือชื่อผู้แจ้ง
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [createdAt, status, priority, type]
 *           default: createdAt
 *         description: เรียงตามฟิลด์
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *         description: ลำดับการเรียง
 *     responses:
 *       200:
 *         description: ดึงรายการสำเร็จ
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Incidents retrieved"
 *               data:
 *                 - id: "clxxxxxxxxxxxxxxxxxxxxxxxxx"
 *                   type: "SAFETY_CONCERN"
 *                   status: "PENDING"
 *                   priority: "HIGH"
 *                   title: "คนขับขับรถเร็วเกินกำหนด"
 *               pagination:
 *                 page: 1
 *                 limit: 20
 *                 total: 5
 *                 totalPages: 1
 *       401:
 *         description: ไม่ได้ Login
 *       403:
 *         description: ไม่ใช่ Admin
 */

/**
 * @swagger
 * /api/incidents/admin/{id}:
 *   get:
 *     summary: (Admin) ดูรายละเอียดเหตุการณ์
 *     description: Admin สามารถดูรายละเอียดเหตุการณ์ใดก็ได้ในระบบ
 *     tags: [Incidents]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Incident ID
 *     responses:
 *       200:
 *         description: ดึงรายละเอียดสำเร็จ
 *       404:
 *         description: ไม่พบรายงานเหตุการณ์
 *
 *   patch:
 *     summary: (Admin) อัปเดตสถานะ/ระดับความสำคัญ
 *     description: |
 *       Admin สามารถเปลี่ยนสถานะ ระดับความสำคัญ และเพิ่มความเห็นการแก้ไข
 *       เมื่อเปลี่ยนสถานะเป็น RESOLVED ระบบจะบันทึกผู้แก้ไขและเวลาแก้ไขอัตโนมัติ
 *     tags: [Incidents]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Incident ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [PENDING, INVESTIGATING, RESOLVED, DISMISSED, ESCALATED]
 *                 description: สถานะใหม่
 *                 example: "INVESTIGATING"
 *               priority:
 *                 type: string
 *                 enum: [LOW, NORMAL, HIGH, URGENT]
 *                 description: ระดับความเร่งด่วนใหม่
 *                 example: "HIGH"
 *               resolution:
 *                 type: string
 *                 description: ความเห็นจาก Admin เมื่อปิด case
 *                 example: "ได้ตรวจสอบและตักเตือนคนขับแล้ว"
 *     responses:
 *       200:
 *         description: อัปเดตสำเร็จ
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 id: "clxxxxxxxxxxxxxxxxxxxxxxxxx"
 *                 status: "RESOLVED"
 *                 priority: "HIGH"
 *                 resolution: "ได้ตรวจสอบและตักเตือนคนขับแล้ว"
 *                 resolvedAt: "2026-02-16T10:00:00.000Z"
 *                 resolver:
 *                   id: "clxxxxxxxxxxxxxxxxxxxxxxxxx"
 *                   firstName: "Admin"
 *                   lastName: "System"
 *       400:
 *         description: ข้อมูลไม่ถูกต้อง หรือไม่ได้ส่งฟิลด์ใดมาเลย
 *       404:
 *         description: ไม่พบรายงานเหตุการณ์
 *
 *   delete:
 *     summary: (Admin) ลบรายงานเหตุการณ์
 *     description: Admin สามารถลบรายงานเหตุการณ์ออกจากระบบ
 *     tags: [Incidents]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Incident ID
 *     responses:
 *       200:
 *         description: ลบสำเร็จ
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 message: "ลบรายงานเหตุการณ์สำเร็จ"
 *       404:
 *         description: ไม่พบรายงานเหตุการณ์
 */

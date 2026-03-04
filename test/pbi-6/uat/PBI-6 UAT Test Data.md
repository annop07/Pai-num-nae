**PBI-6 UAT Test Data**

เอกสารนี้รวบรวม **Test Data (ข้อมูลทดสอบ)** สำหรับการรัน UAT (User Acceptance Testing) ด้วย Robot Framework ในส่วนของ **Admin Incident Management** ซึ่งครอบคลุมการเปลี่ยนสถานะ (Change Status), การกรองข้อมูล (Filter), และการตรวจสอบรายละเอียดเหตุการณ์

⸻

**1. บัญชีผู้ดูแลระบบที่ใช้ทดสอบ (Admin Test Account)**

**1.1 ฝั่งผู้ดูแลระบบ (Admin)**
• **Username:** admin123
• **Password:** Admin@12345
• **Role:** Admin
• **เงื่อนไข (Pre-condition):**
• ต้องมี Incident ในระบบอย่างน้อย 1 รายการ
• Incident ต้องมีสถานะเริ่มต้นเป็น PENDING
• Admin ต้อง Login สำเร็จก่อนเข้าหน้า Incident Management

⸻

**2. ข้อมูลสำหรับทดสอบการเปลี่ยนสถานะ (Change Status - Happy Path)**

**2.1 เปลี่ยนจาก PENDING → INVESTIGATING**
• **Incident ID:** INC001
• **สถานะเดิม:** PENDING
• **สถานะใหม่:** INVESTIGATING
• **Expected Result:**
• แสดง Success Message
• Status เปลี่ยนเป็น INVESTIGATING
• รีเฟรชหน้าแล้วสถานะยังคงถูกต้อง

⸻

**2.2 เปลี่ยนจาก INVESTIGATING → ESCALATED**
• **Incident ID:** INC002
• **สถานะเดิม:** INVESTIGATING
• **สถานะใหม่:** ESCALATED
• **Expected Result:**
• แสดง Success Alert
• Badge Status เปลี่ยนเป็น ESCALATED
• สามารถกรองด้วย Filter ESCALATED แล้วพบรายการนี้

⸻

**2.3 เปลี่ยนจาก ESCALATED → RESOLVED**
• **Incident ID:** INC003
• **สถานะเดิม:** ESCALATED
• **สถานะใหม่:** RESOLVED
• **Expected Result:**
• แสดง Success Notification
• Status เปลี่ยนเป็น RESOLVED
• Incident แสดงใน Filter RESOLVED

⸻

**2.4 เปลี่ยนจาก ESCALATED → DISMISSED**
• **Incident ID:** INC004
• **สถานะเดิม:** ESCALATED
• **สถานะใหม่:** DISMISSED
• **Expected Result:**
• แสดง Success Message
• Status เปลี่ยนเป็น DISMISSED
• แสดงใน Filter DISMISSED

⸻

**3. ข้อมูลสำหรับ Negative Test Cases (Admin Validation & Error)**

**3.1 เปลี่ยนสถานะโดยไม่เลือกค่าใหม่**
• **สถานะเดิม:** PENDING
• **Action:** กดปุ่ม Change Status โดยไม่เลือกค่า
• **Expected Result:**
• แสดง Alert: “กรุณาเลือกสถานะ”
• ไม่เกิดการเปลี่ยนแปลงในฐานข้อมูล
⸻

**4. ข้อมูลสำหรับทดสอบ Filter Status (Tracking & Filtering)**

ใช้ Dropdown Status Filter บนหน้า Incident Management:
1. PENDING
2. INVESTIGATING
3. ESCALATED
4. RESOLVED
5. DISMISSED

**4.1 กรองแต่ละสถานะ**
• **Action:** เลือก Filter = PENDING
• **Expected Result:** แสดงเฉพาะ Incident ที่มีสถานะ PENDING
• **Action:** เลือก Filter = RESOLVED
• **Expected Result:** แสดงเฉพาะ Incident ที่มีสถานะ RESOLVED

⸻

**4.2 รีเซ็ต Filter**
• **Action:** เลือกสถานะใดสถานะหนึ่ง → กด Clear Filter
• **Expected Result:**
• แสดง Incident ทั้งหมด
• Dropdown รีเซ็ตค่าเป็น Default

⸻

**5. ข้อมูลสำหรับทดสอบการดูรายละเอียด Incident (View Detail)**

**5.1 ตรวจสอบข้อมูลที่แสดงใน Modal / Detail Page**
• **Incident ID:** INC005
• **Expected Data:**
• ประเภทปัญหา (Category)
• หัวข้อ
• รายละเอียด
• รูปภาพแนบ (ถ้ามี)
• วันที่แจ้งเหตุ
• ผู้แจ้งเหตุ (Passenger / Driver)
• สถานะปัจจุบัน
• **Expected Result:**
• ข้อมูลแสดงครบถ้วน
• รูปภาพโหลดได้
• ปิด Modal ได้ตามปกติ

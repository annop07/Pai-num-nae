# Test Design Document

## 1. บทนำ (Introduction)

เอกสารนี้จัดทำขึ้นเพื่ออธิบายกลยุทธ์และวิธีการทดสอบระบบ **Pai Nam Nae** โดยครอบคลุมทั้ง Unit Test และ Integration Test เพื่อให้มั่นใจในคุณภาพของระบบ

## 2. กลยุทธ์การทดสอบ (Test Strategy)

โครงการนี้ใช้การทดสอบ 2 ระดับหลัก ได้แก่:

### 2.1 การทดสอบระดับย่อย (Unit Testing)

- **ขอบเขต (Scope)**: ทดสอบการทำงานของ Business Logic ภายใน Service Layer อย่างละเอียด
- **เครื่องมือ (Tools)**: Jest
- **เทคนิคการจำลอง (Mocking)**: ใช้การ Mock dependencies ภายนอกทั้งหมด เช่น Prisma (ฐานข้อมูล), Notification Service, Socket.io เพื่อให้การทดสอบเป็นอิสระ (Isolated)
- **เป้าหมายความครอบคลุม (Coverage Goal)**: ครอบคลุมคำสั่ง (Statements) มากกว่า 80%

### 2.2 การทดสอบระดับบูรณาการ (Integration Testing)

- **ขอบเขต (Scope)**: ทดสอบ API Endpoints ตั้งแต่การรับ Request, การประมวลผล, การบันทึกข้อมูลลงฐานข้อมูล, จนถึงการส่ง Response กลับ
- **เครื่องมือ (Tools)**: Jest, Supertest
- **ฐานข้อมูล (Database)**: ใช้ Test Database แยกต่างหาก และล้างข้อมูลหลังจบการทดสอบแต่ละชุด

## 3. ภาพรวมกรณีทดสอบ (Test Cases Overview)

### 3.1 โมดูลยืนยันตัวตน (Authentication Module)

- **การเข้าสู่ระบบ (Login)**:
  - ข้อมูลถูกต้อง -> ได้รับ 200 OK + JWT Token
  - รหัสผ่านผิด -> ได้รับ 401 Unauthorized
  - ไม่พบผู้ใช้ -> ได้รับ 404 Not Found
- **การลงทะเบียน (Register)**:
  - ข้อมูลครบถ้วน -> ได้รับ 201 Created
  - อีเมล/ชื่อผู้ใช้ซ้ำ -> ได้รับ 400 Bad Request

### 3.2 โมดูลแจ้งเหตุ (Incident Module)

- **สร้างรายงานเหตุการณ์ (Create Incident)**:
  - ข้อมูลถูกต้อง -> ได้รับ 201 Created + ห้องแชทถูกสร้างอัตโนมัติ
  - ข้อมูลไม่ครบ -> ได้รับ 400 Bad Request
- **ดึงรายงานของฉัน (Get My Incidents)**:
  - ผู้ใช้ดึงข้อมูลของตัวเอง -> ได้รับ 200 OK + รายการเหตุการณ์
- **อัปเดตสถานะโดย Admin (Update Status)**:
  - Admin เปลี่ยนสถานะ -> ได้รับ 200 OK + ผู้แจ้งได้รับ Notification

### 3.3 โมดูลแชท (Chat Module)

- **ส่งข้อความ (Send Message)**:
  - ห้องแชทเปิดอยู่ -> ได้รับ 201 Created
  - ห้องแชทปิดแล้ว -> ได้รับ 400 Bad Request
- **ดึงประวัติการแชท (Get Chat History)**:
  - ผู้มีสิทธิ์ (เจ้าของ/Admin) -> ได้รับ 200 OK + รายการข้อความ
  - ผู้ไม่มีสิทธิ์ -> ได้รับ 403 Forbidden

### 3.4 โมดูลแจ้งเตือน (Notification Module)

- **ดูรายการแจ้งเตือน (List Notifications)**:
  - ดึงรายการของผู้ใช้ -> ได้รับ 200 OK
- **อ่านแจ้งเตือน (Mark Read)**:
  - ระบุ ID เพื่ออ่าน -> ได้รับ 200 OK

## 4. สภาพแวดล้อมการทดสอบ (Test Environment)

- **ระบบปฏิบัติการ (OS)**: Windows / Linux
- **รันไทม์ (Runtime)**: Node.js v16 ขึ้นไป
- **ฐานข้อมูล (Database)**: PostgreSQL (รัน Local หรือ Docker Container)
- **การจัดการ Config**: ใช้ไฟล์ `.env` หรือการตั้งค่า Environment Variables สำหรับทดสอบ

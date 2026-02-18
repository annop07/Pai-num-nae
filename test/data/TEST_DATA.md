# การจัดการข้อมูลทดสอบ (Test Data Management)

## 1. ภาพรวม (Overview)

เอกสารนี้ระบุรายการชุดข้อมูลทดสอบ (Test Data) ที่ใช้สำหรับการทดสอบทั้งในระดับ Unit Test และ Integration Test ของระบบ

## 2. ข้อมูลจำลองสำหรับ Unit Test (Mock Data)

ในการทำ Unit Test จะใช้การ Mock ข้อมูล object แทนการดึงจากฐานข้อมูลจริง ตัวอย่างเช่น:

### 2.1 ข้อมูลผู้ใช้ (Users)

```json
{
  "id": "user-1",
  "username": "tester",
  "role": "PASSENGER",
  "email": "test@example.com",
  "firstName": "สมชาย",
  "lastName": "ใจดี"
}
```

### 2.2 ข้อมูลผู้ดูแลระบบ (Admin)

```json
{
  "id": "admin-1",
  "username": "admin",
  "role": "ADMIN",
  "email": "admin@example.com",
  "firstName": "Admin",
  "lastName": "System"
}
```

### 2.3 ข้อมูลเหตุการณ์ (Incidents)

```json
{
  "id": "inc-1",
  "title": "อุบัติเหตุเฉี่ยวชน",
  "type": "ACCIDENT",
  "reporterId": "user-1",
  "status": "PENDING",
  "priority": "HIGH"
}
```

## 3. ข้อมูลตั้งต้นสำหรับ Integration Test (Seed Data)

ข้อมูลเหล่านี้จะถูกสร้างขึ้นจริงใน Test Database ก่อนเริ่มการทดสอบ (Setup) และจะถูกลบออกเมื่อจบการทดสอบ (Teardown)

### 3.1 การเตรียมข้อมูลเริ่มต้น (Initial Setup)

- **Admin User**: สร้างผ่าน `beforeAll` hook ในไฟล์ทดสอบ เพื่อใช้ยิง API ที่ต้องการสิทธิ์ Admin
- **Test User**: สร้างผ่าน API `auth/register` หรือ `prisma.user.create` ใน `beforeAll`
- **Incident Sample**: สร้าง Incident ตัวอย่างสำหรับทดสอบการดึงข้อมูล หรือแก้ไขสถานะ

### 3.2 กลยุทธ์การล้างข้อมูล (Cleanup Strategy)

- ใช้ `afterAll` hook ในแต่ละไฟล์ทดสอบ เพื่อลบข้อมูลที่สร้างขึ้น
- **วิธีการลบ**:
  - ลบข้อมูลโดยอ้างอิงจาก ID ที่เก็บไว้ในตัวแปรระหว่างทดสอบ
  - ลบข้อมูลโดยอ้างอิงจาก Pattern เฉพาะ (เช่น email ที่ลงท้ายด้วย `@test.com` หรือ title ที่ขึ้นต้นด้วย `[TEST]`)
- **สำคัญ**: การทดสอบจะไม่ยุ่งเกี่ยวกับฐานข้อมูลจริง (Production Database) ข้อมูลทั้งหมดจะอยู่ใน Test Environment เท่านั้น

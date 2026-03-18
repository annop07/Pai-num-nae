# for doc about PBI-16
# CHANGELOG
### Product Backlog Item As a user, I want my account and information to be removed from the system when I am no longer want to be a part of this community.

#### การพัฒนาฟังก์ชันลบบัญชีผู้ใช้

ผู้ใช้สามารถลบบัญชีของตนเองได้จากหน้า Profile หรือ ตั้งค่าบัญชี
ต้องยืนยันตัวตนด้วยรหัสผ่านปัจจุบันก่อนดำเนินการลบทุกครั้ง
ระบบตรวจสอบเงื่อนไขก่อนอนุญาตให้ลบ (Blocking Conditions) ได้แก่ Booking ที่ยังค้างอยู่, Route ที่ยัง Active และ Incident ที่ยังไม่ปิด
เมื่อลบสำเร็จระบบจะ Logout อัตโนมัติและ Redirect กลับหน้า Home
บัญชีที่ลบแล้วไม่สามารถ Login กลับเข้าระบบได้อีก
ข้อมูลจะถูกเก็บไว้ในระบบ (Soft Delete) และลบถาวรหลังครบ 90 วัน

#### การปรับปรุงส่วนติดต่อผู้ใช้
หน้า Profile / ตั้งค่าบัญชี

เพิ่มปุ่ม "ลบบัญชี" หรือ "Delete Account" สำหรับ Driver และ Passenger
ซ่อนปุ่มลบบัญชีสำหรับ Role Admin โดยสมบูรณ์

Dialog ยืนยันการลบบัญชี

แสดง Modal/Dialog ยืนยันการลบพร้อมช่องกรอกรหัสผ่าน
ปุ่ม "ยืนยัน" และ "ยกเลิก"
แสดงข้อความแจ้งเตือนเมื่อรหัสผ่านว่างเปล่าหรือไม่ถูกต้อง
แสดงข้อความแจ้งเตือนเฉพาะเจาะจงเมื่อมี Blocking Condition เช่น  "กรุณายกเลิกการจองที่ยังค้างอยู่ก่อน"

#### การปรับปรุงโครงสร้างไฟล์โปรเจค

ในไฟล์ pages/profile/index.vue เพิ่มปุ่ม Delete Account และ Logic การแสดง/ซ่อนตาม Role
เพิ่มฟังก์ชัน handleDeleteAccount() สำหรับเรียก API ตรวจสอบ Blocking Conditions และดำเนินการลบ
สร้าง Component ใหม่ components/DeleteAccountModal.vue แสดง Dialog ยืนยันพร้อมช่องกรอกรหัสผ่านและข้อความแจ้งเตือน
เพิ่ม API Endpoint DELETE /api/users/me รองรับการลบบัญชีพร้อม Middleware ตรวจสอบ Role และ Blocking Conditions
เพิ่ม Scheduled Job สำหรับ Hard Delete บัญชีที่ครบ 90 วัน

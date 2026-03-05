User Manual
Product Backlog Item No.6
As an admin, I want to keep the users updated on their reported incidents

---

การใช้งานสำหรับผู้ดูแลระบบ (Admin)
---

1. การเข้าสู่ระบบ
1.1 ไปที่หน้า Login
1.2 กรอก Email และ Password ของผู้ดูแลระบบ
1.3 กดปุ่ม เข้าสู่ระบบ

![Login](../img/Admin-Category-Reason.png)

---

2. การเข้าสู่หน้า Incident Management
2.1 หลังจากเข้าสู่ระบบสำเร็จ ระบบจะแสดงหน้า Admin Dashboard
2.2 เลือกเมนู Incident Management

![AdminDashboard](img-adminSidebar.png)

---

3. การเข้าสู่หน้า Change Status Form
3.1 ในหน้า Incident Management เลือกเคสที่ต้องการจัดการ
3.2 กดปุ่ม View & Take Action
3.3 ภายในหน้าจะแสดงรายละเอียด เคสการรายงาน 

![Incident](img-adminIncident.png)
ระบบจะแสดงหน้า Form Change Status

---

4.โครงสร้างหน้า Form Change Status
ภายในฟอร์มประกอบด้วย:
Incident Id (ID เคส)
Issue Type (ประเภทเคส)
Priority Level (ความรุนแรงเคส)
Reporter Name (ผู้รายงาน)
Current Status (แสดงสถานะปัจจุบัน)
Time (เวลาการรายงาน)
Incident Description (รายละเอียดเคสโดยผู้รายงาน)
Media Evidence (สื่อการรายงาน)
Location (สถานที่รายงานเหตุ)
New Status (เลือกสถานะต่อไป)
Reason Category (บังคับเลือกเหตุผล)
Description (บังคับกรอกรายละเอียดการดำเนินการ)
Resolution Note (Noteจดบันทึก)
ปุ่ม Confirm Change (ยอมรับการเปลี่ยนแปลง)
ปุ่ม รายงาน

![Form](img-FormChangeStatus.png)

--- 

5.การบันทึกข้อมูลเพื่อความปลอดภัย (Audit Log)
5.1 เมื่อกด Confirm ระบบจะดำเนินการดังนี้:
ตรวจสอบสิทธิ์ของผู้ดูแลระบบ
ตรวจสอบความถูกต้องของสถานะที่เลือก
บันทึกข้อมูลลงในระบบ Audit Log
Incident ID
สถานะเดิม
สถานะใหม่
เหตุผล
ผู้ดำเนินการ
วันที่และเวลา
5.2 ระบบจะไม่แก้ไขข้อมูลย้อนหลัง แต่จะบันทึกประวัติการเปลี่ยนแปลงทุกครั้ง

---

6. Success Modal
6.1 ระบบจะแสดงข้อความยืนยันการเปลี่ยนสถานะสำเร็จ
6.2 ปิดหน้าต่าง Form อัตโนมัติ
6.3 รีเฟรชข้อมูลในหน้า Incident Management

![Success](img-FormConfirm.png)

---

7. ุการเปลี่ยนสถานะ
Dashboard จะแสดงสถานะถัดไปของเคสนั้นๆ
PENDING (กำลังรอ)
INVESTIGATING (กำลังดำเนินการ)
RESOLVED (แก้ไขแล้ว)
DISMISSED
ESCALATE


8. การ Reopen เคส
หากต้องการเปิดเคสที่ถูกปิดแล้ว:
8.1 กดปุ่ม View & Take Action
8.2 เลือกสาเหตุในการเปิดเคสใหม่
8.3 กรอกเหตุผลในการเปิดเคสใหม่
8.4 กดยืนยัน
ระบบจะ:
บันทึกเหตุผลลงใน Audit Log
สร้าง Revision ใหม่ของเคส
ป้องกันการแก้ไขข้อมูลเคสเดิม

![Form](img-FormReopen.png)

---

สรุปการทำงานของ Form Change Status
Form Change Status ช่วยให้ผู้ดูแลระบบสามารถ:
อัปเดตสถานะเคสอย่างเป็นระบบ
บังคับกรอกเหตุผลเพื่อความโปร่งใส
บันทึกประวัติการเปลี่ยนแปลงทุกครั้ง
ป้องกันการแก้ไขย้อนหลัง
รองรับการ Reopen แบบมีหลักฐานตรวจสอบได้

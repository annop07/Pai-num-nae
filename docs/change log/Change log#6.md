CHANGELOG
Product Backlog Item No.6: As an admin, I want to keep the users updated on their reported incidents.
#### การพัฒนาฟังก์ชันรับเหตุสำหรับแอดมิน
-รับเหตุการณ์ที่userแจ้งจากหน้า Incident management 
-ตรวจสอบข้อมูลรายละเอียดIncident ทั้งหมดในรูปแบบ Dashboard table
-รองรับการตรวจสอบรายละเอียดเหตุการณ์ (Title, Description, Reporter, Reported user)
-เพิ่มความสามารถในการปรับสถานะเคส (Pending, Investigating, Resolved, Dismissed, Escalated)
-บันทึกnote สำหรับAdmin
-รองรับไฟล์แนบจากรายงานเหตุการณ์


#### การปรับปรุงส่วนติดต่อผู้ใช้
หน้า PNN Admin
-เพิ่มIncident managementสู่หน้าAdmin dashboard

หน้า Incident management
-Filter สถานะของแต่ละเคส
-Dropdown Status/Priority
-Box Incidentที่แสดงถึงเคสทั้งหมด,กำลังดำเนินการ
-list Case Incident ต่างๆที่ถูกreportเข้ามา
-ปุ่มView Detail เพื่อแสดงถึงรายละเอียด Incident detail
-Title และ description ของที่user ส่งเข้ามา
-ตำแหน่งLocationของการรายงานเคส
-ปุ่มMark as resolved สำหรับการยืนยันจัดการปัญหา

Success Modal
-เมื่อกด Mark as resolved ระบบอัปเดตสถานะเคสเป็น resolved
-ปิด Modal หลังดำเนินการสำเร็จ

#### การปรับปรุงโครงสร้างไฟล์โปรเจค
-เพิ่มไฟล์ pages/admin/incidents/index.vue
-เพิ่มไฟล์ pages/admin/incidents/create.vue
-เพิ่มไฟล์ pages/admin/incidents/[id]/edit.vue
-เพิ่มไฟล์ pages/admin/incidents/[id]/index.vue
-เพิ่ม mock data structure ให้สอดคล้องกับ Form Incicdent (รองรับ role, location, media, resolution) 
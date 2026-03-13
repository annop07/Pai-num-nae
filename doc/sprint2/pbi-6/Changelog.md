#### CHANGELOG
#### Product Backlog Item No.6: As an admin, I want to keep the users updated on their reported incidents.
#### การพัฒนาฟังก์ชันเปลี่ยนสถานะเคสรายงานสำหรับแอดมิน
-เพิ่มระบบ Change Status แบบมี Audit Log บันทึกทุกการเปลี่ยนสถานะแบบ append-only
-บังคับกรอก Resolution Note ก่อนเปลี่ยนสถานะ
-เพิ่ม Validation การเปลี่ยนสถานะตามลำดับ
-เพิ่มระบบ Reopen Case แบบสร้าง Revision ใหม่ แทนการแก้ไขเคสเดิม
-Lock เคสเมื่อสถานะเป็น resolved เพื่อป้องกันการแก้ไขย้อนหลัง
-บันทึกข้อมูลผู้ดำเนินการ (adminId) และ timestamp 


#### การปรับปรุงส่วนAdmin dashboard
-Incident management
แสดงสถานะของแต่ละเคส 
-แสดงรายการ Case Incident ที่ถูก report เข้ามาแบบApended only


#### หน้า Form ChangeStatus
-สถานะของแต่ละเคส ซึ่งดึงค่ามาจากการรายงาน
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


### Success Modal
-เมื่อกดระบบอัปเดตสถานะเคสเป็นสถานะถัดไป
-ปิด Modal หลังดำเนินการสำเร็จ


#### การปรับปรุงโครงสร้างไฟล์โปรเจค
### Data Model Update
-เพิ่ม field statusHistory,revisionNumber,incidentScope,targetUserId,updatedBy,updatedAt


### Audit Log
-เพิ่มโครงสร้าง Audit Log แยกออกจาก Incident หลัก,Incident ID,Old Status,New Status,Reason,Category,Action Description,Operator (Admin ID),Timestamp,Revision Reference

### Revision Control Mechanism
เมื่อ Reopen → สร้าง revision ใหม่
Lock ข้อมูล revision เดิม (read-only)
เชื่อมโยง revision ด้วย parentIncidentId

### Mock data
-เพิ่ม mock data structure ให้สอดคล้องกับ Form Change Stutus (รองรับ role, location, media, resolution,status logs,revision support) 

**เอกสารสรุปผลการทดสอบ (Test Report)**  
**ระบบจัดการเหตุการณ์ฝั่งผู้ดูแลระบบ (Admin Incident Management)**  
   
โครงการ: Pai-Num-Nae (ไปนำแหน่)  
ระดับการทดสอบ: User Acceptance Testing (UAT)  
เครื่องมือที่ใช้: Robot Framework & SeleniumLibrary  
Test Server: https://cssekku3-5.cpkku.com/  
ผู้ทดสอบ: สรยุทธ์ิ บุญกลัยา  
วันที่ดำเนินการทดสอบ: 4 มีนาคม 2026  
  
**1. บทสรุปผู้บริหาร (Executive Summary)**  
การทดสอบระบบจัดการ Incident ฝั่งผู้ดูแลระบบ (Admin – PBI-6) ได้ดำเนินการตาม Test Design ที่กำหนดไว้ โดยครอบคลุม:  
* การเข้าสู่ระบบ Admin  
* การดูรายการ Incident ทั้งหมด  
* การเปลี่ยนสถานะ Incident ตาม Workflow  
* การ Re-open Incident  
* การตรวจสอบ Validation ของฟอร์ม Change Status  
* การตรวจสอบการอัปเดตสถานะบนหน้าจอ  
**ภาพรวมผลการทดสอบ**  
* จำนวน Test Scenario ทั้งหมด: 10 Scenario  
* จำนวน Test Case รวม: 18 เคส  
* Passed: 18 (100%)  
* Failed: 0 (0%)  
* Blocked: 0  
ผลการทดสอบแสดงให้เห็นว่าระบบสามารถจัดการ Incident ได้ถูกต้องตาม Business Workflow และไม่มีข้อผิดพลาดเชิงฟังก์ชัน  
  
**2. ขอบเขตการทดสอบ (Scope of Testing)**  
การทดสอบครอบคลุมโมดูล:  
Module: Incident Management (Admin)  
ทดสอบการทำงานในส่วน:  
1.     View & Take Action  
2.     Change Status  
3.     Re-open Incident  
4.     Form Validation  
5.     การ Redirect หลัง Submit  
6.     การแสดง Badge สถานะ  
  
**3. สรุปผลการทดสอบตาม Scenario**  
**3.1 Change Status Workflow**  

| Scenario ID                | Scenario Name             | ผลลัพธ์ |
| -------------------------- | ------------------------- | ----- |
| UAT-Admin-ChangeStatus-001 | PENDING → INVESTIGATING   | Pass  |
| UAT-Admin-ChangeStatus-002 | INVESTIGATING → RESOLVED  | Pass  |
| UAT-Admin-ChangeStatus-004 | PENDING → DISMISSED       | Pass  |
| UAT-Admin-Reopened-008     | INVESTIGATING → ESCALATED | Pass  |
| UAT-Admin-Reopened-009     | ESCALATED → RESOLVED      | Pass  |
| UAT-Admin-Reopened-010     | ESCALATED → DISMISSED     | Pass  |
  
** **  
ผลการตรวจสอบ:  
* ระบบอัปเดตสถานะได้ถูกต้อง  
* มีการบันทึกข้อมูลลงฐานข้อมูลสำเร็จ  
* แสดงสถานะใหม่บนหน้า Incident Management ถูกต้อง  
* Redirect กลับหน้าหลักหลัง Submit สำเร็จ  
  
**3.2 Re-open Incident**  

| Scenario ID                | Scenario Name       | ผลลัพธ์ |
| -------------------------- | ------------------- | ----- |
| UAT-Admin-Reopened-006     | RESOLVED → PENDING  | Pass  |
| UAT-Admin-ChangeStatus-005 | DISMISSED → PENDING | Pass  |
  
ผลการตรวจสอบ:  
·       ปุ่ม Re-opened แสดงเฉพาะ Incident ที่มีสถานะ RESOLVED  
·       ระบบบังคับให้กรอกรายละเอียดก่อน Submit  
·       สถานะเปลี่ยนกลับเป็น PENDING สำเร็จ  
**3.3 Validation Testing**  

| Scenario ID                | รายละเอียด                       | ผลลัพธ์ |
| -------------------------- | ------------------------------- | ----- |
| UAT-Admin-ChangeStatus-003 | ไม่กรอกรายละเอียดใน Change Status | Pass  |
| UAT-Admin-Reopened-007     | ไม่กรอกรายละเอียดใน Re-open       | Pass  |
  
ผลการตรวจสอบ:  
* ระบบไม่อนุญาตให้ Submit เมื่อข้อมูลไม่ครบ  
* แสดงข้อความแจ้งเตือน “กรุณากรอกข้อมูลให้ครบถ้วน”  
* สถานะ Incident ไม่เปลี่ยนแปลง  
  
**4. ข้อมูลที่ใช้ในการทดสอบ (Test Data)**  
บัญชีที่ใช้ทดสอบ  
Username: admin123  
Role: Admin  
เงื่อนไขก่อนการทดสอบ (Pre-condition):  
* มี Incident ในระบบที่มีสถานะ:  
    * PENDING  
    * INVESTIGATING  
    * RESOLVED  
    * DISMISSED  
    * ESCALATED  
* Incident ต้องแสดงปุ่ม “View & Take Action”  
  
**5. สภาพแวดล้อมในการทดสอบ (Testing Environment)**  
Hardware:  
* Processor: 11th Gen Intel Core i5  
* RAM: 24 GB  
* SSD 512 GB  
Software:  
* Windows 11  
* Google Chrome Version 143.0.7499.169  
* Python 3.13.3  
* Robot Framework 7.4.1  
* SeleniumLibrary 6.8.0  
  
**6. ข้อค้นพบและการปรับปรุง (Key Findings & Improvements)**  
1.     เพิ่ม Wait Until Element Is Visible เพื่อลดปัญหา Flaky Test  
2.     ปรับ Locator ให้เลือก Incident ตาม Status แทนการเลือกตามลำดับ Row  
3.     เพิ่มขั้นตอน Verify Status หลัง Submit ทุกครั้ง  
4.     ตรวจสอบการแสดง Badge สีของแต่ละสถานะ (Resolved = สีเขียว)  
ไม่พบ Bug เชิงฟังก์ชันในระบบ  
  
**7. บทสรุปผลการทดสอบ (Final Conclusion)**  
ระบบ Admin Incident Management (PBI-6):  
* รองรับ Workflow การเปลี่ยนสถานะครบถ้วน  
* มีการตรวจสอบ Validation ถูกต้อง  
* การ Re-open ทำงานได้ตาม Policy  
* ไม่มีข้อผิดพลาดระดับ Critical หรือ Major  
   

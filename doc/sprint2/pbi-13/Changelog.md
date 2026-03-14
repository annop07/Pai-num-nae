# for doc about PBI-13
# CHANGELOG
### Product Backlog Item No.13: As a passenger, I want to report the driver behavior to the admin and get the update on the filed case.

#### การพัฒนาฟังก์ชันแจ้งเหตุสำหรับผู้ขับ
-แจ้งเหตุการณ์ด้านความปลอดภัยจากหน้า My Trip ได้โดยตรง
-กรอกข้อมูลรายละเอียดเหตุการณ์ผ่านแบบฟอร์ม
-ได้รับการยืนยันเมื่อส่งรายงานสำเร็จ

#### การปรับปรุงส่วนติดต่อผู้ใช้
หน้า My Trip
-เพิ่มปุ่มแจ้งเหตุ ในรายการการเดินทาง

หน้า Incident Form
-Dropdown สำหรับเลือกประเภทปัญหา
-ช่องกรอกหัวข้อ (ไม่เกิน 100 ตัวอักษร)
-ช่องกรอกรายละเอียดเหตุการณ์
-เลือกตำแหน่งผ่าน Google Maps
-อัปโหลดไฟล์รูปภาพ/วิดีโอ (สูงสุด 10MB)
-ปุ่มรายงานเหตุการณ์

Success Modal
-แสดง Pop-up แจ้งว่าส่งข้อมูลเรียบร้อยแล้ว

#### การปรับปรุงโครงสร้างไฟล์โปรเจค
-ในไฟล์ pages/myTrip/index.vue มีการเพิ่มปุ่มแจ้งเหตุในแต่ละรายการเดินทาง
-เพิ่มฟังก์ชัน goToIncidentForm(trip) เพื่อลิงค์ไปที่หน้า formIncident
-สร้างไฟล์ใหม่ pages/formIncident/index.vue แสดงแบบฟอร์มแจ้งเหตุ ที่รองรับ Google Maps, File Upload แสดง Success Modal 

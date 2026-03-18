## for doc about PBI-bonus
# CHANGELOG
### Product Backlog Item bonus: As a user, I want an evidence to confirm that the payment is successful.

#### การพัฒนาฟังก์ชันยืนยันการชำระเงินและออกเอกสาร

Passenger สามารถอัปโหลดสลิปหลักฐานการโอนเงินในหน้า Booking ได้
Driver สามารถตรวจสอบสลิปและกดยืนยันรับเงินได้
เมื่อ Driver ยืนยันแล้ว ปุ่มดาวน์โหลดเอกสารฝั่ง Passenger จะเปิดใช้งานทันที
รองรับการออกใบกำกับภาษีอย่างย่อตามมาตรฐานกรมสรรพากร
รองรับการออกใบสำคัญรับเงิน
กรณีชำระเงินสด Driver สามารถออกเอกสารได้โดยตรงโดยระบบ Auto-fill ข้อมูลจาก Booking

#### การปรับปรุงส่วนติดต่อผู้ใช้
หน้า Booking (ฝั่ง Passenger)

เพิ่มปุ่ม "อัปโหลดหลักฐาน" หรือ "Upload Slip"
แสดง Preview สลิปหลังอัปโหลดสำเร็จ
ปุ่มดาวน์โหลดใบกำกับภาษีอย่างย่อ (Disabled จนกว่า Driver จะยืนยัน)
ปุ่มดาวน์โหลดใบสำคัญรับเงิน (Disabled จนกว่า Driver จะยืนยัน)

หน้า Booking (ฝั่ง Driver)

แสดงสลิปที่ Passenger อัปโหลดพร้อมปุ่ม "ยืนยันรับเงิน" หรือ "Confirm Payment"
กรณีชำระเงินสด แสดง Template เอกสารพร้อม Auto-fill ข้อมูลจาก Booking
ปุ่มออกใบกำกับภาษีอย่างย่อ และปุ่มออกใบสำคัญรับเงิน

#### การปรับปรุงโครงสร้างไฟล์โปรเจค

ในไฟล์ pages/booking/[id].vue เพิ่ม Section การอัปโหลด Slip สำหรับ Passenger และ Section ยืนยันรับเงินสำหรับ Driver
เพิ่ม Component components/SlipUpload.vue รองรับการอัปโหลดไฟล์ JPG/PNG พร้อม Validation ประเภทและขนาดไฟล์ และแสดง Preview
เพิ่ม Component components/PaymentDocumentDownload.vue จัดการสถานะปุ่มดาวน์โหลดตาม Driver Confirmation
เพิ่ม API Endpoint POST /api/bookings/:id/slip สำหรับ Passenger อัปโหลด Slip
เพิ่ม API Endpoint POST /api/bookings/:id/confirm-payment สำหรับ Driver ยืนยันรับเงิน
เพิ่ม API Endpoint GET /api/bookings/:id/tax-invoice และ GET /api/bookings/:id/receipt สำหรับ Generate และดาวน์โหลดเอกสาร
เพิ่มฟังก์ชัน generateTaxInvoice() และ generateReceipt() สำหรับสร้างเอกสารพร้อม Auto-fill ข้อมูลจาก Booking


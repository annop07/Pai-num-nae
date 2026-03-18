# Test Design Document — PBL Bonus

**Project ID:** WEB-PaiNamNae  
**UAT Name:** เว็บไซต์ ไปนำแหน่  
**Version:** V1.0

---

## 1. บทนำ (Introduction)

### 1.1 ภาพรวมของระบบ (System Overview)

ไปนำแหน่ เป็นเว็บแอปพลิเคชันสำหรับค้นหาและประกาศการเดินทางแบบ Carpooling ผู้ใช้งานสามารถสมัครสมาชิก เข้าสู่ระบบ ค้นหาเส้นทาง และจองการเดินทางได้ผ่านระบบออนไลน์

### 1.2 วัตถุประสงค์ในการทดสอบ (Purpose of Test)

1. เพื่อตรวจสอบว่า Passenger สามารถอัปโหลดหลักฐานการชำระเงินได้ถูกต้อง
2. เพื่อตรวจสอบว่า Driver สามารถกดยืนยันรับเงินได้ถูกต้อง
3. เพื่อตรวจสอบว่าการดาวน์โหลดถูก Disable จนกว่า Driver จะยืนยัน
4. เพื่อตรวจสอบว่าใบกำกับภาษีอย่างย่อมีข้อมูลครบถ้วนตามที่กรมสรรพากรกำหนด
5. เพื่อตรวจสอบว่าใบสำคัญรับเงินมีข้อมูลครบถ้วน

### 1.3 การชำระเงิน (Payment Flow)

| ขั้นตอน 1 | ขั้นตอน 2 | ขั้นตอน 3 | ขั้นตอน 4 |
|:---:|:---:|:---:|:---:|
| Passenger โอนเงินให้ Driver นอกระบบ | Passenger อัปโหลด Slip หลักฐานในระบบ | Driver ตรวจสอบ Slip และกดยืนยันรับเงิน | การดาวน์โหลดเปิดใช้งาน: ใบกำกับภาษีอย่างย่อ / ใบสำคัญรับเงิน |

---

## 2. ขอบเขตการทดสอบ (Test Scope)

ผู้ทดสอบทำการทดสอบระดับ **User Acceptance Test (UAT)** โดยครอบคลุมกรณีการทดสอบดังต่อไปนี้

**2.1 กรณีฝั่งผู้ใช้งานฝั่ง Driver**
1. Driver ยืนยันรับเงินสำเร็จ
2. Driver ยืนยันรับเงินโดยไม่มีหลักฐานการชำระเงิน

**2.2 กรณีฝั่งผู้ใช้งานฝั่ง Passenger**
1. Passenger อัปโหลดหลักฐานการชำระเงินสำเร็จ
2. Passenger อัปโหลดหลักฐานการชำระเงินล้มเหลว
3. Passenger ตรวจสอบใบกำกับภาษีอย่างย่อ
4. Passenger ตรวจสอบใบสำคัญรับเงิน

**2.3 กรณีชำระเงินสด**
1. Driver ออกเอกสารให้ Passenger

**2.4 กรณี Driver ยังไม่ยืนยัน**
1. ปุ่มดาวน์โหลดถูก Disable

---

## 3. สภาพแวดล้อมในการทดสอบ (Testing Environment)

### 3.1 ฮาร์ดแวร์ (Hardware)

| รายการ | รายละเอียด |
|---|---|
| Model | Apple MacBook Air (M2) |
| Processor | Apple M2 |
| RAM | 16 GB |
| Storage | SSD 256 GB |

### 3.2 ซอฟต์แวร์ (Software)

| รายการ | รายละเอียด |
|---|---|
| Operating System | macOS |
| Browser | Google Chrome version 143.0.7499.169 |
| Python | Version 3.13.3 |
| Robot Framework | Version 7.4.1 |
| Selenium Library | Version 6.8.0 |
| Test Server | https://cssekku3-5.cpkku.com/ |

### 3.3 ผู้ทดสอบ (Human)

**Name:** นาย พิษณุวัชร์ หงส์วิไล, นาย นัฐดนัย ชาวไทย

---

## 4. รายละเอียดการทดสอบ (Test Scenario and Test Design)

### 4.1 คำอธิบาย (Description)

เป็นการทดสอบโดยผู้ทดสอบดำเนินการกรอกข้อมูลและใช้งานระบบด้วยตนเอง เพื่อประเมินความถูกต้องของการทำงานและประสบการณ์การใช้งาน (Usability) ทดสอบในกรณีดังต่อไปนี้

การสมัครสมาชิกสำเร็จ, การสมัครสมาชิกไม่สำเร็จ, การเข้าสู่ระบบสำเร็จ, การเข้าสู่ระบบไม่สำเร็จ, การแสดงข้อความแจ้งเตือน (Validation Message) ตามเงื่อนไขที่ได้กำหนดไว้ในเอกสารการทดสอบ

✓ หมายถึง ผ่าน (Pass)  
✗ หมายถึง ไม่ผ่าน (Fail)

---

### 4.2 ผลการทดสอบ (Test Results)

---

| **Test Scenario ID:** UAT-Bonus-SlipUpload-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Passenger อัปโหลด Slip สำเร็จ (JPG/PNG) | **Tested by:** ณัฐดนัย ชาวไทย |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Slip Upload (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่สามารถ Login ได้
2. มี Booking ที่สถานะรอชำระเงิน
3. เตรียมไฟล์ slip_payment.jpg (2 MB) และ slip_payment.png (3 MB)

**Description:** ทดสอบการอัปโหลดหลักฐานการชำระเงิน (Slip) ประเภท JPG และ PNG ระบบต้องรับไฟล์และแสดงตัวอย่างได้

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Open Website and Login:** 1. เปิดเว็บไซต์ https://cssekku3-5.cpkku.com/ 2. Login ด้วยบัญชี Passenger | เข้าสู่ระบบสำเร็จ ระบบแสดงหน้า Home | | ✓ | |
| 2 | **Navigate to Booking:** 1. เข้าหน้าชำระเงินที่มีสถานะรอชำระเงิน 2. กดปุ่ม 'อัปโหลดหลักฐาน' หรือ 'Upload Slip' | ระบบแสดง File Upload Dialog | | ✓ | |
| 3 | **Upload JPG (SL-01):** 1. เลือกไฟล์ slip_payment.jpg ขนาด 2 MB 2. กด Confirm/Submit | อัปโหลดสำเร็จ ระบบแสดงตัวอย่าง Slip (Preview) | | ✓ | TD: SL-01 |
| 4 | **Upload PNG (SL-02):** 1. ลบ Slip เดิมหรือ Upload ใหม่ 2. เลือกไฟล์ slip_payment.png ขนาด 3 MB 3. กด Submit | อัปโหลดสำเร็จ ระบบแสดงตัวอย่าง Slip (Preview) | | ✓ | TD: SL-02 |
| 5 | **Verify Slip Status:** ตรวจสอบว่าสถานะ Booking เปลี่ยนเป็น 'รอ Driver ยืนยัน' | สถานะ Booking อัปเดตสะท้อนการอัปโหลด Slip แล้ว | | ✓ | |

---

| **Test Scenario ID:** UAT-Bonus-SlipUpload-002 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Passenger อัปโหลด Slip ล้มเหลว — Validation | **Tested by:** ณัฐดนัย ชาวไทย |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Slip Upload Validation (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่ Login ได้
2. มี Booking ที่รอชำระเงิน
3. เตรียมไฟล์ทดสอบ: document.mp4 (10 MB), large_slip.jpg (15 MB), virus.exe (1 MB)

**Description:** ทดสอบ Validation ของระบบเมื่อ Passenger อัปโหลดไฟล์ที่ไม่ถูกต้อง ระบบต้องปฏิเสธและแสดงข้อความแจ้งเตือน

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Case 1 — ไม่อัปโหลดไฟล์ (SL-03):** 1. เปิด Upload Dialog 2. ไม่เลือกไฟล์ 3. กด Submit/Confirm | ระบบไม่อนุญาตให้ดำเนินการต่อ | | ✓ | TD: SL-03 |
| 2 | **Case 2 — ไฟล์ประเภทไม่ถูกต้อง .mp4 (SL-04):** 1. เลือกไฟล์ document.mp4 2. กด Submit | ระบบแจ้งเตือนประเภทไฟล์ไม่ถูกต้อง | | ✓ | TD: SL-04 |
| 3 | **Case 3 — ไฟล์ขนาดเกินกำหนด (SL-05):** 1. เลือกไฟล์ large_slip.jpg ขนาด 15 MB 2. กด Submit | ระบบแจ้งเตือนขนาดไฟล์เกินที่กำหนด / ไม่อัปโหลดไฟล์ | | ✓ | TD: SL-05 |
| 4 | **Case 4 — ไฟล์นามสกุลไม่ปลอดภัย (SL-06):** 1. เลือกไฟล์ virus.exe 2. กด Submit | ระบบแจ้งเตือนประเภทไฟล์ไม่ถูกต้อง / ไม่อัปโหลดไฟล์ | | ✓ | TD: SL-06 |

---

| **Test Scenario ID:** UAT-Bonus-SlipUpload-003 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Passenger อัปโหลด Slip ประเภท PDF | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Slip Upload PDF (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่สามารถ Login ได้
2. มี Booking ที่สถานะรอชำระเงิน
3. เตรียมไฟล์ slip_payment.pdf (2 MB)

**Description:** ทดสอบการอัปโหลดหลักฐานการชำระเงิน (Slip) ประเภท PDF ระบบต้องรับไฟล์ได้

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Passenger:** 1. เปิดเว็บไซต์ 2. Login ด้วยบัญชี Passenger | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Navigate to Booking:** 1. เข้าหน้าชำระเงินที่มีสถานะรอชำระเงิน 2. กดปุ่ม 'อัปโหลดหลักฐาน' | ระบบแสดง File Upload Dialog | | | |
| 3 | **Upload PDF (SL-07):** 1. เลือกไฟล์ slip_payment.pdf ขนาด 2 MB 2. กด Submit | อัปโหลดสำเร็จ ระบบบันทึกไฟล์ PDF | | | TD: SL-07 |
| 4 | **Verify Slip Status:** ตรวจสอบว่าสถานะ Booking เปลี่ยนเป็น 'รอ Driver ยืนยัน' | สถานะ Booking อัปเดตสะท้อนการอัปโหลด Slip แล้ว | | | |

---

| **Test Scenario ID:** UAT-Bonus-SlipUpload-004 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Passenger อัปโหลดหลายไฟล์ (Multiple Files) | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Multiple Files Upload (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่ Login ได้
2. มี Booking ที่รอชำระเงิน
3. เตรียมไฟล์ทดสอบ 6 ไฟล์: slip1.jpg, slip2.jpg, slip3.png, slip4.png, slip5.jpg, slip6.jpg

**Description:** ทดสอบการอัปโหลดหลายไฟล์พร้อมกัน ระบบรองรับสูงสุด 5 ไฟล์

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Upload 5 Files (SL-08):** 1. เลือกไฟล์ 5 ไฟล์พร้อมกัน 2. กด Submit | อัปโหลดสำเร็จทั้ง 5 ไฟล์ | | | TD: SL-08 |
| 2 | **Upload 6 Files (SL-09):** 1. เลือกไฟล์ 6 ไฟล์พร้อมกัน 2. กด Submit | ระบบปฏิเสธหรือรับแค่ 5 ไฟล์แรก | | | TD: SL-09 |

---

| **Test Scenario ID:** UAT-Bonus-DriverConfirm-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Driver ยืนยันรับเงินสำเร็จ | **Tested by:** ณัฐดนัย ชาวไทย |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Driver Confirm (Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Driver ที่ Login ได้
2. Passenger ได้อัปโหลด Slip แล้ว (ผ่าน SL-01 หรือ SL-02)
3. Booking อยู่ในสถานะ 'รอ Driver ยืนยัน'

**Description:** ทดสอบการที่ Driver กดยืนยันรับเงินหลังตรวจสอบ Slip ระบบต้องเปิดปุ่มดาวน์โหลดให้ Passenger

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Driver:** 1. เปิดเว็บไซต์ 2. Login ด้วยบัญชี Driver | เข้าสู่ระบบสำเร็จ | | ✓ | |
| 2 | **Navigate to Booking:** 1. เข้าหน้า Booking ที่ Passenger อัปโหลด Slip แล้ว 2. ตรวจสอบ Slip ที่ Passenger อัปโหลด | Driver เห็น Slip ของ Passenger พร้อมปุ่มยืนยัน | | ✓ | |
| 3 | **Confirm Payment (DR-01):** 1. กดปุ่ม 'ยืนยันรับเงิน' หรือ 'Confirm' | ระบบบันทึกสถานะสำเร็จ / ปุ่มดาวน์โหลดฝั่ง Passenger เปิดใช้งานได้ | | ✓ | TD: DR-01 |
| 4 | **Verify Download Button:** 1. ตรวจสอบฝั่ง Passenger ว่าปุ่มดาวน์โหลดเปิดแล้ว | ปุ่มดาวน์โหลดใบกำกับภาษีอย่างย่อและใบสำคัญรับเงิน Active กดได้ปกติ | | ✓ | TD: BL-02 |

---

| **Test Scenario ID:** UAT-Bonus-DriverConfirm-002 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Driver ยืนยันรับเงินสดโดยไม่มี Slip จาก Passenger | **Tested by:** ณัฐดนัย ชาวไทย |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Driver Confirm Blocking (Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Driver ที่ Login ได้
2. Passenger ยังไม่ได้อัปโหลด Slip

**Description:** ทดสอบว่าระบบไม่อนุญาตให้ Driver ยืนยันรับเงินหาก Passenger ยังไม่อัปโหลด Slip

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Driver:** 1. Login ด้วยบัญชี Driver | เข้าสู่ระบบสำเร็จ | | ✓ | |
| 2 | **Navigate to Booking (No Slip):** 1. เข้าหน้า Booking ที่ Passenger ยังไม่อัปโหลด Slip | หน้า Booking แสดงสถานะ 'รอ Passenger อัปโหลด Slip' | | ✓ | |
| 3 | **Attempt to Confirm (DR-02):** 1. พยายามกดปุ่มยืนยันรับเงิน (ถ้ามี) | ระบบไม่อนุญาตให้ยืนยัน / แสดงข้อความแจ้งเตือน 'รอ Slip จาก Passenger ก่อน' | | ✓ | TD: DR-02 |

---

| **Test Scenario ID:** UAT-Bonus-DriverReject-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Driver ปฏิเสธหลักฐานการชำระเงิน | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Driver Reject (Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Driver ที่ Login ได้
2. Passenger ได้อัปโหลด Slip แล้ว
3. Booking อยู่ในสถานะ 'รอ Driver ยืนยัน' (PROOF_SUBMITTED)

**Description:** ทดสอบการที่ Driver ปฏิเสธหลักฐานการชำระเงิน ระบบต้องเปลี่ยนสถานะเป็น DISPUTED และแจ้ง Passenger

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Driver:** 1. เปิดเว็บไซต์ 2. Login ด้วยบัญชี Driver | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Navigate to Booking:** 1. เข้าหน้า Booking ที่ Passenger อัปโหลด Slip แล้ว | Driver เห็น Slip และปุ่มยืนยัน/ปฏิเสธ | | | |
| 3 | **Reject without Reason (RJ-01):** 1. กดปุ่ม 'ปฏิเสธหลักฐาน' โดยไม่ใส่เหตุผล | ระบบแจ้งเตือน "กรุณาระบุเหตุผลอย่างน้อย 3 ตัวอักษร" | | | TD: RJ-01 |
| 4 | **Reject with Short Reason (RJ-02):** 1. ใส่เหตุผล "ab" (2 ตัวอักษร) 2. กดปฏิเสธ | ระบบแจ้งเตือน "กรุณาระบุเหตุผลอย่างน้อย 3 ตัวอักษร" | | | TD: RJ-02 |
| 5 | **Reject with Valid Reason (RJ-03):** 1. ใส่เหตุผล "สลิปไม่ชัด" 2. กดปฏิเสธ | ปฏิเสธสำเร็จ, สถานะเปลี่ยนเป็น DISPUTED | | | TD: RJ-03 |
| 6 | **Verify Passenger Notification:** ตรวจสอบฝั่ง Passenger | Passenger ได้รับ Notification แจ้งว่าถูกปฏิเสธพร้อมเหตุผล | | | |

---

| **Test Scenario ID:** UAT-Bonus-Resubmit-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Passenger ส่งหลักฐานใหม่หลังถูกปฏิเสธ | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Re-submit After Reject (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่ Login ได้
2. Booking อยู่ในสถานะ DISPUTED (ถูก Driver ปฏิเสธแล้ว)
3. เตรียมไฟล์ new_slip.jpg

**Description:** ทดสอบการที่ Passenger ส่งหลักฐานใหม่หลังถูกปฏิเสธ ระบบต้องอนุญาตให้ส่งใหม่ได้

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Passenger:** 1. Login ด้วยบัญชี Passenger | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **View Rejected Booking:** 1. เข้าหน้า Booking ที่ถูกปฏิเสธ | แสดงสถานะ DISPUTED และเหตุผลที่ถูกปฏิเสธ | | | |
| 3 | **Re-upload Slip (RS-01):** 1. กดอัปโหลดหลักฐานใหม่ 2. เลือก new_slip.jpg 3. กด Submit | อัปโหลดสำเร็จ, สถานะเปลี่ยนกลับเป็น PROOF_SUBMITTED | | | TD: RS-01 |
| 4 | **Verify Submission Number:** ตรวจสอบ Submission Number | แสดง Submission No. = 2 (ครั้งที่ 2) | | | |

---

| **Test Scenario ID:** UAT-Bonus-Blocking-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** การดาวน์โหลด Disabled ก่อน/หลัง Driver ยืนยัน | **Tested by:** ณัฐดนัย ชาวไทย |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Blocking Condition (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่ Login ได้
2. มี Booking ที่ Passenger อัปโหลด Slip แล้ว แต่ Driver ยังไม่ยืนยัน

**Description:** ทดสอบว่าระบบ Disable ปุ่มดาวน์โหลดก่อน Driver ยืนยัน และเปิดใช้งานได้หลัง Driver ยืนยันแล้ว

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Case 1 — Driver ยังไม่ยืนยัน (BL-01):** 1. Login ด้วยบัญชี Passenger 2. เข้าหน้า Booking 3. พยายามดาวน์โหลดเอกสาร | ไม่มีรายการดาวน์โหลด | | ✓ | TD: BL-01 |
| 2 | **Case 2 — Driver ยืนยันแล้ว (BL-02):** 1. Driver กดยืนยันรับเงิน (ทำ UAT-Bonus-DriverConfirm-001 ก่อน) 2. Passenger กลับมาดาวน์โหลด | สามารถดาวน์โหลดเอกสารได้ | | ✓ | TD: BL-02 |

---

| **Test Scenario ID:** UAT-Bonus-MethodMismatch-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Driver ยืนยันรับเงินด้วยวิธีชำระที่ต่างจาก Passenger แจ้ง | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Method Mismatch (Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Driver ที่ Login ได้
2. Passenger อัปโหลด Slip และแจ้งว่าชำระด้วย "PromptPay"
3. Booking อยู่ในสถานะ PROOF_SUBMITTED

**Description:** ทดสอบกรณี Driver ยืนยันว่าได้รับเงินด้วยวิธีที่ต่างจากที่ Passenger แจ้ง

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Driver:** 1. Login ด้วยบัญชี Driver | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **View Payment Details:** 1. เข้าหน้ายืนยันการชำระเงิน | แสดงวิธีที่ Passenger แจ้ง = PromptPay | | | |
| 3 | **Select Different Method (MM-01):** 1. เลือกวิธีรับเงินจริง = "เงินสด" 2. กดยืนยันโดยไม่ใส่เหตุผล | ระบบแจ้งเตือน "กรุณาระบุเหตุผลเมื่อวิธีชำระไม่ตรงกัน" | | | TD: MM-01 |
| 4 | **Mismatch with Short Reason (MM-02):** 1. ใส่เหตุผล "ok" (2 ตัวอักษร) 2. กดยืนยัน | ระบบแจ้งเตือน "กรุณาระบุเหตุผลอย่างน้อย 3 ตัวอักษร" | | | TD: MM-02 |
| 5 | **Mismatch with Valid Reason (MM-03):** 1. ใส่เหตุผล "ผู้โดยสารเปลี่ยนเป็นจ่ายเงินสดแทน" 2. กดยืนยัน | ยืนยันสำเร็จ, บันทึก verifiedPaymentMethod และ methodMismatchReason | | | TD: MM-03 |
| 6 | **Verify Document Data:** 1. ออกเอกสารและตรวจสอบ | เอกสารแสดงวิธีชำระ = เงินสด และมีบันทึกเหตุผล | | | |

---

| **Test Scenario ID:** UAT-Bonus-TaxInvoice-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** ตรวจสอบความครบถ้วนของใบกำกับภาษีอย่างย่อ | **Tested by:** ณัฐดนัย ชาวไทย |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Tax Invoice (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. Driver ยืนยันรับเงินแล้ว (ผ่าน UAT-Bonus-DriverConfirm-001)
2. Passenger Login และเข้าหน้า Booking ที่ยืนยันแล้ว
3. ปุ่มดาวน์โหลดใบกำกับภาษีอย่างย่อเปิดใช้งาน

**Description:** ทดสอบว่าใบกำกับภาษีอย่างย่อที่ระบบออกมีข้อมูลครบถ้วนตามที่กรมสรรพากรกำหนด

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Download Tax Invoice:** 1. Passenger กดปุ่มดาวน์โหลดใบกำกับภาษีอย่างย่อ | ไฟล์ดาวน์โหลดได้ไม่ corrupt เปิดได้ปกติ | | ✓ | TD: TX-07 |
| 2 | **Verify Header (TX-01):** ตรวจสอบว่ามีคำว่า 'ใบกำกับภาษีอย่างย่อ' ระบุชัดเจน | ปรากฏคำว่า 'ใบกำกับภาษีอย่างย่อ' ในเอกสาร | | ✓ | TD: TX-01 |
| 3 | **Verify Seller Info (TX-02):** ตรวจสอบชื่อ/ชื่อย่อของ Driver และเลขประจำตัวผู้เสียภาษี | แสดงชื่อ/ชื่อย่อ Driver และเลขประจำตัวผู้เสียภาษีถูกต้อง (ไม่ต้องระบุที่อยู่) | | ✓ | TD: TX-02 |
| 4 | **Verify Invoice Number (TX-03):** ตรวจสอบเลขที่ใบกำกับภาษี | แสดงเลขที่ไม่ซ้ำกันในแต่ละรายการ (Running Number) | | ✓ | TD: TX-03 |
| 5 | **Verify Price & VAT (TX-04):** ตรวจสอบราคาค่าบริการและข้อความ VAT | แสดงราคาพร้อมข้อความ 'ราคารวมภาษีมูลค่าเพิ่มแล้ว' ชัดเจน | | ✓ | TD: TX-04 |
| 6 | **Verify Date (TX-05):** ตรวจสอบวัน เดือน ปีที่ออกใบกำกับภาษี | แสดงวันที่ถูกต้อง ตรงกับวันที่ Driver ยืนยันรับเงิน | | ✓ | TD: TX-05 |

---

| **Test Scenario ID:** UAT-Bonus-Corporate-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Passenger ขอใบกำกับภาษีในนามนิติบุคคล | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Corporate Tax Invoice Request (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่ Login ได้
2. มี Booking ที่รอชำระเงิน
3. เตรียมข้อมูลบริษัท: ชื่อบริษัท, เลขผู้เสียภาษี 13 หลัก, ที่อยู่

**Description:** ทดสอบการขอใบกำกับภาษีในนามนิติบุคคล (Corporate Request)

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Passenger:** 1. Login ด้วยบัญชี Passenger | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Select Tax Invoice:** 1. เลือกเอกสาร "ใบกำกับภาษี" | แสดง checkbox "ต้องการออกใบกำกับภาษีในนามนิติบุคคล" | | | |
| 3 | **Enable Corporate without Company Name (CP-01):** 1. เลือก checkbox 2. ไม่ใส่ชื่อบริษัท 3. กด Submit | ระบบแจ้งเตือน "กรุณาระบุชื่อบริษัท" | | | TD: CP-01 |
| 4 | **Without Tax ID (CP-02):** 1. ใส่ชื่อบริษัท 2. ไม่ใส่เลขผู้เสียภาษี 3. กด Submit | ระบบแจ้งเตือน "กรุณาระบุเลขผู้เสียภาษี" | | | TD: CP-02 |
| 5 | **Invalid Tax ID — 12 digits (CP-03):** 1. ใส่เลขผู้เสียภาษี 12 หลัก 2. กด Submit | ระบบแจ้งเตือน "เลขผู้เสียภาษีต้องมี 13 หลัก" | | | TD: CP-03 |
| 6 | **Invalid Tax ID — 14 digits (CP-04):** 1. ใส่เลขผู้เสียภาษี 14 หลัก 2. กด Submit | ระบบแจ้งเตือน "เลขผู้เสียภาษีต้องมี 13 หลัก" | | | TD: CP-04 |
| 7 | **Invalid Tax ID — Letters (CP-05):** 1. ใส่เลขผู้เสียภาษีมีตัวอักษร "123456789012A" 2. กด Submit | ระบบแจ้งเตือน "เลขผู้เสียภาษีต้องเป็นตัวเลข 13 หลัก" | | | TD: CP-05 |
| 8 | **Without Address (CP-06):** 1. ใส่ชื่อบริษัท + เลขผู้เสียภาษีถูกต้อง 2. ไม่ใส่ที่อยู่ 3. กด Submit | ระบบแจ้งเตือน "กรุณาระบุที่อยู่ตามทะเบียนภาษี" | | | TD: CP-06 |
| 9 | **Valid Corporate Request (CP-07):** 1. ใส่ข้อมูลครบถ้วน (ชื่อ + Tax ID 13 หลัก + ที่อยู่) 2. อัปโหลด Slip 3. กด Submit | อัปโหลดสำเร็จ, บันทึก isCorporateRequest = true | | | TD: CP-07 |

---

| **Test Scenario ID:** UAT-Bonus-TaxProfile-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Driver กรอก Tax Profile ก่อนออกใบกำกับภาษี | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Driver Tax Profile (Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Driver ที่ Login ได้ และยังไม่เคยกรอก Tax Profile
2. มี Booking ที่ Driver ยืนยันรับเงินแล้ว (CONFIRMED)

**Description:** ทดสอบการกรอก Tax Profile ของ Driver ก่อนออกใบกำกับภาษี

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Driver:** 1. Login ด้วยบัญชี Driver ที่ยังไม่มี Tax Profile | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Attempt Issue Tax Invoice (TP-01):** 1. เลือกออกใบกำกับภาษี 2. กดออกเอกสาร | ระบบแสดง Modal ให้กรอก Tax Profile | | | TD: TP-01 |
| 3 | **Submit Empty Profile (TP-02):** 1. ไม่กรอกข้อมูล 2. กดบันทึก | ระบบแจ้งเตือน "กรุณากรอกชื่อผู้เสียภาษี" | | | TD: TP-02 |
| 4 | **Invalid Tax ID (TP-03):** 1. กรอกชื่อ + เลขผู้เสียภาษีไม่ครบ 13 หลัก 2. กดบันทึก | ระบบแจ้งเตือน "เลขผู้เสียภาษีต้องเป็นตัวเลข 13 หลัก" | | | TD: TP-03 |
| 5 | **Without Address (TP-04):** 1. กรอกชื่อ + เลขผู้เสียภาษีถูกต้อง 2. ไม่กรอกที่อยู่ 3. กดบันทึก | ระบบแจ้งเตือน "กรุณากรอกที่อยู่ตามทะเบียนภาษี" | | | TD: TP-04 |
| 6 | **Invalid Email (TP-05):** 1. กรอกอีเมลไม่ถูกรูปแบบ "test@" 2. กดบันทึก | ระบบแจ้งเตือน "รูปแบบอีเมลไม่ถูกต้อง" | | | TD: TP-05 |
| 7 | **Valid Tax Profile (TP-06):** 1. กรอกข้อมูลครบถ้วน 2. กดบันทึก | บันทึกสำเร็จ และออกใบกำกับภาษีอัตโนมัติ | | | TD: TP-06 |
| 8 | **Verify Tax Profile Persistence:** 1. ออกใบกำกับภาษีครั้งถัดไป | ไม่ต้องกรอก Tax Profile ใหม่ (ใช้ข้อมูลที่บันทึกไว้) | | | |

---

| **Test Scenario ID:** UAT-Bonus-Receipt-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** ตรวจสอบความครบถ้วนของใบสำคัญรับเงิน | **Tested by:** ณัฐดนัย ชาวไทย |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Receipt (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. Driver ยืนยันรับเงินแล้ว (ผ่าน UAT-Bonus-DriverConfirm-001)
2. Passenger Login และปุ่มดาวน์โหลดใบสำคัญรับเงินเปิดใช้งาน

**Description:** ทดสอบว่าใบสำคัญรับเงินที่ระบบออกมีข้อมูลครบถ้วน

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Download Receipt:** 1. Passenger กดปุ่มดาวน์โหลดใบสำคัญรับเงิน | ไฟล์ดาวน์โหลดได้ไม่ corrupt เปิดได้ปกติ | | ✓ | TD: RC-07 |
| 2 | **Verify Header (RC-01):** ตรวจสอบว่ามีคำว่า 'ใบสำคัญรับเงิน' | ปรากฏคำว่า 'ใบสำคัญรับเงิน' ในเอกสาร | | ✓ | TD: RC-01 |
| 3 | **Verify Receiver (RC-02):** ตรวจสอบชื่อผู้รับเงิน (Driver) | แสดงชื่อ Driver ถูกต้อง | | ✓ | TD: RC-02 |
| 4 | **Verify Payer (RC-03):** ตรวจสอบชื่อผู้จ่ายเงิน (Passenger) | แสดงชื่อ Passenger ถูกต้อง | | ✓ | TD: RC-03 |
| 5 | **Verify Amount (RC-04):** ตรวจสอบจำนวนเงินที่รับ | จำนวนเงินตรงกับจำนวนจริงที่ชำระ | | ✓ | TD: RC-04 |
| 6 | **Verify Details (RC-05):** ตรวจสอบรายละเอียดการชำระ | แสดงรายละเอียดการเดินทาง (Route/Booking) ครบถ้วน | | ✓ | TD: RC-05 |
| 7 | **Verify Date (RC-06):** ตรวจสอบวันที่รับเงิน | ตรงกับวันที่ Driver ยืนยันรับเงิน | | ✓ | TD: RC-06 |

---

| **Test Scenario ID:** UAT-Bonus-DuplicateDoc-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** ป้องกันการออกเอกสารซ้ำประเภทเดียวกัน | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Duplicate Document Prevention (Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Driver ที่ Login ได้
2. มี Booking ที่ CONFIRMED และออกใบกำกับภาษีไปแล้ว 1 ใบ

**Description:** ทดสอบว่าระบบป้องกันการออกเอกสารประเภทเดียวกันซ้ำ

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Driver:** 1. Login ด้วยบัญชี Driver | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Navigate to Issued Booking:** 1. เข้าหน้า Booking ที่ออกใบกำกับภาษีไปแล้ว | แสดงเอกสารที่ออกแล้วในรายการ | | | |
| 3 | **Attempt Duplicate Tax Invoice (DD-01):** 1. เลือกออกใบกำกับภาษีอีกครั้ง 2. กดออกเอกสาร | ระบบแจ้งเตือน "เอกสารประเภทนี้ถูกออกแล้ว" หรือปุ่มถูก Disable | | | TD: DD-01 |
| 4 | **Issue Different Type (DD-02):** 1. เลือกออกใบสำคัญรับเงินแทน 2. กดออกเอกสาร | ออกเอกสารสำเร็จ (คนละประเภทกัน) | | | TD: DD-02 |

---

| **Test Scenario ID:** UAT-Bonus-MultiDoc-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** Passenger ขอเอกสารหลายประเภท | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Multiple Document Types Request (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่ Login ได้
2. มี Booking ที่รอชำระเงิน

**Description:** ทดสอบการเลือกเอกสารหลายประเภทพร้อมกัน

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Passenger:** 1. Login ด้วยบัญชี Passenger | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Select No Document (MD-01):** 1. ไม่เลือกเอกสารใดเลย 2. กด Submit | ระบบแจ้งเตือน "กรุณาเลือกเอกสารที่ต้องการอย่างน้อย 1 รายการ" | | | TD: MD-01 |
| 3 | **Select Both Types (MD-02):** 1. เลือกทั้ง "ใบกำกับภาษี" และ "ใบสำคัญรับเงิน" 2. อัปโหลด Slip 3. กด Submit | อัปโหลดสำเร็จ, บันทึก requestedDocumentTypes = ["TAX_INVOICE", "PAYMENT_VOUCHER"] | | | TD: MD-02 |
| 4 | **Verify Driver View:** 1. Driver ดู Booking | แสดงข้อความ "Passenger requested: ใบกำกับภาษี, ใบสำคัญรับเงิน" | | | |

---

| **Test Scenario ID:** UAT-Bonus-QRCode-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** การชำระเงินผ่าน QR Code | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — QR Code Payment Method (Passenger) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger ที่ Login ได้
2. มี Booking ที่รอชำระเงิน
3. เตรียมไฟล์ slip_qr.jpg

**Description:** ทดสอบการชำระเงินผ่าน QR Code (ถ้าระบบรองรับใน UI)

> **หมายเหตุ:** ถ้า UI ไม่มี QR_CODE ใน dropdown ให้ระบุว่า "N/A — ไม่มีใน UI แต่ Backend รองรับ"

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Passenger:** 1. Login ด้วยบัญชี Passenger | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Select QR Code Method (QR-01):** 1. เลือกวิธีชำระเงิน = "QR Code" (ถ้ามีใน dropdown) | ระบบบันทึก paymentMethod = QR_CODE | | | TD: QR-01 |
| 3 | **Upload Slip:** 1. อัปโหลด slip_qr.jpg 2. กด Submit | อัปโหลดสำเร็จ | | | |

---

| **Test Scenario ID:** UAT-Bonus-Cash-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** กรณีชำระเงินสด — Driver ออกเอกสาร (Auto-fill & Document Issue) | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Cash Payment (Passenger & Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Passenger และ Driver ที่ Login ได้
2. มี Booking ที่รอชำระเงิน

**Description:** ทดสอบ Flow การชำระเงินสดแบบครบถ้วน

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Login as Passenger:** 1. Login ด้วยบัญชี Passenger | เข้าสู่ระบบสำเร็จ | | | |
| 2 | **Select Cash Method:** 1. เลือกวิธีชำระเงิน = "เงินสด (CASH)" | ระบบแสดงข้อความ "กรณีเงินสด ไม่แนบไฟล์ได้ แต่ต้องใส่หมายเหตุ" | | | |
| 3 | **Cash without Note (CS-01):** 1. ไม่อัปโหลดไฟล์ 2. ไม่ใส่หมายเหตุ 3. กด Submit | ระบบแจ้งเตือน "กรณีชำระเงินสด กรุณาระบุหมายเหตุ" | | | TD: CS-01 |
| 4 | **Cash with Note (CS-02):** 1. ไม่อัปโหลดไฟล์ 2. ใส่หมายเหตุ "จ่ายเงินสดก่อนขึ้นรถ" 3. กด Submit | อัปโหลดสำเร็จ (ไม่มีไฟล์แนบแต่มี note) | | | TD: CS-02 |
| 5 | **Verify No Evidence Files:** 1. ตรวจสอบฝั่ง Driver | แสดงข้อความ "ไม่มีไฟล์หลักฐาน" และแสดงหมายเหตุจาก Passenger | | | |
| 6 | **Driver Confirm Cash (CS-03):** 1. Driver กดยืนยันรับเงิน | ยืนยันสำเร็จ | | | TD: CS-03 |
| 7 | **Issue Tax Invoice (CS-04):** 1. Driver ออกใบกำกับภาษี | ออกเอกสารสำเร็จ แสดงวิธีชำระ = เงินสด | | | TD: CS-04 |
| 8 | **Issue Payment Voucher (CS-05):** 1. Driver ออกใบสำคัญรับเงิน | ออกเอกสารสำเร็จ | | | TD: CS-05 |
| 9 | **Passenger Download Documents:** 1. Passenger ดาวน์โหลดเอกสาร | ดาวน์โหลดได้ทั้ง 2 ประเภท | | | |

---

| **Test Scenario ID:** UAT-Bonus-UniqueNumber-001 | **Project ID:** WEB-PaiNamNae |
|---|---|
| **Test Scenario Name:** ตรวจสอบเลขที่เอกสารไม่ซ้ำกัน | **Tested by:** |
| **UAT Name:** เว็บไซต์ ไปนำแหน่ | **Version:** V1.0 |
| **Module:** Payment Confirmation — Unique Document Number (Driver) | **Date of Test:** |

**Pre-requisite:**
1. มีบัญชี Driver ที่ Login ได้
2. มี Booking 2 รายการที่ CONFIRMED

**Description:** ทดสอบว่าเลขที่เอกสารไม่ซ้ำกันในแต่ละใบ

| No. | Test Case and Steps | Expected Result | Actual Result | Test Result (Pass/Fail) | Remark |
|:---:|---|---|---|:---:|---|
| 1 | **Issue First Tax Invoice (UN-01):** 1. ออกใบกำกับภาษีสำหรับ Booking #1 | ได้เลขที่เอกสาร เช่น TI-202603-0001 | | | TD: UN-01 |
| 2 | **Issue Second Tax Invoice (UN-02):** 1. ออกใบกำกับภาษีสำหรับ Booking #2 | ได้เลขที่เอกสาร เช่น TI-202603-0002 (ไม่ซ้ำกับใบแรก) | | | TD: UN-02 |
| 3 | **Verify Running Number:** 1. เปรียบเทียบเลขที่ทั้ง 2 ใบ | เลขที่เอกสารต้องต่างกันและเป็น Running Number | | | |

---

## 5. รายงานสรุปผลการทดสอบ (Test Summary Report)

| Scenario ID | Scenario Name | Test Case # | Pass | Fail | No Run | Block | Remark | Defect ID |
|---|---|:---:|:---:|:---:|:---:|:---:|---|---|
| UAT-Bonus-SlipUpload-001 | Passenger อัปโหลด Slip สำเร็จ (JPG/PNG) | 5 | | | | | | |
| UAT-Bonus-SlipUpload-002 | Passenger อัปโหลด Slip ล้มเหลว — Validation | 4 | | | | | | |
| UAT-Bonus-SlipUpload-003 | Passenger อัปโหลด Slip ประเภท PDF | 4 | | | | | | |
| UAT-Bonus-SlipUpload-004 | Multiple Files Upload | 2 | | | | | | |
| UAT-Bonus-DriverConfirm-001 | Driver ยืนยันรับเงินสำเร็จ | 4 | | | | | | |
| UAT-Bonus-DriverConfirm-002 | Driver ยืนยันรับเงินโดยไม่มี Slip จาก Passenger | 3 | | | | | | |
| UAT-Bonus-DriverReject-001 | Driver ปฏิเสธหลักฐานการชำระเงิน | 6 | | | | | | |
| UAT-Bonus-Resubmit-001 | Passenger ส่งหลักฐานใหม่หลังถูกปฏิเสธ | 4 | | | | | | |
| UAT-Bonus-Blocking-001 | ปุ่มดาวน์โหลด Disabled ก่อน/หลัง Driver ยืนยัน | 2 | | | | | | |
| UAT-Bonus-TaxInvoice-001 | ตรวจสอบความครบถ้วนของใบกำกับภาษีอย่างย่อ | 6 | | | | | | |
| UAT-Bonus-Corporate-001 | Corporate Tax Invoice Request | 9 | | | | | | |
| UAT-Bonus-TaxProfile-001 | Driver Tax Profile | 8 | | | | | | |
| UAT-Bonus-Receipt-001 | ตรวจสอบความครบถ้วนของใบสำคัญรับเงิน | 7 | | | | | | |
| UAT-Bonus-DuplicateDoc-001 | Duplicate Document Prevention | 4 | | | | | | |
| UAT-Bonus-MultiDoc-001 | Multiple Document Types Request | 4 | | | | | | |
| UAT-Bonus-QRCode-001 | QR Code Payment Method | 3 | | | | | | |
| UAT-Bonus-Cash-001 | กรณีชำระเงินสด — Driver ออกเอกสาร | 9 | | | | | | |
| UAT-Bonus-UniqueNumber-001 | Unique Document Number | 3 | | | | | | |
| **รวม** | | **103** | | | | | | |

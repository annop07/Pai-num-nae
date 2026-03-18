# Test Data Document — PBL Bonus

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
3. เพื่อตรวจสอบว่าปุ่มดาวน์โหลดถูก Disable จนกว่า Driver จะยืนยัน
4. เพื่อตรวจสอบว่าใบกำกับภาษีอย่างย่อมีข้อมูลครบถ้วนตามที่กรมสรรพากรกำหนด
5. เพื่อตรวจสอบว่าใบสำคัญรับเงินมีข้อมูลครบถ้วน

### 1.3 Flow การชำระเงิน

| ขั้นตอน 1 | ขั้นตอน 2 | ขั้นตอน 3 | ขั้นตอน 4 |
|:---:|:---:|:---:|:---:|
| โอนเงินให้ Driver (Passenger โอนเงินนอกระบบ) | อัปโหลด Slip ในระบบ (Passenger อัปโหลดหลักฐาน) | Driver ยืนยันรับเงิน (ตรวจสอบและกดยืนยันในระบบ) | ดาวน์โหลดเอกสารได้: ใบกำกับภาษีอย่างย่อ / ใบสำคัญรับเงิน |

---

## 2. ขอบเขตการทดสอบ (Scope of Testing)

### 2.1 อยู่ในขอบเขต (In Scope)

- Passenger อัปโหลดหลักฐานการชำระเงิน (Slip)
- Driver กดยืนยันรับเงิน
- Blocking condition — ปุ่มดาวน์โหลด Disable ก่อน Driver ยืนยัน
- ดาวน์โหลดใบกำกับภาษีอย่างย่อ
- ดาวน์โหลดใบสำคัญรับเงิน
- ตรวจสอบความครบถ้วนของข้อมูลในเอกสาร

### 2.2 นอกขอบเขต (Out of Scope)

- ระบบชำระเงินออนไลน์ (Payment Gateway)
- Performance Test
- Login และ Register

---

## 3. สภาพแวดล้อมในการทดสอบ (Testing Environment)

### 3.1 ฮาร์ดแวร์ (Hardware)

| รายการ | รายละเอียด |
|---|---|
| Model | Apple MacBook Air (M2) |
| Processor | Apple M2 |
| RAM | 16 GB |
| Storage | SSD |

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

**Name:** นายอรรณพ แสงศิลา

---

## 4. Test Account Information

| Role | Username | Description |
|---|---|---|
| Passenger | TestPassenger_UAT | ใช้ทดสอบการอัปโหลด Slip และดาวน์โหลดเอกสาร |
| Driver | TestDriver_UAT | ใช้ทดสอบการยืนยันรับเงิน |

---

## 5. Test Data Design

Test Data ถูกออกแบบโดยอ้างอิงจาก User Story และใช้เทคนิค **Equivalence Partitioning** และ **Boundary Value Analysis** เพื่อครอบคลุมทั้งกรณีสำเร็จ (Positive Case) และกรณีไม่สำเร็จ (Negative Case)

---

## 6. Slip Upload — Test Data

**Pre-requisite:** Passenger Login สำเร็จ และมี Booking ที่รอชำระเงิน

### 6.1 Positive Case

| TD_ID | ไฟล์ที่อัปโหลด | ขนาดไฟล์ | Expected Result |
|:---:|---|:---:|---|
| SL-01 | slip_payment.jpg | 2 MB | อัปโหลดสำเร็จ ระบบแสดงตัวอย่าง Slip |
| SL-02 | slip_payment.png | 3 MB | อัปโหลดสำเร็จ ระบบแสดงตัวอย่าง Slip |

### 6.2 Negative Case

| TD_ID | ไฟล์ที่อัปโหลด | ขนาดไฟล์ | Expected Result |
|:---:|---|:---:|---|
| SL-03 | ไม่อัปโหลดไฟล์ | - | ระบบไม่อนุญาตให้ดำเนินการต่อ แจ้งเตือนกรุณาอัปโหลดหลักฐาน |
| SL-04 | document.pdf | 1 MB | ระบบแจ้งเตือนประเภทไฟล์ไม่ถูกต้อง รองรับเฉพาะ JPG/PNG |
| SL-05 | large_slip.jpg | 15 MB | ระบบแจ้งเตือนขนาดไฟล์เกินที่กำหนด |
| SL-06 | virus.exe | 1 MB | ระบบแจ้งเตือนประเภทไฟล์ไม่ถูกต้อง |

---

## 7. Driver — ยืนยันรับเงิน

**Pre-requisite:** Driver Login สำเร็จ และ Passenger อัปโหลด Slip แล้ว

### 7.1 Positive Case

| TD_ID | การกระทำ | Expected Result |
|:---:|---|---|
| DR-01 | Driver ตรวจสอบ Slip และกดยืนยันรับเงิน | ระบบบันทึกสถานะสำเร็จ ปุ่มดาวน์โหลดฝั่ง Passenger เปิดใช้งานได้ |

### 7.2 Negative Case

| TD_ID | การกระทำ | Expected Result |
|:---:|---|---|
| DR-02 | Driver กดยืนยันโดยไม่มี Slip จาก Passenger | ระบบไม่อนุญาตให้ยืนยัน แจ้งเตือนรอ Slip จาก Passenger ก่อน |

---

## 8. Blocking Condition — ปุ่มดาวน์โหลดก่อน/หลัง Driver ยืนยัน

**Pre-requisite:** Passenger Login สำเร็จ

| TD_ID | สถานะ | การกระทำ | Expected Result |
|:---:|---|---|---|
| BL-01 | Driver **ยังไม่ยืนยัน** | Passenger พยายามกดปุ่มดาวน์โหลด | ปุ่มดาวน์โหลด Disabled / Blank ไม่สามารถกดได้ |
| BL-02 | Driver **ยืนยันแล้ว** | Passenger กดปุ่มดาวน์โหลด | ปุ่มดาวน์โหลด Active กดได้ปกติ |

---

## 9. ใบกำกับภาษีอย่างย่อ — Test Data

**Pre-requisite:** Driver ยืนยันรับเงินแล้ว และ Passenger กดดาวน์โหลดใบกำกับภาษีอย่างย่อ

### 9.1 ตรวจสอบข้อมูลในเอกสาร

| TD_ID | รายการที่ตรวจสอบ | Expected Result |
|:---:|---|---|
| TX-01 | ระบุคำว่า "ใบกำกับภาษีอย่างย่อ" ให้ชัดเจน | ปรากฏคำว่า "ใบกำกับภาษีอย่างย่อ" ในเอกสาร |
| TX-02 | ชื่อหรือชื่อย่อของผู้ขาย (Driver) และเลขประจำตัวผู้เสียภาษี | แสดงชื่อ/ชื่อย่อ Driver และเลขประจำตัวผู้เสียภาษีถูกต้อง (ไม่ต้องระบุที่อยู่) |
| TX-03 | เลขที่ใบกำกับภาษี | แสดงเลขที่ไม่ซ้ำกันในแต่ละรายการ |
| TX-04 | ชื่อ ชนิด ประเภท ปริมาณ และมูลค่าการซื้อขาย | แสดงรายละเอียดบริการเดินทาง (Route) ครบถ้วน |
| TX-05 | ราคาค่าบริการ พร้อมข้อความระบุว่า **"ราคารวมภาษีมูลค่าเพิ่มแล้ว"** | แสดงราคาและข้อความ VAT Included ชัดเจน |
| TX-06 | วัน เดือน ปีที่ออกใบกำกับภาษี | แสดงวันที่ถูกต้อง ตรงกับวันที่ Driver ยืนยัน |
| TX-07 | ดาวน์โหลดไฟล์ได้สำเร็จ | ไฟล์ดาวน์โหลดได้ ไม่ corrupt |

---

## 10. ใบสำคัญรับเงิน — Test Data

**Pre-requisite:** Driver ยืนยันรับเงินแล้ว และ Passenger กดดาวน์โหลดใบสำคัญรับเงิน

| TD_ID | รายการที่ตรวจสอบ | Expected Result |
|:---:|---|---|
| RC-01 | ระบุคำว่า "ใบสำคัญรับเงิน" ให้ชัดเจน | ปรากฏคำว่า "ใบสำคัญรับเงิน" ในเอกสาร |
| RC-02 | ชื่อผู้รับเงิน (Driver) | แสดงชื่อ Driver ถูกต้อง |
| RC-03 | ชื่อผู้จ่ายเงิน (Passenger) | แสดงชื่อ Passenger ถูกต้อง |
| RC-04 | จำนวนเงินที่รับ | ตรงกับจำนวนเงินจริงที่ชำระ |
| RC-05 | รายละเอียดการชำระ (เพื่ออะไร) | แสดงรายละเอียดการเดินทาง (Route/Booking) |
| RC-06 | วันที่รับเงิน | ตรงกับวันที่ Driver ยืนยัน |
| RC-07 | ดาวน์โหลดไฟล์ได้สำเร็จ | ไฟล์ดาวน์โหลดได้ ไม่ corrupt เปิดได้ปกติ |

---

## 11. เงินสด — Test Data (Driver ออกเอกสารให้ Passenger)

**Pre-requisite:** Driver Login สำเร็จ, มี Booking ที่ Passenger ชำระเงินสดหน้างานแล้ว

### 11.1 ตรวจสอบ Auto-fill จาก Booking

| TD_ID | รายการที่ตรวจสอบ | Expected Result |
|:---:|---|---|
| CS-01 | เปิด Template — ตรวจสอบชื่อ Passenger ที่ Auto-fill มา | ชื่อตรงกับ Booking |
| CS-02 | เปิด Template — ตรวจสอบจำนวนเงินที่ Auto-fill มา | จำนวนเงินตรงกับ Booking |
| CS-03 | เปิด Template — ตรวจสอบวันที่ที่ Auto-fill มา | วันที่ตรงกับวันที่ Booking |
| CS-04 | เปิด Template — ตรวจสอบรายละเอียดบริการที่ Auto-fill มา | รายละเอียด Route/Booking ครบถ้วน |

### 11.2 Positive Case — Driver ออกเอกสารสำเร็จ

| TD_ID | การกระทำ | Expected Result |
|:---:|---|---|
| CS-05 | Driver ตรวจสอบข้อมูล Auto-fill แล้วกดออกใบกำกับภาษีอย่างย่อ | ระบบออกเอกสารสำเร็จ Passenger ดาวน์โหลดได้ |
| CS-06 | Driver ตรวจสอบข้อมูล Auto-fill แล้วกดออกใบสำคัญรับเงิน | ระบบออกเอกสารสำเร็จ Passenger ดาวน์โหลดได้ |

### 11.3 Negative Case

| TD_ID | การกระทำ | Expected Result |
|:---:|---|---|
| CS-07 | Driver พยายามออกเอกสารโดยที่ข้อมูล Booking ไม่สมบูรณ์ | ระบบไม่อนุญาต แจ้งเตือนข้อมูลไม่ครบถ้วน |
| CS-08 | Passenger พยายามดาวน์โหลดก่อน Driver กดออกเอกสาร | ปุ่มดาวน์โหลด Disabled ยังกดไม่ได้ |

---

## 12. สรุป Test Data ทั้งหมด (Test Data Summary)

| TD_ID | กลุ่ม | ประเภท | Expected Result |
|:---:|---|:---:|---|
| SL-01 | Slip Upload | Positive | อัปโหลด JPG สำเร็จ |
| SL-02 | Slip Upload | Positive | อัปโหลด PNG สำเร็จ |
| SL-03 | Slip Upload | Negative | แจ้งเตือนกรุณาอัปโหลด |
| SL-04 | Slip Upload | Negative | แจ้งเตือนประเภทไฟล์ไม่ถูกต้อง |
| SL-05 | Slip Upload | Negative | แจ้งเตือนขนาดไฟล์เกิน |
| SL-06 | Slip Upload | Negative | แจ้งเตือนประเภทไฟล์ไม่ถูกต้อง |
| DR-01 | Driver ยืนยัน (โอนเงิน) | Positive | ยืนยันสำเร็จ ปุ่มดาวน์โหลดเปิด |
| DR-02 | Driver ยืนยัน (โอนเงิน) | Negative | ไม่อนุญาตยืนยันโดยไม่มี Slip |
| BL-01 | Blocking | Negative | ปุ่มดาวน์โหลด Disabled |
| BL-02 | Blocking | Positive | ปุ่มดาวน์โหลด Active |
| TX-01 | ใบกำกับภาษีอย่างย่อ | Positive | มีคำว่า "ใบกำกับภาษีอย่างย่อ" |
| TX-02 | ใบกำกับภาษีอย่างย่อ | Positive | แสดงชื่อ/ชื่อย่อ + เลขผู้เสียภาษี Driver |
| TX-03 | ใบกำกับภาษีอย่างย่อ | Positive | แสดงเลขที่ใบกำกับภาษี |
| TX-04 | ใบกำกับภาษีอย่างย่อ | Positive | แสดงรายละเอียดบริการครบ |
| TX-05 | ใบกำกับภาษีอย่างย่อ | Positive | แสดงราคา + VAT Included |
| TX-06 | ใบกำกับภาษีอย่างย่อ | Positive | แสดงวันที่ถูกต้อง |
| TX-07 | ใบกำกับภาษีอย่างย่อ | Positive | ดาวน์โหลดได้ ไม่ corrupt |
| RC-01 | ใบสำคัญรับเงิน | Positive | มีคำว่า "ใบสำคัญรับเงิน" |
| RC-02 | ใบสำคัญรับเงิน | Positive | แสดงชื่อ Driver ถูกต้อง |
| RC-03 | ใบสำคัญรับเงิน | Positive | แสดงชื่อ Passenger ถูกต้อง |
| RC-04 | ใบสำคัญรับเงิน | Positive | แสดงจำนวนเงินถูกต้อง |
| RC-05 | ใบสำคัญรับเงิน | Positive | แสดงรายละเอียดการเดินทาง |
| RC-06 | ใบสำคัญรับเงิน | Positive | แสดงวันที่ถูกต้อง |
| RC-07 | ใบสำคัญรับเงิน | Positive | ดาวน์โหลดได้ ไม่ corrupt |
| CS-01 | เงินสด — Auto-fill | Positive | ชื่อ Passenger ตรงกับ Booking |
| CS-02 | เงินสด — Auto-fill | Positive | จำนวนเงินตรงกับ Booking |
| CS-03 | เงินสด — Auto-fill | Positive | วันที่ตรงกับ Booking |
| CS-04 | เงินสด — Auto-fill | Positive | รายละเอียดบริการครบ |
| CS-05 | เงินสด — Driver ออกเอกสาร | Positive | ออกใบกำกับภาษีอย่างย่อสำเร็จ |
| CS-06 | เงินสด — Driver ออกเอกสาร | Positive | ออกใบสำคัญรับเงินสำเร็จ |
| CS-07 | เงินสด — Driver ออกเอกสาร | Negative | ไม่อนุญาต ข้อมูล Booking ไม่สมบูรณ์ |
| CS-08 | เงินสด — Blocking | Negative | ปุ่มดาวน์โหลด Disabled ก่อน Driver ออกเอกสาร |
| **รวม** | | **32 Test Data** | |

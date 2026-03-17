# Test Data Document — PBI-16: ลบบัญชีผู้ใช้ (Delete Account)

---

## 1. บทนำ (Introduction)

### 1.1 ภาพรวมของระบบ (System Overview)

**ไปนำแหน่** เป็นเว็บแอปพลิเคชันสำหรับค้นหาและประกาศการเดินทางแบบ Carpooling ผู้ใช้งานสามารถสมัครสมาชิก เข้าสู่ระบบ ค้นหาเส้นทาง และจองการเดินทางได้ผ่านระบบออนไลน์

### 1.2 วัตถุประสงค์ในการทดสอบ (Purpose of Test)

1. เพื่อให้ผู้ใช้งาน (Passenger และ Driver) สามารถลบบัญชีของตนเองได้อย่างถูกต้องและปลอดภัย โดยต้องผ่านการยืนยันตัวตนด้วยรหัสผ่านปัจจุบัน
2. เพื่อตรวจสอบว่าระบบป้องกันไม่ให้ลบบัญชีในกรณีที่มีข้อมูลค้างอยู่ในระบบ เช่น Active Booking, Active Route หรือ Incident ที่ยังไม่ปิด
3. เพื่อตรวจสอบว่าบัญชี Admin ไม่สามารถถูกลบได้ผ่านหน้า Profile/Settings
4. เพื่อตรวจสอบพฤติกรรมของระบบหลังลบบัญชี เช่น Logout อัตโนมัติ และการป้องกัน Login กลับ

---

## 2. ขอบเขตการทดสอบ (Scope of Testing)

### 2.1 อยู่ในขอบเขต (In Scope)

- Passenger ลบบัญชีตนเอง
- Driver ลบบัญชีตนเอง
- Admin ไม่มีตัวเลือกลบบัญชี
- Validation รหัสผ่าน (ว่าง / ไม่ถูกต้อง)
- Blocking Conditions (Active Booking / Active Route / Incident ยังไม่ปิด)
- Post-Delete Behavior (Logout, Login ไม่ได้, Soft Delete 90 วัน)

### 2.2 นอกขอบเขต (Out of Scope)

- ระบบ Chat
- Login และ Register
- Performance Test
- การลบบัญชีโดย Admin (Admin ลบบัญชีผู้อื่น)

---

## 3. สภาพแวดล้อมในการทดสอบ (Testing Environment)

### 3.1 ฮาร์ดแวร์ (Hardware)

- **Model:** Apple MacBook Air (M2)
- **Processor:** Apple M2
- **RAM:** 16 GB
- **Storage:** SSD

### 3.2 ซอฟต์แวร์ (Software)

- **Operating System:** macOS
- **Browser:** Google Chrome
- **Test Server:** https://cssekku3-5.cpkku.com/

### 3.3 ผู้ทดสอบ (Human)

- **Name:** นายศุภกฤต แก้วแกมทอง

---

## 4. Test Account Information

| Role | Username | Password | Description |
|---|---|---|---|
| Passenger | TestPassenger_UAT@gmail.com | 123456789Test | ใช้ทดสอบการลบบัญชี Passenger |
| Passenger (มี Active Booking) | TestPassenger_Block@gmail.com | 123456789Test | บัญชีที่มี Booking สถานะ PENDING/CONFIRMED |
| Passenger (มี Incident ค้าง) | TestPassenger_Incident@gmail.com | 123456789Test | บัญชีที่มี Incident สถานะ PENDING |
| Driver | TestDriver_UAT | 123456789Test | ใช้ทดสอบการลบบัญชี Driver |
| Driver (มี Active Route) | TestDriver_Block@gmail.com | 123456789Test | บัญชีที่มี Route สถานะ AVAILABLE/IN_TRANSIT |
| Driver (มี Incident ค้าง) | TestDriver_Incident@gmail.com | 123456789Test | บัญชีที่มี Incident สถานะ INVESTIGATING |
| Admin | Admin_UAT | (ตามที่กำหนด) | ใช้ทดสอบว่า Admin ไม่มีตัวเลือกลบบัญชี |

---

## 5. Test Data Design

Test Data ถูกออกแบบโดยอ้างอิงจาก Test Scenario ที่กำหนดไว้ในเอกสาร Test Design PBI-16 และใช้เทคนิคการทดสอบ ได้แก่ **Equivalence Partitioning** และ **Boundary Value Analysis** เพื่อให้ครอบคลุมทั้งกรณีสำเร็จ (Positive Case) และกรณีไม่สำเร็จ (Negative Case) โดยเน้นการทดสอบ

- ความถูกต้องของรหัสผ่าน (Password Validation)
- เงื่อนไขที่ป้องกันการลบบัญชี (Blocking Conditions)
- พฤติกรรมของระบบหลังลบบัญชี (Post-Delete Behavior)
- การทำงานตามสิทธิ์ของผู้ใช้งานแต่ละประเภท (Role-based Testing)

---

## 6. Passenger — Delete Account Test Data

**Pre-requisite:** ผู้ทดสอบต้องเข้าสู่ระบบด้วยบัญชี Passenger ก่อนเริ่มการทดสอบ และต้องอยู่ในหน้า Profile/Settings

### 6.1 Positive Case

| TD_ID | Password Input | Account State | Expected Result |
|---|---|---|---|
| PA-01 | รหัสผ่านถูกต้อง (`123456789Test`) | ไม่มี Active Booking / Route / Incident | ลบบัญชีสำเร็จ, Logout อัตโนมัติ, แสดงข้อความยืนยัน |

### 6.2 Negative Case — Validation รหัสผ่าน

| TD_ID | Password Input | Account State | Expected Result |
|---|---|---|---|
| PA-02 | ว่าง (ไม่กรอก) | ปกติ | แจ้งเตือน "กรุณากรอกรหัสผ่าน" ไม่อนุญาตให้ดำเนินการ |
| PA-03 | รหัสผ่านผิด (`WrongPassword123`) | ปกติ | แจ้งเตือน "รหัสผ่านไม่ถูกต้อง" บัญชียังคงอยู่ในระบบ |
| PA-04 | รหัสผ่านผิดเพียง 1 ตัวอักษร (`123456789Tes`) | ปกติ | แจ้งเตือน "รหัสผ่านไม่ถูกต้อง" บัญชียังคงอยู่ในระบบ |

### 6.3 Negative Case — Blocking Conditions

| TD_ID | Password Input | Account State | Blocking Reason | Expected Result |
|---|---|---|---|---|
| PA-05 | รหัสผ่านถูกต้อง | มี Booking สถานะ **PENDING** | Active Booking | แจ้งเตือนไม่สามารถลบบัญชีได้ กรุณายกเลิกการจองก่อน |
| PA-06 | รหัสผ่านถูกต้อง | มี Booking สถานะ **CONFIRMED** | Active Booking | แจ้งเตือนไม่สามารถลบบัญชีได้ กรุณายกเลิกการจองก่อน |
| PA-07 | รหัสผ่านถูกต้อง | มี Incident สถานะ **PENDING** | Incident ยังไม่ปิด | แจ้งเตือนไม่สามารถลบบัญชีได้ มี Incident ที่รอดำเนินการ |
| PA-08 | รหัสผ่านถูกต้อง | มี Incident สถานะ **INVESTIGATING** | Incident ยังไม่ปิด | แจ้งเตือนไม่สามารถลบบัญชีได้ มี Incident ที่รอดำเนินการ |
| PA-09 | รหัสผ่านถูกต้อง | มี Incident สถานะ **ESCALATED** | Incident ยังไม่ปิด | แจ้งเตือนไม่สามารถลบบัญชีได้ มี Incident ที่รอดำเนินการ |

---

## 7. Driver — Delete Account Test Data

**Pre-requisite:** ผู้ทดสอบต้องเข้าสู่ระบบด้วยบัญชี Driver ก่อนเริ่มการทดสอบ และต้องอยู่ในหน้า Profile/Settings

### 7.1 Positive Case

| TD_ID | Password Input | Account State | Expected Result |
|---|---|---|---|
| DR-01 | รหัสผ่านถูกต้อง (`123456789Test`) | ไม่มี Active Route / Booking / Incident | ลบบัญชีสำเร็จ, Logout อัตโนมัติ, แสดงข้อความยืนยัน |

### 7.2 Negative Case — Validation รหัสผ่าน

| TD_ID | Password Input | Account State | Expected Result |
|---|---|---|---|
| DR-02 | ว่าง (ไม่กรอก) | ปกติ | แจ้งเตือน "กรุณากรอกรหัสผ่าน" ไม่อนุญาตให้ดำเนินการ |
| DR-03 | รหัสผ่านผิด (`WrongPassword123`) | ปกติ | แจ้งเตือน "รหัสผ่านไม่ถูกต้อง" บัญชียังคงอยู่ในระบบ |

### 7.3 Negative Case — Blocking Conditions

| TD_ID | Password Input | Account State | Blocking Reason | Expected Result |
|---|---|---|---|---|
| DR-04 | รหัสผ่านถูกต้อง | มี Route สถานะ **AVAILABLE** | Active Route | แจ้งเตือนไม่สามารถลบบัญชีได้ กรุณาปิดเส้นทางที่เปิดอยู่ก่อน |
| DR-05 | รหัสผ่านถูกต้อง | มี Route สถานะ **IN_TRANSIT** | Active Route | แจ้งเตือนไม่สามารถลบบัญชีได้ กรุณาปิดเส้นทางที่เปิดอยู่ก่อน |
| DR-06 | รหัสผ่านถูกต้อง | มี Booking สถานะ **PENDING** บน Route | Active Booking on Route | แจ้งเตือนไม่สามารถลบบัญชีได้ ยังมีการจองที่ค้างอยู่ |
| DR-07 | รหัสผ่านถูกต้อง | มี Booking สถานะ **CONFIRMED** บน Route | Active Booking on Route | แจ้งเตือนไม่สามารถลบบัญชีได้ ยังมีการจองที่ค้างอยู่ |
| DR-08 | รหัสผ่านถูกต้อง | มี Incident สถานะ **PENDING** | Incident ยังไม่ปิด | แจ้งเตือนไม่สามารถลบบัญชีได้ มี Incident ที่รอดำเนินการ |
| DR-09 | รหัสผ่านถูกต้อง | มี Incident สถานะ **INVESTIGATING** | Incident ยังไม่ปิด | แจ้งเตือนไม่สามารถลบบัญชีได้ มี Incident ที่รอดำเนินการ |
| DR-10 | รหัสผ่านถูกต้อง | มี Incident สถานะ **ESCALATED** | Incident ยังไม่ปิด | แจ้งเตือนไม่สามารถลบบัญชีได้ มี Incident ที่รอดำเนินการ |

---

## 8. Admin — Delete Account Test Data

**Pre-requisite:** ผู้ทดสอบต้องเข้าสู่ระบบด้วยบัญชี Admin และต้องอยู่ในหน้า Profile/Settings

### 8.1 Role Restriction Case

| TD_ID | Role | Action | Expected Result |
|---|---|---|---|
| AD-01 | Admin | เข้าหน้า Profile/Settings และตรวจสอบ | ไม่มีปุ่ม "ลบบัญชี" ปรากฏในหน้า Profile/Settings |

---

## 9. Post-Delete Behavior Test Data

**Pre-requisite:** ต้องทำ Test Case PA-01 หรือ DR-01 ให้สำเร็จก่อน (ลบบัญชีแล้ว)

### 9.1 Login หลังลบบัญชี

| TD_ID | Username | Password | Expected Result |
|---|---|---|---|
| PD-01 | TestPassenger_UAT@gmail.com | 123456789Test | Login ไม่ได้ แสดงข้อความ "บัญชีนี้ถูกปิดใช้งานแล้ว" หรือ "Username หรือ Password ไม่ถูกต้อง" |
| PD-02 | TestDriver_UAT | 123456789Test | Login ไม่ได้ แสดงข้อความ "บัญชีนี้ถูกปิดใช้งานแล้ว" หรือ "Username หรือ Password ไม่ถูกต้อง" |

### 9.2 Soft Delete — 90 วัน (Simulate)

| TD_ID | วิธีการ Simulate | สิ่งที่ตรวจสอบ | Expected Result |
|---|---|---|---|
| PD-03 | Dev Set `deleted_at` ย้อนหลัง 90 วัน ใน DB | ข้อมูลผู้ใช้ใน Database | ข้อมูลยังอยู่ครบก่อน Purge Job รัน |
| PD-04 | รัน Scheduled Purge Job แบบ Manual | ข้อมูลผู้ใช้ใน Database หลัง Purge | ข้อมูลผู้ใช้ถูกลบออกจาก DB ถาวร ค้นหาด้วย Username/Email ไม่พบ |
| PD-05 | หลัง Purge Job รัน | ข้อมูลที่เกี่ยวข้อง เช่น Booking History, Incident | ข้อมูลที่เกี่ยวข้องถูกจัดการตามนโยบายของระบบ (ลบหรือ Anonymize) |

---

## 10. สรุป Test Data ทั้งหมด (Test Data Summary)

| TD_ID | กลุ่ม | ประเภท | สถานะบัญชีที่ใช้ทดสอบ | Expected Result |
|---|---|---|---|---|
| PA-01 | Passenger | Positive | ปกติ ไม่มีข้อมูลค้าง | ลบสำเร็จ |
| PA-02 | Passenger | Negative (Validation) | ปกติ | แจ้งเตือน กรุณากรอกรหัสผ่าน |
| PA-03 | Passenger | Negative (Validation) | ปกติ | แจ้งเตือน รหัสผ่านไม่ถูกต้อง |
| PA-04 | Passenger | Negative (Validation) | ปกติ | แจ้งเตือน รหัสผ่านไม่ถูกต้อง |
| PA-05 | Passenger | Negative (Blocking) | มี Booking PENDING | ลบไม่ได้ |
| PA-06 | Passenger | Negative (Blocking) | มี Booking CONFIRMED | ลบไม่ได้ |
| PA-07 | Passenger | Negative (Blocking) | มี Incident PENDING | ลบไม่ได้ |
| PA-08 | Passenger | Negative (Blocking) | มี Incident INVESTIGATING | ลบไม่ได้ |
| PA-09 | Passenger | Negative (Blocking) | มี Incident ESCALATED | ลบไม่ได้ |
| DR-01 | Driver | Positive | ปกติ ไม่มีข้อมูลค้าง | ลบสำเร็จ |
| DR-02 | Driver | Negative (Validation) | ปกติ | แจ้งเตือน กรุณากรอกรหัสผ่าน |
| DR-03 | Driver | Negative (Validation) | ปกติ | แจ้งเตือน รหัสผ่านไม่ถูกต้อง |
| DR-04 | Driver | Negative (Blocking) | มี Route AVAILABLE | ลบไม่ได้ |
| DR-05 | Driver | Negative (Blocking) | มี Route IN_TRANSIT | ลบไม่ได้ |
| DR-06 | Driver | Negative (Blocking) | มี Booking PENDING บน Route | ลบไม่ได้ |
| DR-07 | Driver | Negative (Blocking) | มี Booking CONFIRMED บน Route | ลบไม่ได้ |
| DR-08 | Driver | Negative (Blocking) | มี Incident PENDING | ลบไม่ได้ |
| DR-09 | Driver | Negative (Blocking) | มี Incident INVESTIGATING | ลบไม่ได้ |
| DR-10 | Driver | Negative (Blocking) | มี Incident ESCALATED | ลบไม่ได้ |
| AD-01 | Admin | Role Restriction | Admin Account | ไม่มีปุ่มลบบัญชี |
| PD-01 | Post-Delete | Behavior | บัญชี Passenger ที่ลบแล้ว | Login ไม่ได้ |
| PD-02 | Post-Delete | Behavior | บัญชี Driver ที่ลบแล้ว | Login ไม่ได้ |
| PD-03 | Post-Delete | Soft Delete (Simulate) | DB ก่อน Purge | ข้อมูลยังอยู่ |
| PD-04 | Post-Delete | Soft Delete (Simulate) | DB หลัง Purge | ข้อมูลลบถาวร |
| PD-05 | Post-Delete | Soft Delete (Simulate) | ข้อมูลที่เกี่ยวข้อง | ถูกจัดการตามนโยบาย |
| **รวม** | | | | **25 Test Data** |

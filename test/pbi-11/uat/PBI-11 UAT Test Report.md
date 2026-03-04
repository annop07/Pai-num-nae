# Test Report – PBL-11 (Driver Incident Reporting)

## Project
Pai-Num-Nae (ไปนำแน่)

## Test Level
User Acceptance Testing (UAT)

## Tools
Robot Framework + SeleniumLibrary

## Test Date
4 มีนาคม 2026

---

## Executive Summary
การทดสอบระบบ Incident Reporting & Tracking สำหรับฝั่งคนขับ (Driver) ครอบคลุมการแจ้งเหตุ การอัปโหลดไฟล์ การตรวจสอบ Validation และการติดตามสถานะเหตุการณ์

ผลการทดสอบทั้งหมดทำงานถูกต้องตามที่ออกแบบไว้

- Test Suites: 4 ไฟล์
- Test Cases: 41
- Passed: 41
- Failed: 0

---

## Test Execution Details

### Test Account
TestDriver_UAT

| Test Suite | Module Tested | Test Cases | Passed | Failed |
|------------|--------------|------------|--------|--------|
| Test.robot | E2E แจ้งเหตุทั่วไป, Upload รูป/PDF, Validation | 13 | 13 | 0 |
| TestSituation.robot | ทดสอบแจ้งเหตุครบทุกประเภท | 14 | 14 | 0 |
| CategoryPriority.robot | ตรวจสอบ Priority ตาม Category | 7 | 7 | 0 |
| TestTracking.robot | ตรวจสอบการติดตามสถานะ | 7 | 7 | 0 |
| **Total** |  | **41** | **41** | **0** |

---

## Test Data

### Pre-condition
บัญชี TestDriver_UAT ต้องมีรายการ "เส้นทางของฉัน" อยู่ในระบบ

### Incident Test Data (Happy Path)

#### 1. ปัญหาเส้นทาง
- Title: น้ำท่วมขังบนถนนเส้นหลัก
- Description: ไม่สามารถเดินทางผ่านได้ เนื่องจากน้ำท่วมสูงกว่า 50 ซม.

#### 2. อุบัติเหตุ
- Title: รถชนบนทางด่วน
- Description: เฉี่ยวชนกับรถยนต์อีกคัน รอประกันมาเคลียร์

#### 3. ปัญหารถยนต์
- Title: ยางแตก
- Description: ยางรั่วและแตกตรงมอเตอร์เวย์

#### 4. อื่นๆ
- Title: พบสัตว์เลี้ยงบนถนน
- Description: มีสุนัขวิ่งตัดหน้าบนถนนหลวง

---

## Negative Test Cases

### Missing Image
- Expected: สามารถบันทึกได้ (รูปเป็น Optional)

### Missing Location
- Expected: สามารถบันทึกได้

### Invalid File Type
- Upload: .exe
- Expected: ระบบแจ้ง error

### Oversized File
- File > 50MB
- Expected: แจ้งเตือน "ไฟล์ต้องไม่เกิน 50MB"

### Missing Required Fields
- Expected: แจ้งเตือนให้กรอกข้อมูลให้ครบ

---

## Priority Mapping

| Category | Priority |
|----------|----------|
| ปัญหาความปลอดภัย | HIGH |
| การล่วงละเมิด | HIGH |
| การฉ้อโกง | HIGH |
| ข้อพิพาทการชำระเงิน | NORMAL |
| ลืมของ | NORMAL |
| ผู้โดยสารไม่มา | LOW |
| พฤติกรรมไม่เหมาะสม | LOW |

---

## Key Findings & Improvements

1. เพิ่ม Wait Until Element Is Visible ลดปัญหา Flaky Test
2. เพิ่มไฟล์ทดสอบสำหรับ Upload
3. เพิ่ม Test ครอบคลุมทุก Category

---

## Conclusion
ระบบสามารถใช้งานได้จริงในระดับ UAT และพร้อม Deploy
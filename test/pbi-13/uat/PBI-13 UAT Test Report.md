# Test Report – PBL-13 (Passenger Incident Reporting)

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
การทดสอบระบบแจ้งเหตุสำหรับผู้โดยสาร ครอบคลุมการแจ้งเหตุ การอัปโหลดไฟล์ Validation และการติดตามสถานะเหตุการณ์

ผลการทดสอบผ่านทั้งหมด

- Test Suites: 3 ไฟล์
- Test Cases: 28
- Passed: 28
- Failed: 0

---

## Test Execution Details

### Test Account
TestPassenger_UAT

| Test Suite | Module Tested | Test Cases | Passed | Failed |
|------------|--------------|------------|--------|--------|
| Test.robot | E2E แจ้งเหตุ + Upload + Validation | 13 | 13 | 0 |
| CategoryPriority.robot | ตรวจสอบ Priority | 8 | 8 | 0 |
| TestTracking.robot | ตรวจสอบการติดตามสถานะ | 7 | 7 | 0 |
| **Total** |  | **28** | **28** | **0** |

---

## Test Data

### Pre-condition
บัญชี TestPassenger_UAT ต้องมี Trip ที่สถานะ Confirmed

### Incident Test Data (Happy Path)

- Category: พฤติกรรมไม่เหมาะสม
- Title: คนขับขับรถเร็วเกินกำหนด
- Description: ขอให้ตักเตือนคนขับ เนื่องจากขับรถหวาดเสียว

---

## Negative Test Cases

### Missing Image
- Expected: สามารถบันทึกได้

### Missing Location
- Expected: สามารถบันทึกได้

### Invalid File Type
- Upload: .exe
- Expected: ระบบแจ้งเตือนไฟล์ไม่รองรับ

### Oversized File
- File > 50MB
- Expected: แจ้งเตือนขนาดไฟล์

### Missing Required Fields
- Expected: แจ้งเตือนให้กรอกข้อมูล

---

## Priority Mapping

| Category | Priority |
|----------|----------|
| ปัญหาความปลอดภัย | HIGH |
| การล่วงละเมิด | HIGH |
| การฉ้อโกง | HIGH |
| ข้อพิพาทการชำระเงิน | NORMAL |
| ลืมของ | NORMAL |
| คนขับไม่มาตามจุดนัด | NORMAL |
| ป้ายทะเบียนรถไม่ตรง | NORMAL |
| พฤติกรรมไม่เหมาะสม | LOW |

---

## Conclusion
ระบบทำงานถูกต้องและผ่าน UAT พร้อมใช้งานจริง
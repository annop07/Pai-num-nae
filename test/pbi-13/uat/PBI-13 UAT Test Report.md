# Test Report – PBI-13 (Passenger Incident Reporting)

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

การทดสอบระบบแจ้งเหตุสำหรับผู้โดยสาร ครอบคลุมการแจ้งเหตุ การอัปโหลดไฟล์ Validation ตำแหน่ง GPS และการติดตามสถานะเหตุการณ์

ผลการทดสอบผ่านทั้งหมด

- Test Suites: 4 ไฟล์
- Test Cases: 21
- Passed: 21
- Failed: 0

---

## Test Execution Details

### Test Account

TestPassenger_UAT

| Scenario ID                         | Scenario Name                                           | Test Case# | Pass   | Fail  | No run | Block |
| ----------------------------------- | ------------------------------------------------------- | ---------- | ------ | ----- | ------ | ----- |
| UAT-Passenger-Report-001            | ผู้โดยสารรายงานความประพฤติคนขับสำเร็จ                   | 6          | 6      | 0     | 0      | 0     |
| UAT-Passenger-Report-002            | ผู้โดยสารการตรวจสอบการกรอกข้อมูลไม่ครบถ้วน (Validation) | 7          | 7      | 0     | 0      | 0     |
| UAT-Passenger-Report-Location-001   | การรายงานคนขับพร้อมระบุตำแหน่งที่เกิดเหตุ               | 2          | 2      | 0     | 0      | 0     |
| UAT-Passenger-Incident-Priority-001 | ทดสอบประเภทปัญหาของที่ passenger และเช็คผลลัพธ์ที่แสดง  | 6          | 6      | 0     | 0      | 0     |
| **Total**                           |                                                         | **21**     | **21** | **0** | **0**  | **0** |

---

## Test Data

### Pre-condition

บัญชี TestPassenger_UAT ต้องมี Trip ที่สถานะ "ยืนยันแล้ว" (Confirmed)

### Incident Test Data (Happy Path)

- Category: การล่วงละเมิด
- Title: คนขับมีพฤติกรรมไม่เหมาะสม
- Description: พูดจาไม่สุภาพระหว่างการเดินทาง
- File Attachment: document.pdf (Optional)

---

## Negative Test Cases (UAT-Passenger-Report-002)

| Test Case            | Input                                        | Expected Result                  |
| -------------------- | -------------------------------------------- | -------------------------------- |
| ไม่เลือกประเภทปัญหา  | กรอกหัวข้อ+รายละเอียด แต่ไม่เลือก Category   | Alert: กรุณากรอกข้อมูลให้ครบถ้วน |
| ไม่กรอกหัวข้อ        | เลือก Category แต่ไม่กรอก Title              | Alert: กรุณากรอกข้อมูลให้ครบถ้วน |
| ไม่กรอกรายละเอียด    | เลือก Category+หัวข้อ แต่ไม่กรอก Description | Alert: กรุณากรอกข้อมูลให้ครบถ้วน |
| ไฟล์เกิน 50MB        | แนบไฟล์ 51MB                                 | Alert: ไฟล์ต้องไม่เกิน 50MB      |
| ไฟล์ผิดประเภท (.exe) | แนบไฟล์ .exe                                 | ระบบแจ้ง error ไม่รองรับ         |

---

## Priority Mapping (UAT-Passenger-Incident-Priority-001)

| Category            | Priority | Display     |
| ------------------- | -------- | ----------- |
| ปัญหาความปลอดภัย    | HIGH     | เร่งด่วน    |
| การล่วงละเมิด       | HIGH     | เร่งด่วน    |
| การฉ้อโกง           | HIGH     | เร่งด่วน    |
| ข้อพิพาทการชำระเงิน | NORMAL   | ปกติ        |
| ลืมของ              | NORMAL   | ปกติ        |
| คนขับไม่มาตามจุดนัด | NORMAL   | ปกติ        |
| ป้ายทะเบียนรถไม่ตรง | NORMAL   | ปกติ        |
| พฤติกรรมไม่เหมาะสม  | LOW      | ไม่เร่งด่วน |

---

## Conclusion

ระบบแจ้งเหตุฝั่งผู้โดยสารทำงานถูกต้องครบถ้วนตาม Acceptance Criteria ทุกเคส ผ่าน UAT 100% พร้อมใช้งานจริง

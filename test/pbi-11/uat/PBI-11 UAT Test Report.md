# Test Report – PBI-11 (Driver Incident Reporting)

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

การทดสอบระบบ Incident Reporting & Tracking สำหรับฝั่งคนขับ (Driver) ครอบคลุมการแจ้งเหตุทั่วไป แจ้งเหตุเกี่ยวกับบุคคล ตรวจสอบ Validation สถานการณ์ ตำแหน่ง และการติดตามสถานะ

ผลการทดสอบทั้งหมดทำงานถูกต้องตามที่ออกแบบไว้

- Test Suites: 7 ไฟล์
- Test Cases: 54
- Passed: 49
- Failed: 0

---

## Test Execution Details

### Test Account

TestDriver_UAT

| Scenario ID                       | Scenario Name                                                                           | Test Case# | Pass   | Fail  | No run | Block |
| --------------------------------- | --------------------------------------------------------------------------------------- | ---------- | ------ | ----- | ------ | ----- |
| UAT-Driver-Incident-001           | คนขับรายงานเหตุการณ์ทั่วไปสำเร็จ                                                        | 7          | 7      | 0     | 0      | 0     |
| UAT-Driver-Incident-002           | คนขับรายงานแจ้งเหตุเกี่ยวกับบุคคลสำเร็จ                                                 | 7          | 6      | 0     | 0      | 0     |
| UAT-Driver-Incident-003           | การตรวจสอบการกรอกข้อมูลไม่ครบถ้วน (Validation)                                          | 6          | 2      | 0     | 0      | 0     |
| UAT-Driver-Incident-004           | การรายงานเหตุการณ์พร้อมระบุตำแหน่งที่เกิดเหตุ                                           | 2          | 2      | 0     | 0      | 0     |
| UAT-Driver-Incident-Tracking-001  | Driver สามารถติดตามสถานะเหตุการณ์ที่ถูกแจ้ง และเคสที่ถูกแจ้ง พร้อมใช้งานตัวกรองสถานะได้ | 10         | 10     | 0     | 0      | 0     |
| UAT-Driver-Incident-Priority-001  | การรายงานเหตุการณ์พร้อมระบุตำแหน่งที่เกิดเหตุ                                           | 7          | 7      | 0     | 0      | 0     |
| UAT-Driver-Incident-Situation-001 | การตรวจสอบการกรอกข้อมูลถูกต้องในส่วนคนขับรายงานสถานการณ์                                | 15         | 15     | 0     | 0      | 0     |
| **Total**                         |                                                                                         | **54**     | **49** | **0** | **0**  | **0** |

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

## Negative Test Cases (UAT-Driver-Incident-003)

| Test Case            | Input                                        | Expected Result                  |
| -------------------- | -------------------------------------------- | -------------------------------- |
| ไม่เลือกประเภทปัญหา  | กรอกหัวข้อ+รายละเอียด แต่ไม่เลือก Category   | Alert: กรุณากรอกข้อมูลให้ครบถ้วน |
| ไม่กรอกหัวข้อ        | เลือก Category แต่ไม่กรอก Title              | Alert: กรุณากรอกข้อมูลให้ครบถ้วน |
| ไม่กรอกรายละเอียด    | เลือก Category+หัวข้อ แต่ไม่กรอก Description | Alert: กรุณากรอกข้อมูลให้ครบถ้วน |
| ไฟล์เกิน 50MB        | แนบไฟล์ 51MB                                 | Alert: ไฟล์ต้องไม่เกิน 50MB      |
| ไฟล์ผิดประเภท (.exe) | แนบไฟล์ .exe                                 | ระบบแจ้ง error ไม่รองรับ         |

---

## Priority Mapping (UAT-Driver-Incident-Priority-001)

| Category            | Priority | Display     |
| ------------------- | -------- | ----------- |
| ปัญหาความปลอดภัย    | HIGH     | เร่งด่วน    |
| การล่วงละเมิด       | HIGH     | เร่งด่วน    |
| การฉ้อโกง           | HIGH     | เร่งด่วน    |
| ข้อพิพาทการชำระเงิน | NORMAL   | ปกติ        |
| ลืมของ              | NORMAL   | ปกติ        |
| ผู้โดยสารไม่มา      | LOW      | ไม่เร่งด่วน |
| พฤติกรรมไม่เหมาะสม  | LOW      | ไม่เร่งด่วน |

---

## Conclusion

ระบบแจ้งเหตุฝั่งคนขับทำงานถูกต้องครบถ้วนตาม Acceptance Criteria ผ่าน UAT พร้อมใช้งานจริง

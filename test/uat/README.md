# วิธีการรัน Robot Framework UAT

## 1. ติดตั้ง Python และ Libraries

ต้องมี Python ติดตั้งในเครื่องก่อน จากนั้นรันคำสั่ง:

```bash
pip install -r requirements.txt
```

## 2. ติดตั้ง WebDriver

- สำหรับ Chrome: ต้องมี `chromedriver` ที่ตรงกับเวอร์ชัน Chrome ในเครื่อง
- วางไฟล์ `chromedriver.exe` ไว้ใน Path หรือโฟลเดอร์เดียวกับโปรเจกต์

## 3. การรันทดสอบ

มีการแยกไฟล์เทสออกเป็น 2 ส่วนหลัก:

- ฝั่งผู้โดยสาร/ฟอร์มแจ้งเหตุ ใช้ไฟล์ `tests.robot`
- ฝั่ง Admin Incident Management ใช้ไฟล์ `admin_tests.robot`

ตัวอย่างคำสั่งรัน:

```bash
# รันเทสฝั่งผู้โดยสาร
robot tests.robot

# รันเทสฝั่ง Admin
robot admin_tests.robot

# หรือจะรันทั้งหมดในโฟลเดอร์นี้
robot .
```

## 4. ผลลัพธ์

- หลังจากรันจบ จะได้ไฟล์ `report.html` และ `log.html` สำหรับดูผลการทดสอบ

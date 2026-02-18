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

- ฝั่งผู้โดยสาร/ฟอร์มแจ้งเหตุ/Driver ใช้ไฟล์ `tests.robot`
- ฝั่ง Admin Incident Management ใช้ไฟล์ `admin_tests.robot`

> หมายเหตุ: ค่าเริ่มต้นของ Robot จะสร้าง `report.html` / `log.html` **ในโฟลเดอร์ที่สั่งรันคำสั่งอยู่**  
> ถ้าต้องการให้ผลลัพธ์ไปอยู่ที่ `test\results` ทุกครั้ง ให้ใช้ option `-d` ตามตัวอย่างด้านล่าง

ตัวอย่างคำสั่งรัน (แนะนำให้รันจากโฟลเดอร์ `test\uat`):

```bash
cd C:\SoftwareEngineer\Pai-num-nae\test\uat

# รันเทสฝั่งผู้โดยสาร + Driver แล้วเก็บผลที่โฟลเดอร์ ..\results
robot -d ..\results tests.robot

# รันเทสฝั่ง Admin แล้วเก็บผลที่โฟลเดอร์ ..\results
robot -d ..\results admin_tests.robot

# หรือจะรันทั้งหมดในโฟลเดอร์นี้ แล้วผลไปเก็บที่ ..\results
robot -d ..\results .
```

## 4. ผลลัพธ์

- หลังจากรันจบ แล้วใช้ `-d ..\results` ตามตัวอย่างด้านบน  
  จะได้ไฟล์ `report.html` และ `log.html` อยู่ที่ `C:\SoftwareEngineer\Pai-num-nae\test\results` สำหรับดูผลการทดสอบ

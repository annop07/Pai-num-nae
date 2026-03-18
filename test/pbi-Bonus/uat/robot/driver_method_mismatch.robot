*** Settings ***
Resource          bonus_resource.robot
Test Setup        Open Browser To Login Page
Test Teardown     Close Browser Session

*** Test Cases ***
UAT-Bonus-MethodMismatch-001: Driver Confirms with Method Mismatch
    [Tags]    Success    Mismatch    Bonus
    [Documentation]    ทดสอบคนขับยืนยันหลักฐาน แม้ผู้โดยสารจะแจ้งวิธีชำระเงินไม่ตรงกับที่ได้รับจริง (เช่น แจ้งโอนแต่จ่ายสด)

    # 1. เข้าสู่ระบบด้วยบัญชีคนขับ
    Login As User    ${DRIVER_EMAIL}    ${PASSWORD}

    # 2. ไปที่หน้ารายการตรวจสอบการชำระเงิน
    Go To Check Payments

    # 3. เลือกผู้โดยสารที่ต้องการตรวจสอบ
    Go To Passenger Verification

    # 4. เลือกวิธีชำระเงินที่ได้รับจริง (เช่น CASH) และยืนยัน
    Verify Payment Flow    CASH    ได้รับเป็นเงินสดแทนหน้างานครับ

    # 5. ตรวจสอบว่าสำเร็จ
    Wait Until Page Contains    ยืนยันหลักฐานสำเร็จ    20s

UAT-Bonus-Reject-001: Driver Rejects Invalid Payment Proof
    [Tags]    Success    Reject    Bonus
    [Documentation]    ทดสอบคนขับปฏิเสธหลักฐานการชำระเงินที่ถูกต้อง (เช่น สลิปปลอม หรือยอดเงินไม่ครบ)

    # 1. เข้าสู่ระบบด้วยบัญชีคนขับ
    Login As User    ${DRIVER_EMAIL}    ${PASSWORD}

    # 2. ไปที่หน้ารายการตรวจสอบ
    Go To Check Payments

    # 3. เลือกผู้โดยสาร
    Go To Passenger Verification

    # 4. ปฏิเสธหลักฐานพร้อมระบุเหตุผล
    Reject Payment Flow    ยอดเงินไม่ถูกต้องตามที่ตกลงกันไว้ครับ

    # 5. ตรวจสอบว่าสำเร็จ
    Wait Until Page Contains    สำเร็จ    20s

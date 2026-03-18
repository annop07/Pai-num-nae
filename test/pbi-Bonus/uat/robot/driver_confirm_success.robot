*** Settings ***
Resource          bonus_resource.robot
Test Setup        Open Browser To Login Page
Test Teardown     Close Browser Session

*** Test Cases ***
UAT-Bonus-DriverConfirm-001: Driver Successfully Confirms Payment
    [Tags]    Success    Confirm    Bonus
    [Documentation]    ทดสอบคนขับยืนยันหลักฐานการชำระเงินสำเร็จ (วิธีชำระเงินตรงกัน)

    # 1. เข้าสู่ระบบด้วยบัญชีคนขับ
    Login As User    ${DRIVER_EMAIL}    ${PASSWORD}

    # 2. ไปที่หน้ารายการตรวจสอบการชำระเงิน
    Go To Check Payments

    # 3. เลือกผู้โดยสารและเข้าสู่หน้าตรวจสอบหลักฐาน (Verify Page)
    Go To Passenger Verification

    # 4. ยืนยันหลักฐานการชำระเงิน (เลือกวิธีที่ถูกต้องและกดปุ่มยืนยัน)
    # สามารถระบุเป็น Index (เช่น 1) หรือ Value (เช่น PROMPTPAY) ก็ได้
    Verify Payment Flow    PROMPTPAY

    # 5. ตรวจสอบว่ามีข้อความยืนยันความสำเร็จปรากฏขึ้นมา
    Wait Until Page Contains    ยืนยันหลักฐานสำเร็จ    20s

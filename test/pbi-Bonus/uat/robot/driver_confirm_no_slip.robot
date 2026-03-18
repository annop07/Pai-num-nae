*** Settings ***
Resource          bonus_resource.robot
Test Setup        Open Browser To Login Page
Test Teardown     Close Browser Session

*** Test Cases ***
UAT-Bonus-DriverConfirm-002: Driver Confirms Without Passenger Slip
    [Tags]    Success    NoSlip    Bonus
    [Documentation]    ทดสอบคนขับยืนยันการรับชำระเงิน ในกรณีที่ผู้โดยสารยังไม่ได้ส่งหลักฐาน (เช่น จ่ายเงินสดหน้างาน)

    # 1. เข้าสู่ระบบด้วยบัญชีคนขับ
    Login As User    ${DRIVER_EMAIL}    ${PASSWORD}

    # 2. ไปที่หน้ารายการตรวจสอบการชำระเงิน
    Go To Check Payments

    # 3. เลือกผู้โดยสารที่สถานะเป็น "รอตรวจ" (ถึงแม้จะไม่มี Slip แต่ระบบอนุญาตให้คนขับกดยืนยันได้เอง)
    Go To Passenger Verification

    # 4. ยืนยันการรับชำระเงิน (กรณีนี้อาจเลือก CASH)
    Verify Payment Flow    CASH

    # 5. ตรวจสอบว่ามีข้อความยืนยันความสำเร็จ
    Wait Until Page Contains    ยืนยันหลักฐานสำเร็จ    20s

*** Settings ***
Resource          bonus_resource.robot
Test Setup        Open Browser To Login Page
Test Teardown     Close Browser Session

*** Test Cases ***
UAT-Bonus-Cash-001: Passenger Announces Cash Payment
    [Tags]    Success    Cash    Passenger    Bonus
    [Documentation]    ทดสอบผู้โดยสารแจ้งว่าได้ชำระเงินด้วยเงินสดหน้างาน

    # 1. เข้าสู่ระบบด้วยบัญชีผู้โดยสาร
    Login As User    ${PASSENGER_EMAIL}    ${PASSWORD}

    # 2. ไปที่หน้ารายการชำระเงินของฉัน
    Go To My Payments

    # 3. คลิกปุ่มแนบหลักฐาน (เพื่อแจ้งวิธีชำระเงิน)
    Wait Until Element Is Visible    xpath=//a[contains(.,'แนบหลักฐาน')]    15s
    Click Element    xpath=//a[contains(.,'แนบหลักฐาน')]

    # 4. ส่งแจ้งว่าจ่ายเงินสด (ไม่ต้องแนบไฟล์)
    Submit Payment Proof    CASH    100    จ่ายเงินสดหน้างานครับ

    # 5. ตรวจสอบข้อความสำเร็จ
    Wait Until Page Contains    บันทึกสำเร็จ    20s

*** Settings ***
Resource          bonus_resource.robot
Test Setup        Open Browser To Login Page
Test Teardown     Close Browser Session

*** Test Cases ***
UAT-Bonus-QRCode-001: Passenger Pays via QR Code
    [Tags]    Success    QRCode    Bonus
    [Documentation]    ทดสอบผู้โดยสารชำระเงินผ่าน QR Code และส่งหลักฐาน (Slip) เข้าสู่ระบบ

    # 1. เข้าสู่ระบบด้วยบัญชีผู้โดยสาร
    Login As User    ${PASSENGER_EMAIL}    ${PASSWORD}

    # 2. ไปที่หน้ารายการชำระเงินของฉัน
    Go To My Payments

    # 3. คลิกปุ่มแนบหลักฐาน (ถ้ามีปุ่มนี้ปรากฏ)
    Wait Until Element Is Visible    xpath=//a[contains(.,'แนบหลักฐาน')]    15s
    Click Element    xpath=//a[contains(.,'แนบหลักฐาน')]

    # 4. ส่งหลักฐานการชำระเงินแบบ PROMPTPAY พร้อมแนบรูปภาพสลิป
    # (ระบบจะใช้ไฟล์ dummy slip_qr.png ที่เตรียมไว้)
    Submit Payment Proof    PROMPTPAY    100    โอนผ่าน QR เรียบร้อยแล้วครับ    ${CURDIR}/slip_qr.png

    # 5. ตรวจสอบข้อความสำเร็จ
    Wait Until Page Contains    บันทึกสำเร็จ    20s

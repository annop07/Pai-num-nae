*** Settings ***
Resource          bonus_resource.robot
Test Setup        Open Browser To Login Page
Test Teardown     Close Browser Session

*** Test Cases ***
UAT-Bonus-MultiDoc-001: Requesting and Issuing Multiple Documents
    [Documentation]    ทดสอบผู้โดยสารส่งหลักฐาน และคนขับออกเอกสาร 2 ใบ
    
    # 1. ผู้โดยสารส่งหลักฐาน
    Login As User    ${PASSENGER_EMAIL}    ${PASSWORD}
    Go To My Payments
    Submit Payment Proof    1    1000    ขอใบกำกับภาษีและใบเสร็จครับ    ${CURDIR}/slip_qr.png
    
    # ปิดเพื่อล้าง Session
    Close Browser
    
    # 2. คนขับตรวจสอบ (รอบนี้น่าจะคลิกปุ่ม ตรวจสอบการชำระเงิน ได้แล้ว)
    Open Browser To Login Page
    Login As User    ${DRIVER_EMAIL}    ${PASSWORD}
    Go To Check Payments
    Go To Passenger Verification
    Verify Payment Flow    1

    # 3. ออกเอกสารใบที่ 1
    Issue Document    1
    Wait Until Page Contains    สำเร็จ    15s
    
    Sleep    2s

    # 4. ออกเอกสารใบที่ 2
    Issue Document    2
    Wait Until Page Contains    สำเร็จ    15s
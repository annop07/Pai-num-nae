*** Settings ***
Resource          bonus_resource.robot
Test Setup        Open Browser To Login Page
Test Teardown     Close Browser Session

*** Keywords ***
Go To Passenger Verification
    # รอให้ปุ่ม "ตรวจสอบ" แสดงผล
    Wait Until Element Is Visible    xpath=//button[contains(.,'ตรวจสอบ')]    15s
    # คลิกปุ่ม "ตรวจสอบ"
    Click Element    xpath=//button[contains(.,'ตรวจสอบ')]
    # รอให้หน้าโหลดข้อมูล
    Wait Until Page Contains    ผู้โดยสารทั้งหมด    15s
    # ค้นหา link สำหรับ verify ตาม index
    ${verify_xpath}=    Set Variable    (//span[contains(.,'รอตรวจ')]/parent::div//a[contains(@href, '/verify/')])[1]
    Wait Until Element Is Visible    xpath=${verify_xpath}    15s
    Click Element    xpath=${verify_xpath}
    Wait Until Location Contains    /verify/    20s

*** Test Cases ***
UAT-Bonus-DriverConfirm-001: Driver Successfully Confirms Payment (Cash Flow)
    # -------------------------
    # STEP 2: Driver มาตรวจสอบ
    # -------------------------
    Login As User    ${DRIVER_EMAIL}    ${PASSWORD}
    Go To Check Payments
    Go To Passenger Verification
    # 🔥 ใช้ index เท่านั้น
    Verify Payment Flow    1
    Issue Document    0
    Wait Until Page Contains    สำเร็จ    20s
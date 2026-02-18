*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     SeleniumLibrary

Suite Setup     Open Browser To Login
Suite Teardown  Close Browser

*** Test Cases ***

UAT-S1-002 Driver Report Incident - Required Field Validation

    # Step 1: Login เป็น Driver
    Login As Driver
    Wait Until Page Contains    เดินทางร่วมกัน    10s

    # Step 2: เข้าเมนู การเดินทางทั้งหมด
    Wait Until Element Is Visible    xpath=//*[contains(text(),"การเดินทางทั้งหมด")]    10s
    Click Element    xpath=//*[contains(text(),"การเดินทางทั้งหมด")]

    Wait Until Element Is Visible    xpath=//*[contains(text(),"คำขอจองเส้นทางของฉัน")]    10s
    Click Element    xpath=//*[contains(text(),"คำขอจองเส้นทางของฉัน")]

    Wait Until Location Contains    /myRoute    10s

    # Step 3: เลือกแท็บ ยืนยันแล้ว
    Wait Until Element Is Visible    xpath=//button[contains(text(),"ยืนยันแล้ว")]    10s
    Click Element    xpath=//button[contains(text(),"ยืนยันแล้ว")]

    # Step 4: กด แจ้งเหตุ
    Wait Until Element Is Visible    xpath=//button[contains(text(),"แจ้งเหตุ")]    10s
    Scroll Element Into View         xpath=//button[contains(text(),"แจ้งเหตุ")]
    Click Element                    xpath=//button[contains(text(),"แจ้งเหตุ")]

    Wait Until Page Contains    แจ้งเหตุการณ์    10s

    # =====================================
    # ไม่กรอกรายละเอียดเหตุ (ปล่อย textarea ว่าง)
    # =====================================

    # กรอกเฉพาะหัวข้อ
    Wait Until Element Is Visible    xpath=//input    10s
    Input Text    xpath=//input    ทดสอบไม่กรอกรายละเอียด

    # ไม่กรอก textarea ❌

    # กด Submit
    Click Element    xpath=//button[contains(text(),"รายงาน")]

    # =====================================
    # ตรวจสอบ Validation
    # =====================================

    # ต้องมีข้อความแจ้งเตือน Required
    Wait Until Page Contains    จำเป็นต้องกรอก    10s

    # ตรวจสอบว่าไม่ redirect หน้า
    Location Should Contain    report

    Capture Page Screenshot

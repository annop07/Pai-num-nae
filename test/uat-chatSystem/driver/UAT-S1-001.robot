*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     SeleniumLibrary

Suite Setup     Open Browser To Login
Suite Teardown  Close Browser


*** Test Cases ***
UAT-S1-001 Driver Report Incident Success

    # Step 1: Login เป็น Driver
    Login As Driver
    Wait Until Page Contains    เดินทางร่วมกัน    10s

    # Step 2: เข้าเมนู การเดินทางทั้งหมด
    Wait Until Element Is Visible    xpath=//*[contains(text(),"การเดินทางทั้งหมด")]    10s
    Click Element    xpath=//*[contains(text(),"การเดินทางทั้งหมด")]

    # เลือก คำขอจองเส้นทางของฉัน
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

    # Step 5: รอหน้าแจ้งเหตุ
    Wait Until Page Contains    แจ้งเหตุการณ์    10s

    # เลือกประเภทปัญหา
    Click Element    xpath=//label[contains(text(),"ประเภทปัญหา")]/following::div[1]
    Click Element    xpath=//div[contains(text(),"พฤติกรรมไม่เหมาะสม")]

    # เลือกระดับความเร่งด่วน
    Click Element    xpath=//button[contains(text(),"ปกติ")]

    # กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength="100"]    รถเสียกลางทาง

    # กรอกรายละเอียด
    Input Text    xpath=//textarea    รถเครื่องยนต์ดับ ไม่สามารถสตาร์ทได้

    # Submit
    Click Element    xpath=//button[contains(text(),"รายงาน")]

    # ตรวจสอบ Success
    Wait Until Page Contains    ส่งข้อมูลเรียบร้อยแล้ว    15s

    Capture Page Screenshot

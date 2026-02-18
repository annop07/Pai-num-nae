*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     SeleniumLibrary

Suite Setup     Open Browser To Login
Suite Teardown  Close Browser


*** Test Cases ***
UAT-S1-003 Passenger Report Driver Incident

    # Step 1: Login เป็น Passenger
    Login As Passenger
    Wait Until Page Contains    เดินทางร่วมกัน    10s

    # Step 2: เข้าเมนู การเดินทางของฉัน
    Click Element    xpath=//*[contains(text(),"การเดินทางของฉัน")]
    Wait Until Location Contains    /myTrip    10s

    # Step 3: กดแท็บ "ยืนยันแล้ว"
    Wait Until Element Is Visible    xpath=//button[contains(text(),"ยืนยันแล้ว")]    10s
    Click Element    xpath=//button[contains(text(),"ยืนยันแล้ว")]
    Sleep    2s

    # Step 4: กดปุ่ม "แจ้งเหตุ"
    Wait Until Element Is Visible    xpath=//button[contains(text(),"แจ้งเหตุ")]    10s
    Click Element    xpath=//button[contains(text(),"แจ้งเหตุ")]

    # Step 5: รอหน้าแจ้งเหตุการณ์โหลด
    Wait Until Page Contains    แจ้งเหตุการณ์    10s

    # เลือกประเภทปัญหา
    Wait Until Element Is Visible
    ...    xpath=//label[contains(text(),"ประเภทปัญหา")]/following::div[1]
    ...    10s
    Click Element
    ...    xpath=//label[contains(text(),"ประเภทปัญหา")]/following::div[1]

    Wait Until Element Is Visible
    ...    xpath=//div[contains(text(),"พฤติกรรมไม่เหมาะสม")]
    ...    10s
    Click Element
    ...    xpath=//div[contains(text(),"พฤติกรรมไม่เหมาะสม")]

    # เลือกระดับความเร่งด่วน
    Click Element    xpath=//button[contains(text(),"ปกติ")]

    # กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength="100"]    คนขับขับรถเร็วเกินไป

    # กรอกรายละเอียด
    Input Text    xpath=//textarea    คนขับขับรถเร็วและเบรกกะทันหันหลายครั้ง

    # กดรายงาน
    Click Element    xpath=//button[contains(text(),"รายงาน")]

    # รอข้อความสำเร็จ
    Wait Until Page Contains    ส่งข้อมูลเรียบร้อยแล้ว    15s

    # กดปุ่มแชทกับ Admin
    Wait Until Element Is Visible
    ...    xpath=//button[contains(text(),"แชทกับ Admin")]
    ...    10s
    Click Element    xpath=//button[contains(text(),"แชทกับ Admin")]

    # รอเข้า /chat
    Wait Until Location Contains    /chat    10s
    Wait Until Page Contains    Inbox    10s

    Capture Page Screenshot

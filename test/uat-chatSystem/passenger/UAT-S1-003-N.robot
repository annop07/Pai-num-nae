*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     SeleniumLibrary

Suite Setup     Open Browser To Login
Suite Teardown  Close Browser


*** Test Cases ***
UAT-S1-003-N Passenger Report Driver Incident (Negative)

    Login As Passenger
    Wait Until Page Contains    เดินทางร่วมกัน    10s

    Click Element    xpath=//*[contains(text(),"การเดินทางของฉัน")]
    Wait Until Location Contains    /myTrip    10s

    Click Element    xpath=//button[contains(text(),"ยืนยันแล้ว")]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),"แจ้งเหตุ")]
    Wait Until Page Contains    แจ้งเหตุการณ์    10s


    # ================= CASE 1 =================
    Input Text    xpath=//input[@maxlength="100"]    ทดสอบหัวข้อ
    Input Text    xpath=//textarea    ทดสอบรายละเอียด
    Click Element    xpath=//button[contains(text(),"รายงาน")]

    ${alert_text}=    Handle Alert    ACCEPT
    Should Be Equal    ${alert_text}    กรุณากรอกข้อมูลให้ครบถ้วน
    Capture Page Screenshot


    # ================= CASE 2 =================
    Reload Page
    Wait Until Page Contains    แจ้งเหตุการณ์    10s

    Scroll Element Into View    xpath=//label[contains(text(),"ประเภทปัญหา")]
    Sleep    1s
    Execute JavaScript
    ...    document.evaluate('//label[contains(text(),"ประเภทปัญหา")]/following::div[1]', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();

    Click Element    xpath=//div[contains(text(),"พฤติกรรมไม่เหมาะสม")]

    ${long_text}=    Set Variable
    ...    123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345

    Input Text    xpath=//input[@maxlength="100"]    ${long_text}
    Input Text    xpath=//textarea    ทดสอบรายละเอียด
    Click Element    xpath=//button[contains(text(),"รายงาน")]

    ${alert_text}=    Handle Alert    ACCEPT
    Should Be Equal    ${alert_text}    กรุณากรอกข้อมูลให้ครบถ้วน
    Capture Page Screenshot


    # ================= CASE 3 =================
    Reload Page
    Wait Until Page Contains    แจ้งเหตุการณ์    10s

    Scroll Element Into View    xpath=//label[contains(text(),"ประเภทปัญหา")]
    Sleep    1s
    Execute JavaScript
    ...    document.evaluate('//label[contains(text(),"ประเภทปัญหา")]/following::div[1]', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();

    Click Element    xpath=//div[contains(text(),"พฤติกรรมไม่เหมาะสม")]

    Input Text    xpath=//input[@maxlength="100"]    ทดสอบหัวข้อ
    Click Element    xpath=//button[contains(text(),"รายงาน")]

    ${alert_text}=    Handle Alert    ACCEPT
    Should Be Equal    ${alert_text}    กรุณากรอกข้อมูลให้ครบถ้วน
    Capture Page Screenshot

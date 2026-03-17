*** Settings ***
Documentation     UAT - Admin Change Status (Validation Case)
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       http://localhost:3001
${BROWSER}        chrome
${USERNAME}     admin123
${PASSWORD}     Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-002
    [Documentation]    Submit โดยไม่เลือก New Status ต้องแสดง Validation Error

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]

    Wait Until Page Contains    Incident Management    10s

    # ===== เลือก Incident PENDING =====
    Wait Until Page Contains    PENDING    15s
    Click Element    xpath=//td[contains(.,'PENDING')]/following::button[contains(.,'View')][1]

    Wait Until Element Is Visible    xpath=//label[contains(.,'New Status')]    10s

    # ❌ ไม่เลือก New Status

    # เลือก Reason อย่างเดียว
    Select From List By Label
    ...    xpath=//label[contains(.,'Reason Category')]/following::select[1]
    ...    ตรวจสอบหลักฐานแล้ว

    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    ทดสอบ validation

    Click Element    xpath=//input[@type='checkbox']

    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Expected Result =====
    Wait Until Page Contains    กรุณาเลือกสถานะใหม่    5s

    Close Browser
*** Settings ***
Documentation     UAT - Admin Change Status from DISMISSED to PENDING
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       http://localhost:3001
${BROWSER}        chrome
${USERNAME}     admin123
${PASSWORD}     Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-005
    [Documentation]    เปิดเคสใหม่จาก DISMISSED เป็น PENDING

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]

    Wait Until Page Contains    Incident Management    10s

    # ===== เลือก Incident ที่เป็น DISMISSED =====
    Wait Until Page Contains    DISMISSED    15s
    Click Element    xpath=//td[contains(.,'DISMISSED')]/following::button[contains(.,'View')][1]

    # ===== รอหน้า Reopen เปิด =====
    Wait Until Page Contains    เหตุผลในการเปิดเคสใหม่    10s

    Select From List By Index
    ...    xpath=//label[contains(.,'เหตุผลในการเปิดเคสใหม่')]/following::select[1]
    ...    1


    # ===== กรอกคำอธิบาย =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    พบข้อมูลใหม่ ต้องเปิดเคสดำเนินการอีกครั้ง

    # ===== Submit =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Verify =====
    Wait Until Page Contains    PENDING    15s

    Close Browser
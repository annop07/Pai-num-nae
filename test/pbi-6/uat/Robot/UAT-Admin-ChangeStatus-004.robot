*** Settings ***
Documentation     UAT - Admin Change Status from INVESTIGATING to RESOLVED
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       http://localhost:3001
${BROWSER}        chrome
${USERNAME}     admin123
${PASSWORD}     Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-004
    [Documentation]    เปลี่ยนสถานะ Incident จาก PENDING เป็น DISMISSED

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]

    Wait Until Page Contains    Incident Management    10s

    # ===== เลือก Incident ที่เป็น PENDING =====
    Wait Until Page Contains    PENDING    15s
    Click Element    xpath=//td[contains(.,'PENDING')]/following::button[contains(.,'View')][1]

    # ===== รอ Form เปิด =====
    Wait Until Element Is Visible    xpath=//label[contains(.,'New Status')]    10s

    # ===== เลือกสถานะ DISMISSED =====
    Select From List By Label
    ...    xpath=//label[contains(.,'New Status')]/following::select[1]
    ...    DISMISSED

    # ===== เลือก Reason Category (ใช้ index กันพัง) =====
    Select From List By Index
    ...    xpath=//label[contains(.,'Reason Category')]/following::select[1]
    ...    1

    # ===== กรอกรายละเอียด =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    เคสนี้ไม่มีมูลความจริง จึงปฏิเสธเรื่องร้องเรียน

    # ===== กรอก Resolution Note =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'บันทึกภายใน')]
    ...    ปิดเคสแบบ DISMISSED

    # ===== ติ๊ก Checkbox =====
    Click Element    xpath=//input[@type='checkbox']

    # ===== Submit =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Verify Result =====
    Wait Until Page Contains    DISMISSED    15s

    Close Browser

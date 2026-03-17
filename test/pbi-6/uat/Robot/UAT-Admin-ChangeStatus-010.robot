*** Settings ***
Documentation     UAT - Admin Change Status from ESCALATED to DISMISSED
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       http://localhost:3001
${BROWSER}        chrome
${USERNAME}       admin123
${PASSWORD}       Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-010
    [Documentation]    เปลี่ยนสถานะ Incident จาก ESCALATED เป็น DISMISSED

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Page Contains    Incident Management    10s

    # ===== เลือก Incident ที่เป็น ESCALATED =====
    Wait Until Element Is Visible
    ...    xpath=//tr[td[contains(.,'ESCALATED')]]//button[contains(.,'View')]
    ...    15s

    Click Element
    ...    xpath=//tr[td[contains(.,'ESCALATED')]]//button[contains(.,'View')]

    # ===== รอ Form เปิด =====
    Wait Until Page Contains    New Status    10s

    # ===== เลือก New Status = DISMISSED =====
    Select From List By Label
    ...    xpath=//label[contains(.,'New Status')]/following::select[1]
    ...    DISMISSED

    # ===== เลือก Reason Category =====
    Select From List By Index
    ...    xpath=//label[contains(.,'Reason Category')]/following::select[1]
    ...    1

    # ===== กรอก Description =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    ตรวจสอบแล้วพบว่าไม่เข้าข่ายการดำเนินการ

    # ===== กรอก Resolution Note =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'บันทึกภายใน')]
    ...    ปิดเคสหลังการพิจารณาโดยผู้บริหาร

    # ===== ติ๊ก Checkbox =====
    Click Element    xpath=//input[@type='checkbox']

    # ===== Submit =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Verify =====
    Wait Until Page Contains    DISMISSED    15s

    Close Browser

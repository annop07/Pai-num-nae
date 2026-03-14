*** Settings ***
Documentation     UAT - Validation: Reopen RESOLVED to PENDING (Incomplete Data)
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       http://localhost:3001
${BROWSER}        chrome
${USERNAME}     admin123
${PASSWORD}     Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-007
    [Documentation]    ทดสอบกรอกข้อมูลไม่ครบในการเปิดเคส RESOLVED → PENDING

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]

    Wait Until Page Contains    Incident Management    10s

    # ===== เลือก RESOLVED =====
    Wait Until Page Contains    RESOLVED    15s
    Click Element    xpath=//td[contains(.,'RESOLVED')]/following::button[contains(.,'View')][1]

    # ===== รอหน้า Reopen =====
    Wait Until Page Contains    เหตุผลในการเปิดเคสใหม่    10s

    # ❌ ไม่เลือกเหตุผล
    # ❌ ไม่กรอกคำอธิบาย

    # ===== กด Submit ทันที =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Expected Result =====
    # ระบบยังอยู่หน้าเดิม
    Wait Until Page Contains    เหตุผลในการเปิดเคสใหม่    5s

    # ตรวจว่ามี validation แสดง (ถ้ามีข้อความ)
    # เปลี่ยนข้อความตามระบบจริงของคุณ
    Wait Until Page Contains    กรุณาเลือกเหตุผล    5s

    Close Browser

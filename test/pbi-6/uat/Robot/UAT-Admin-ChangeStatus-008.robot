*** Settings ***
Documentation     UAT - Admin Change Status from INVESTIGATING to ESCALATED
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       http://localhost:3001
${BROWSER}        chrome
${USERNAME}       admin123
${PASSWORD}       Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-008
    [Documentation]    เปลี่ยนสถานะ Incident จาก INVESTIGATING เป็น ESCALATED

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Page Contains    Incident Management    10s

    # ===== เลือก Incident ที่เป็น INVESTIGATING =====
    Wait Until Element Is Visible
    ...    xpath=//tr[td[contains(.,'INVESTIGATING')]]//button[contains(.,'View')]
    ...    15s

    Click Element
    ...    xpath=//tr[td[contains(.,'INVESTIGATING')]]//button[contains(.,'View')]

    # ===== รอ Form เปิด =====
    Wait Until Page Contains    New Status    10s

    # ===== เลือก New Status = ESCALATED =====
    Select From List By Label
    ...    xpath=//label[contains(.,'New Status')]/following::select[1]
    ...    ESCALATED

    # ===== เลือก Reason Category =====
    Select From List By Index
    ...    xpath=//label[contains(.,'Reason Category')]/following::select[1]
    ...    1

    # ===== กรอก Description =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    เคสมีความรุนแรงสูง ต้องส่งต่อหน่วยงานที่เกี่ยวข้อง

    # ===== กรอก Resolution Note =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'บันทึกภายใน')]
    ...    ส่งต่อฝ่ายบริหารระดับสูง

    # ===== ติ๊ก Checkbox =====
    Click Element    xpath=//input[@type='checkbox']

    # ===== Submit =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Verify =====
    Wait Until Page Contains    ESCALATED    15s

    Close Browser

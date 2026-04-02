*** Settings ***
Documentation     UAT - Admin Change Status from INVESTIGATING to RESOLVED
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       https://cssekku3-5.cpkku.com/
${BROWSER}        chrome
${USERNAME}       admin@painamnae.com
${PASSWORD}       Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-002
    [Documentation]    เปลี่ยนสถานะ Incident จาก INVESTIGATING เป็น RESOLVED

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Location Does Not Contain    /login    15s

    Go To    ${BASE_URL}/admin/incidents
    Wait Until Location Contains    /incidents    10s

    # ===== เลือก Incident ที่เป็น INVESTIGATING =====
    Wait Until Page Contains    กำลังตรวจสอบ    15s
    Click Element    xpath=//td[contains(.,'กำลังตรวจสอบ')]/following::button[contains(.,'ดูรายละเอียดและดำเนินการ')][1]

    # ===== รอ Form เปิด =====
    Wait Until Element Is Visible    xpath=//label[contains(.,'สถานะใหม่')]    10s

    # ===== เลือก New Status = RESOLVED =====
    Select From List By Value
    ...    xpath=//label[contains(.,'สถานะใหม่')]/following::select[1]
    ...    RESOLVED

    # ===== เลือก Reason Category =====
    Select From List By Label
    ...    xpath=//label[contains(.,'หมวดหมู่เหตุผล')]/following::select[1]
    ...    ตรวจสอบหลักฐานแล้ว

    # ===== กรอก Description =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    ดำเนินการแก้ไขเรียบร้อยแล้ว

    # ===== กรอก Resolution Note =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'บันทึกภายใน')]
    ...    ปิดงานเรียบร้อย

    # ===== ติ๊ก Checkbox =====
    Click Element    xpath=//input[@type='checkbox']

    # ===== Submit =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Verify Success =====
    Wait Until Page Contains    แก้ไขแล้ว    15s

    Close Browser
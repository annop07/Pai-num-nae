*** Settings ***
Documentation     UAT - Admin Change Status from PENDING to INVESTIGATING
Library           SeleniumLibrary

*** Variables ***
${BASE_URL}       https://cssekku3-5.cpkku.com/
${BROWSER}        chrome
${USERNAME}       admin@painamnae.com
${PASSWORD}       Admin@12345

*** Test Cases ***
UAT-Admin-ChangeStatus-001
    [Documentation]    เปลี่ยนสถานะ Incident จาก PENDING เป็น INVESTIGATING

    Open Browser    ${BASE_URL}/admin/incidents    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    xpath=//input[@type='text']    10s
    Input Text    xpath=//input[@type='text']    ${USERNAME}
    Input Text    xpath=//input[@type='password']    ${PASSWORD}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Location Does Not Contain    /login    15s

    # ===== ไปหน้า Incident Management =====
    Go To    ${BASE_URL}/admin/incidents
    Wait Until Location Contains    /incidents    10s

    # ===== เลือก Incident ที่เป็น PENDING =====
    Wait Until Page Contains    รอดำเนินการ    15s
    Click Element    xpath=//td[contains(.,'รอดำเนินการ')]/following::button[contains(.,'ดูรายละเอียดและดำเนินการ')][1]

    # ===== รอ Form เปิด =====
    Wait Until Element Is Visible    xpath=//label[contains(.,'สถานะใหม่')]    10s

    # ===== เลือก New Status =====
    Select From List By Value
    ...    xpath=//label[contains(.,'สถานะใหม่')]/following::select[1]
    ...    INVESTIGATING

    # ===== เลือก Reason Category =====
    Select From List By Label
    ...    xpath=//label[contains(.,'หมวดหมู่เหตุผล')]/following::select[1]
    ...    ตรวจสอบหลักฐานแล้ว

    # ===== กรอก Description =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    ตรวจสอบแล้ว อยู่ระหว่างดำเนินการ

    # ===== กรอก Resolution Note =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'บันทึกภายใน')]
    ...    บันทึกภายในสำหรับแอดมิน

    # ===== ติ๊ก Checkbox =====
    Click Element    xpath=//input[@type='checkbox']

    # ===== กดปุ่ม รายงาน =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== ตรวจสอบผลลัพธ์ =====
    Wait Until Page Contains    กำลังตรวจสอบ    15s

    Close Browser

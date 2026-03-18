*** Settings ***
Documentation     UAT - Admin Change Status from INVESTIGATING to RESOLVED
Library           SeleniumLibrary
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}         https://cssekku3-5.cpkku.com/
${USERNAME}         admin@painamnae.com
${PASSWORD}         Admin@12345
${CHROMEDRIVER}     C:\\Users\\porap\\.wdm\\drivers\\chromedriver\\win64\\145.0.7632.117\\chromedriver-win32\\chromedriver.exe

*** Test Cases ***
UAT-Admin-ChangeStatus-002
    [Documentation]    เปลี่ยนสถานะ Incident จาก INVESTIGATING เป็น RESOLVED

    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${service}=    Evaluate    sys.modules['selenium.webdriver.chrome.service'].Service(executable_path=r'${CHROMEDRIVER}')    sys
    Create Webdriver    Chrome    options=${options}    service=${service}
    Go To    ${BASE_URL}/login
    Maximize Browser Window
    Set Selenium Speed    0.3s

    # ===== Login =====
    Wait Until Element Is Visible    id=identifier    timeout=15s
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password    ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    timeout=15s

    # ===== ไปหน้า Incident Management =====
    Go To    ${BASE_URL}/admin/incidents
    Wait Until Page Contains    Incident Management    timeout=30s
    Sleep    3s

    # ===== เลือก Incident ที่เป็น INVESTIGATING =====
    Wait Until Element Is Visible    xpath=//td[contains(.,'INVESTIGATING')]    timeout=30s
    Sleep    1s
    Click Element    xpath=//td[contains(.,'INVESTIGATING')]/following::button[contains(.,'View')][1]

    # ===== รอ Form เปิด =====
    Wait Until Element Is Visible    xpath=//label[contains(.,'New Status')]    10s

    # ===== เลือก New Status = RESOLVED =====
    Select From List By Label
    ...    xpath=//label[contains(.,'New Status')]/following::select[1]
    ...    RESOLVED

    # ===== เลือก Reason Category =====
    Select From List By Label
    ...    xpath=//label[contains(.,'Reason Category')]/following::select[1]
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
    Wait Until Page Contains    RESOLVED    15s
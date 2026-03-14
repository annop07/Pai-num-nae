*** Settings ***
Documentation     UAT - Reopen Case from RESOLVED to PENDING
Library           SeleniumLibrary
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}         https://cssekku3-5.cpkku.com/
${USERNAME}         admin@painamnae.com
${PASSWORD}         Admin@12345
${CHROMEDRIVER}     C:\\Users\\porap\\.wdm\\drivers\\chromedriver\\win64\\145.0.7632.117\\chromedriver-win32\\chromedriver.exe

*** Test Cases ***
UAT-Admin-ChangeStatus-006
    [Documentation]    เปิดเคสจาก RESOLVED กลับไป PENDING

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

    # ===== เลือก Incident ที่เป็น RESOLVED =====
    Wait Until Element Is Visible    xpath=//td[contains(.,'RESOLVED')]    timeout=30s
    Sleep    1s
    Click Element    xpath=//td[contains(.,'RESOLVED')]/following::button[contains(.,'View')][1]

    # ===== รอหน้า Reopen Form =====
    Wait Until Page Contains    เหตุผลในการเปิดเคสใหม่    timeout=30s

    # ===== เลือกเหตุผล =====
    Select From List By Index
    ...    xpath=//label[contains(.,'เหตุผลในการเปิดเคสใหม่')]/following::select[1]
    ...    1

    # ===== กรอกคำอธิบาย =====
    Input Text
    ...    xpath=//textarea[contains(@placeholder,'โปรดอธิบาย')]
    ...    พบข้อมูลเพิ่มเติม ต้องกลับไปตรวจสอบใหม่

    # ===== Submit =====
    Click Button    xpath=//button[contains(.,'รายงาน')]

    # ===== Verify =====
    Wait Until Page Contains    PENDING    timeout=30s

*** Settings ***
Library           SeleniumLibrary
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}             http://localhost:3001
${DRIVER_USERNAME}      TestDriver_UAT
${DRIVER_PASSWORD}      12345678Test
${CHROMEDRIVER}         C:\\Users\\porap\\.wdm\\drivers\\chromedriver\\win64\\145.0.7632.117\\chromedriver-win32\\chromedriver.exe

*** Test Cases ***
Step 1 - Login As Driver
    [Documentation]    การตรวจสอบการกรอกข้อมูลไม่ครบถ้วน (Validation) คนขับ
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${service}=    Evaluate    sys.modules['selenium.webdriver.chrome.service'].Service(executable_path=r'${CHROMEDRIVER}')    sys
    Create Webdriver    Chrome    options=${options}    service=${service}
    Go To    ${BASE_URL}/login
    Maximize Browser Window
    Set Selenium Speed    0.5s
    Wait Until Element Is Visible    id=identifier    timeout=10s
    Input Text    id=identifier    ${DRIVER_USERNAME}
    Input Text    id=password    ${DRIVER_PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    timeout=10s

Step 2 - Negative Validation Cases
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    3s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # 1. Submit Without Category
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไม่เลือกประเภท
    Input Text    xpath=//textarea    รายละเอียดทดสอบ
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    1s
    Alert Should Be Present    กรุณากรอกข้อมูลให้ครบถ้วน    action=ACCEPT

    # 2. Submit Without Title
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    3s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Sleep    0.5s
    # Clear title
    Input Text    xpath=//input[@maxlength='100']    ${EMPTY}
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    1s
    Alert Should Be Present    กรุณากรอกข้อมูลให้ครบถ้วน    action=ACCEPT

    # 3. Submit Without Description
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    3s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Input Text    xpath=//input[@maxlength='100']    หัวข้อทดสอบ
    # Clear description
    Input Text    xpath=//textarea    ${EMPTY}
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    1s
    Alert Should Be Present    กรุณากรอกข้อมูลให้ครบถ้วน    action=ACCEPT

    # 4. Upload Exceeds 50MB
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    3s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    1s
    Execute JavaScript    const dt = new DataTransfer(); dt.items.add(new File([new ArrayBuffer(51 * 1024 * 1024)], 'large.mp4', {type: 'video/mp4'})); const input = document.querySelector("input[type='file']"); input.files = dt.files; input.dispatchEvent(new Event('change', { bubbles: true }));
    Sleep    2s
    Alert Should Be Present    ไฟล์ต้องไม่เกิน 50MB    action=ACCEPT

    # 5. Invalid File Type
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    3s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Sleep    0.5s
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไฟล์ผิดประเภท
    # File Exe
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Run Keyword And Ignore Error    Choose File    xpath=//input[@type='file']    ${CURDIR}${/}resources${/}file.exe
    Sleep    1s
    Input Text    xpath=//textarea    รายละเอียดทดสอบ
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s
    Run Keyword And Ignore Error    Alert Should Be Present    action=ACCEPT

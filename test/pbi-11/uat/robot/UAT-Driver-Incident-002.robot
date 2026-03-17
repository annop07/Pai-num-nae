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
    [Documentation]    คนขับรายงานแจ้งเหตุเกี่ยวกับบุคคลสำเร็จ
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

Step 2 - Navigate To My Route Requests
    Mouse Over    xpath=//a[contains(text(),'การเดินทางทั้งหมด')]
    Sleep    1s
    Click Element    xpath=//a[@href='/myRoute' and contains(text(),'คำขอจองเส้นทางของฉัน')]
    Wait Until Location Contains    /myRoute    timeout=10s

Step 3 - Click Confirmed Tab
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s

Step 4 - Click Report Incident Button
    Wait Until Element Is Visible    xpath=//button[contains(text(),'แจ้งเหตุ')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s

Step 5 - Fill Incident Form And Submit (Person)
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'เร่งด่วน')]    timeout=5s
    Input Text    xpath=//input[@maxlength='100']    ผู้โดยสารมีพฤติกรรมไม่เหมาะสม
    Input Text    xpath=//textarea    เกิดการล่วงละเมิดบนรถ
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

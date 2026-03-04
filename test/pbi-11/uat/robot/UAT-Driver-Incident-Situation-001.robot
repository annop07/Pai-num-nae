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
    [Documentation]    การตรวจสอบการกรอกข้อมูลถูกต้องในส่วนคนขับรายงานสถานการณ์
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${service}=    Evaluate    sys.modules['selenium.webdriver.chrome.service'].Service(executable_path=r'${CHROMEDRIVER}')    sys
    Create Webdriver    Chrome    options=${options}    service=${service}
    Go To    ${BASE_URL}/login
    Maximize Browser Window
    Wait Until Element Is Visible    id=identifier    timeout=10s
    Input Text    id=identifier    ${DRIVER_USERNAME}
    Input Text    id=password    ${DRIVER_PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    timeout=10s

Step 2 - Situation: Accident
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    3s
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อุบัติเหตุ')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อุบัติเหตุ')]
    Input Text    xpath=//input[@maxlength='100']    รถชนบนทางด่วน
    Input Text    xpath=//textarea    เฉี่ยวชนกับรถยนต์อีกคัน รอประกันมาเคลียร์
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 3 - Situation: Car Problem
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    3s
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]
    Input Text    xpath=//input[@maxlength='100']    ยางแตก
    Input Text    xpath=//textarea    ยางรั่วและแตกตรงมอเตอร์เวย์
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 4 - Situation: Route Problem
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    3s
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]
    Input Text    xpath=//input[@maxlength='100']    ถนนปิด
    Input Text    xpath=//textarea    ทางปิดทำถนน
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 5 - Situation: Others
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    3s
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อื่นๆ')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อื่นๆ')]
    Input Text    xpath=//input[@maxlength='100']    พบสัตว์เลี้ยงบนถนน
    Input Text    xpath=//textarea    มีสุนัขวิ่งตัดหน้าบนถนนหลวง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

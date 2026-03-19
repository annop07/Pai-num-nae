*** Settings ***
Library           SeleniumLibrary
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}             https://cssekku3-5.cpkku.com/
${DRIVER_USERNAME}      TestDriver_UAT
${DRIVER_PASSWORD}      12345678Test

*** Test Cases ***
Step 1 - Login As Driver
    [Documentation]    คนขับรายงานเหตุการณ์ทั่วไปสำเร็จ
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Create Webdriver    Chrome    options=${options}
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

Step 3 - Click My Routes Tab
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s

Step 4 - Click Report General Incident Button
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s

Step 5 - Fill General Incident Form And Submit (Happy Path)
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]
    Input Text    xpath=//input[@maxlength='100']    น้ำท่วมขังบนถนนเส้นหลัก
    Input Text    xpath=//textarea    ไม่สามารถเดินทางผ่านได้ เนื่องจากน้ำท่วมสูงกว่า 50 ซม.
    
    # อัปโหลดรูปภาพ
    Choose File    xpath=//input[@type='file']    ${CURDIR}${/}resources${/}small_image.jpg
    Sleep    1s

    # รับตำแหน่งปัจจุบัน
    Execute JavaScript    window.scrollTo(0, 600)
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

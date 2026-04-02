*** Settings ***
Library           SeleniumLibrary
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}             http://localhost:3001
${PASSENGER_USERNAME}   TestPassenger_UAT
${PASSENGER_PASSWORD}   12345678Test

*** Test Cases ***
Step 1 - Login As Passenger
    [Documentation]    การรายงานคนขับพร้อมระบุตำแหน่งที่เกิดเหตุ
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Create Webdriver    Chrome    options=${options}
    Go To    ${BASE_URL}/login
    Maximize Browser Window
    Set Selenium Speed    0.5s
    Wait Until Element Is Visible    id=identifier    timeout=10s
    Input Text    id=identifier    ${PASSENGER_USERNAME}
    Input Text    id=password    ${PASSENGER_PASSWORD}
    Sleep    1s
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    timeout=15s
    Sleep    2s

Step 2 - Navigate And Report Incident
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=15s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    3s
    Wait Until Element Is Visible    xpath=//button[contains(text(),'แจ้งเหตุ')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=15s

Step 3 - Fill Form And Get Location
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาความปลอดภัย')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาความปลอดภัย')]
    Input Text    xpath=//input[@maxlength='100']    ทดสอบขอความช่วยเหลือ
    Input Text    xpath=//textarea    รถชนแล้วคนขับทิ้งผู้โดยสาร

    # ระบุตำแหน่ง
    Execute JavaScript    window.scrollTo(0, 600)
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

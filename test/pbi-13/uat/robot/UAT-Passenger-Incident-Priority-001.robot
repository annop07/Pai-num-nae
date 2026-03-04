*** Settings ***
Library           SeleniumLibrary
Suite Setup       Login And Go To Form
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}             http://localhost:3001
${PASSENGER_USERNAME}   TestPassenger_UAT
${PASSENGER_PASSWORD}   12345678Test
${CHROMEDRIVER}         C:\\Users\\porap\\.wdm\\drivers\\chromedriver\\win64\\145.0.7632.117\\chromedriver-win32\\chromedriver.exe

*** Keywords ***
Login And Go To Form
    [Documentation]    เปิด Browser, Login ด้วย Passenger, แล้วไปหน้า formIncident
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${service}=    Evaluate    sys.modules['selenium.webdriver.chrome.service'].Service(executable_path=r'${CHROMEDRIVER}')    sys
    Create Webdriver    Chrome    options=${options}    service=${service}
    Go To    ${BASE_URL}/login
    Maximize Browser Window
    Wait Until Element Is Visible    id=identifier    timeout=10s
    Sleep    1s
    Click Element    id=identifier
    Input Text    id=identifier    ${PASSENGER_USERNAME}
    Click Element    id=password
    Input Text    id=password    ${PASSENGER_PASSWORD}
    Sleep    0.5s
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    timeout=15s
    # ไปหน้า myTrip → ยืนยันแล้ว → กดแจ้งเหตุ
    Click Element    xpath=//a[contains(text(),'การเดินทางของฉัน')]
    Wait Until Location Contains    /myTrip    timeout=10s
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

Verify Category Priority
    [Documentation]    เลือกประเภทปัญหาแล้วตรวจสอบว่าระดับความเร่งด่วนถูกต้อง
    [Arguments]    ${category}    ${expected_priority}
    # คลิกเปิด dropdown (scroll ลงก่อนเพื่อหลบ navbar แล้ว JS click)
    ${trigger}=    Get WebElement    xpath=//label[contains(text(),'ประเภทปัญหา')]/following-sibling::div[contains(@class,'cursor-pointer')]
    Execute JavaScript    JAVASCRIPT    arguments[0].scrollIntoView({block:'center'});    ARGUMENTS    ${trigger}
    Sleep    0.3s
    Execute JavaScript    JAVASCRIPT    arguments[0].click();    ARGUMENTS    ${trigger}
    Sleep    0.5s
    # เลือกประเภท (scroll เข้ามุมมองก่อนแล้ว JS click กันโดน overlay)
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'${category}')]    timeout=5s
    ${item}=    Get WebElement    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'${category}')]
    Execute JavaScript    JAVASCRIPT    arguments[0].scrollIntoView({block:'center'});    ARGUMENTS    ${item}
    Sleep    0.3s
    Execute JavaScript    JAVASCRIPT    arguments[0].click();    ARGUMENTS    ${item}
    Sleep    0.5s
    # ตรวจสอบว่า priority ถูกต้อง
    Wait Until Element Is Visible    xpath=//*[contains(text(),'${expected_priority}')]    timeout=5s

    # กรอกข้อมูลเพิ่มเติมเพื่อทดสอบการส่งฟอร์ม (End-to-End)
    Input Text    xpath=//input[@maxlength='100']    ทดสอบหมวดหมู่ ${category}
    Input Text    xpath=//textarea    ทดสอบการส่งฟอร์มด้วยหมวดหมู่ ${category} แบบ E2E
    
    # กดส่งข้อมูล
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    
    # ตรวจสอบการส่งสำเร็จ
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s
    
    # รีเฟรชหน้าเพื่อเคลียร์ฟอร์มสำหรับ Test Case ถัดไป โดยไม่ต้องกลับไปเริ่มใหม่
    Reload Page
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

*** Test Cases ***
CP-01 ปัญหาความปลอดภัย -> เร่งด่วน
    [Documentation]    ประเภท: ปัญหาความปลอดภัย → Priority: HIGH (เร่งด่วน)
    Verify Category Priority    ปัญหาความปลอดภัย    เร่งด่วน

CP-02 พฤติกรรมไม่เหมาะสม -> ไม่เร่งด่วน
    [Documentation]    ประเภท: พฤติกรรมไม่เหมาะสม → Priority: LOW (ไม่เร่งด่วน)
    Verify Category Priority    พฤติกรรมไม่เหมาะสม    ไม่เร่งด่วน

CP-03 การล่วงละเมิด -> เร่งด่วน
    [Documentation]    ประเภท: การล่วงละเมิด → Priority: HIGH (เร่งด่วน)
    Verify Category Priority    การล่วงละเมิด    เร่งด่วน

CP-06 การฉ้อโกง -> เร่งด่วน
    [Documentation]    ประเภท: การฉ้อโกง → Priority: HIGH (เร่งด่วน)
    Verify Category Priority    การฉ้อโกง    เร่งด่วน

CP-08 ข้อพิพาทการชำระเงิน -> ปกติ
    [Documentation]    ประเภท: ข้อพิพาทการชำระเงิน → Priority: NORMAL (ปกติ)
    Verify Category Priority    ข้อพิพาทการชำระเงิน    ปกติ

CP-09 ลืมของ -> ปกติ
    [Documentation]    ประเภท: ลืมของ → Priority: NORMAL (ปกติ)
    Verify Category Priority    ลืมของ    ปกติ

CP-10 คนขับไม่มาตามจุดนัด -> ปกติ
    [Documentation]    ประเภท: คนขับไม่มาตามจุดนัด → Priority: NORMAL (ปกติ)
    Verify Category Priority    คนขับไม่มาตามจุดนัด    ปกติ

CP-12 ป้ายทะเบียนรถไม่ตรง -> ปกติ
    [Documentation]    ประเภท: ป้ายทะเบียนรถไม่ตรง → Priority: NORMAL (ปกติ)
    Verify Category Priority    ป้ายทะเบียนรถไม่ตรง    ปกติ


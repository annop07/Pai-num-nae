*** Settings ***
Library           SeleniumLibrary
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}             http://localhost:3001
${DRIVER_USERNAME}      TestDriver_UAT
${DRIVER_PASSWORD}      12345678Test
${BROWSER}              chrome
${CHROMEDRIVER}         C:\\Users\\porap\\.wdm\\drivers\\chromedriver\\win64\\145.0.7632.117\\chromedriver-win32\\chromedriver.exe

*** Test Cases ***
Step 1 - Login As Driver
    [Documentation]    กรอกข้อมูลเข้าสู่ระบบด้วย TestDriver_UAT
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${service}=    Evaluate    sys.modules['selenium.webdriver.chrome.service'].Service(executable_path=r'${CHROMEDRIVER}')    sys
    Create Webdriver    Chrome    options=${options}    service=${service}
    Go To    ${BASE_URL}/login
    Maximize Browser Window
    Wait Until Element Is Visible    id=identifier    timeout=10s
    Input Text    id=identifier    ${DRIVER_USERNAME}
    Input Text    id=password    ${DRIVER_PASSWORD}
    # 3. คลิกปุ่ม "เข้าสู่ระบบ"
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    timeout=20s
    Location Should Be    ${BASE_URL}/

Step 2 - Navigate To Tracking Page
    [Documentation]    เข้าสู่หน้าติดตามสถานะแจ้งเหตุการณ์
    # รอให้หน้าโหลดเสร็จ และคลิกปุ่ม "ติดตามเหตุการณ์"
    Wait Until Element Is Visible    xpath=//a[contains(text(),'ติดตามเหตุการณ์')]    timeout=10s
    Click Element    xpath=//a[contains(text(),'ติดตามเหตุการณ์')]
    
    # ตรวจสอบว่าไปหน้า /myIncidents แล้ว
    Wait Until Location Contains    /myIncidents    timeout=10s
    
    # ตรวจสอบหัวข้อหน้า "ติดตามสถานะแจ้งเหตุการณ์"
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'ติดตามสถานะแจ้งเหตุการณ์')]    timeout=10s
    
    # ตรวจสอบแท็บ "เคสที่ฉันแจ้ง"
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เคสที่ฉันแจ้ง')]    timeout=5s

Step 3 - View Incident Details
    [Documentation]    คลิกดูรายละเอียดเคสแรกในรายการและกดปิด
    # รอให้รายการแสดงผลและคลิกรายการแรก (เจาะจงที่ส่วนการ์ด incident)
    Sleep    2s
    Wait Until Element Is Visible    xpath=(//div[contains(@class, 'hover:shadow-md') and contains(@class, 'cursor-pointer')])[1]    timeout=10s
    Click Element    xpath=(//div[contains(@class, 'hover:shadow-md') and contains(@class, 'cursor-pointer')])[1]
    
    # ตรวจสอบว่าเปิดหน้ารายละเอียด (Modal)
    Wait Until Element Is Visible    xpath=//label[contains(text(),'รายละเอียด')]    timeout=10s
    
    # รอและกดปุ่ม ปิด
    Sleep    1s
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ปิด')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ปิด')]
    
    # ตรวจสอบว่าปิด Modal แล้ว
    Wait Until Element Is Not Visible    xpath=//button[contains(text(),'ปิด')]    timeout=5s

Step 4 - Test Filter By Status
    [Documentation]    ทดสอบการทำงานของ dropdown กรองสถานะและปุ่มล้างตัวกรอง
    # 1. ทดสอบเลือก "รอดำเนินการ"
    Wait Until Element Is Visible    xpath=//select    timeout=5s
    Select From List By Value    xpath=//select    PENDING
    Sleep    1s
    
    # 2. ทดสอบเลือก "กำลังตรวจสอบ"
    Select From List By Value    xpath=//select    INVESTIGATING
    Sleep    1s
    
    # 3. ทดสอบเลือก "แก้ไขแล้ว"
    Select From List By Value    xpath=//select    RESOLVED
    Sleep    1s
    
    # 4. ทดสอบเลือก "ยกเลิก"
    Select From List By Value    xpath=//select    DISMISSED
    Sleep    1s
    
    # 5. ทดสอบเลือก "ส่งต่อ"
    Select From List By Value    xpath=//select    ESCALATED
    Sleep    1s

    # 6. ทดสอบคลิกปุ่ม "ล้างตัวกรอง"
    Click Element    xpath=//button[contains(text(),'ล้างตัวกรอง')]
    Sleep    1s
    
    # ตรวจสอบว่า select กลับไปค่า default ('')
    ${selected_value}=    Get Selected List Value    xpath=//select
    Should Be Empty    ${selected_value}

Step 5 - Navigate To Incidents Against Me
    [Documentation]    คลิกแท็บ "เคสที่ฉันถูกแจ้ง"
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เคสที่ฉันถูกแจ้ง')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'เคสที่ฉันถูกแจ้ง')]
    Sleep    2s
    
Step 6 - View Incident Details (Against Me)
    [Documentation]    คลิกดูรายละเอียดเคสแรกในรายการและกดปิด (เคสที่ถูกแจ้ง)
    # รอให้รายการแสดงผลและคลิกรายการแรก (เจาะจงที่ส่วนการ์ด incident)
    Wait Until Element Is Visible    xpath=(//div[contains(@class, 'hover:shadow-md') and contains(@class, 'cursor-pointer')])[1]    timeout=10s
    Click Element    xpath=(//div[contains(@class, 'hover:shadow-md') and contains(@class, 'cursor-pointer')])[1]
    
    # ตรวจสอบว่าเปิดหน้ารายละเอียด (Modal)
    Wait Until Element Is Visible    xpath=//label[contains(text(),'รายละเอียด')]    timeout=10s
    
    # รอและกดปุ่ม ปิด
    Sleep    1s
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ปิด')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ปิด')]
    
    # ตรวจสอบว่าปิด Modal แล้ว
    Wait Until Element Is Not Visible    xpath=//button[contains(text(),'ปิด')]    timeout=5s

Step 7 - Test Filter By Status (Against Me)
    [Documentation]    ทดสอบการทำงานของ dropdown กรองสถานะและปุ่มล้างตัวกรอง (เคสที่ถูกแจ้ง)
    # 1. ทดสอบเลือก "รอดำเนินการ"
    Wait Until Element Is Visible    xpath=//select    timeout=5s
    Select From List By Value    xpath=//select    PENDING
    Sleep    1s
    
    # 2. ทดสอบเลือก "กำลังตรวจสอบ"
    Select From List By Value    xpath=//select    INVESTIGATING
    Sleep    1s
    
    # 3. ทดสอบเลือก "แก้ไขแล้ว"
    Select From List By Value    xpath=//select    RESOLVED
    Sleep    1s
    
    # 4. ทดสอบเลือก "ยกเลิก"
    Select From List By Value    xpath=//select    DISMISSED
    Sleep    1s
    
    # 5. ทดสอบเลือก "ส่งต่อ"
    Select From List By Value    xpath=//select    ESCALATED
    Sleep    1s

    # 6. ทดสอบคลิกปุ่ม "ล้างตัวกรอง"
    Click Element    xpath=//button[contains(text(),'ล้างตัวกรอง')]
    Sleep    1s
    
    # ตรวจสอบว่า select กลับไปค่า default ('')
    ${selected_value}=    Get Selected List Value    xpath=//select
    Should Be Empty    ${selected_value}

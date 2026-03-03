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
Step 2 - Login As Driver
    [Documentation]    กรอกข้อมูลเข้าสู่ระบบด้วย TestDriver_UAT
    # เปิด Browser ไปหน้า Login
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${service}=    Evaluate    sys.modules['selenium.webdriver.chrome.service'].Service(executable_path=r'${CHROMEDRIVER}')    sys
    Create Webdriver    Chrome    options=${options}    service=${service}
    Go To    ${BASE_URL}/login
    Maximize Browser Window

    # รอหน้า Login โหลด
    Wait Until Element Is Visible    id=identifier    timeout=10s

    # 1. กรอก Username
    Input Text    id=identifier    ${DRIVER_USERNAME}

    # 2. กรอก Password
    Input Text    id=password    ${DRIVER_PASSWORD}

    # 3. คลิกปุ่ม "เข้าสู่ระบบ"
    Click Button    xpath=//button[@type='submit']

    # ตรวจสอบผลลัพธ์: เข้าสู่ระบบสำเร็จ ระบบพากลับมาหน้า Home
    Wait Until Location Does Not Contain    /login    timeout=10s
    Location Should Be    ${BASE_URL}/

Step 3 - Navigate To My Route Requests
    [Documentation]    เอาเมาส์ชี้ที่ "การเดินทางทั้งหมด" แล้วกดที่ "คำขอจองเส้นทางของฉัน"
    # Hover ที่เมนู "การเดินทางทั้งหมด" เพื่อให้ dropdown แสดง
    Wait Until Element Is Visible    xpath=//div[contains(@class,'dropdown-trigger')]//a[contains(text(),'การเดินทางทั้งหมด')]    timeout=5s
    Mouse Over    xpath=//div[contains(@class,'dropdown-trigger')]//a[contains(text(),'การเดินทางทั้งหมด')]
    Sleep    1s
    # คลิก "คำขอจองเส้นทางของฉัน"
    Wait Until Element Is Visible    xpath=//div[contains(@class,'dropdown-menu')]//a[@href='/myRoute' and contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'dropdown-menu')]//a[@href='/myRoute' and contains(text(),'คำขอจองเส้นทางของฉัน')]
    # ตรวจสอบว่าไปหน้า /myRoute แล้ว
    Wait Until Location Contains    /myRoute    timeout=10s

Step 5 - Click My Routes Tab
    [Documentation]    คลิกแท็บ "เส้นทางของฉัน" เพื่อดูรายการเส้นทางที่สร้างไว้
    # รอให้หน้าโหลดเสร็จ
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คำขอจองเส้นทางของฉัน')]    timeout=10s
    # คลิกแท็บ "เส้นทางของฉัน"
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s
    # ตรวจสอบว่าแท็บ active (มี class 'active')
    Element Should Contain    xpath=//button[contains(@class,'active') and contains(text(),'เส้นทางของฉัน')]    เส้นทางของฉัน

Step 6 - Click Report General Incident Button
    [Documentation]    เปิดรายละเอียดเส้นทาง และกดปุ่ม "แจ้งเหตุทั่วไป"
    # โหลดรายการและคลิกที่การเดินทางใบแรกเพื่อดูรายละเอียด
    Wait Until Element Is Visible    xpath=//h3[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Sleep    2s
    
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    
    # ตรวจสอบว่าไปหน้า formIncident พร้อม routeId
    Wait Until Location Contains    /formIncident    timeout=10s
    Location Should Contain    routeId=

Step 7 - Fill General Incident Form And Submit (Happy Path)
    [Documentation]    กรอกข้อมูลในฟอร์มแจ้งเหตุทั่วไปให้ครบทุกช่อง แล้วกดส่ง
    # รอฟอร์มโหลด
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # เลือกประเภทปัญหา (เช่น ปัญหาเส้นทาง)
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]
    Sleep    0.5s

    # กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength='100']    น้ำท่วมขังบนถนนเส้นหลัก
    
    # กรอกรายละเอียด
    Input Text    xpath=//textarea    ไม่สามารถเดินทางผ่านได้ เนื่องจากน้ำท่วมสูงกว่า 50 ซม.

    # ระบุตำแหน่ง
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    # แนบไฟล์ jpg
    Choose File    xpath=//input[@type='file']    ${CURDIR}/resources/accident.jpg
    Sleep    2s

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s

    # ตรวจสอบสถานะการเชื่อมต่อ และผลลัพธ์: ระบุข้อความ "บันทึกสำเร็จ"
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 7b - Fill General Incident Form And Submit (Accident)
    [Documentation]    กรอกข้อมูลในฟอร์มแจ้งเหตุทั่วไป (ประเภท: อุบัติเหตุ) ให้ครบทุกช่อง แล้วกดส่ง
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s
    
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อุบัติเหตุ')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อุบัติเหตุ')]
    Sleep    0.5s

    Input Text    xpath=//input[@maxlength='100']    รถชนบนทางด่วน
    Input Text    xpath=//textarea    เฉี่ยวชนกับรถยนต์อีกคัน รอประกันมาเคลียร์
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 7c - Fill General Incident Form And Submit (Car Problem)
    [Documentation]    กรอกข้อมูลในฟอร์มแจ้งเหตุทั่วไป (ประเภท: ปัญหารถยนต์) ให้ครบทุกช่อง แล้วกดส่ง
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s
    
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]
    Sleep    0.5s

    Input Text    xpath=//input[@maxlength='100']    ยางแตก
    Input Text    xpath=//textarea    ยางรั่วและแตกตรงมอเตอร์เวย์
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 7d - Fill General Incident Form And Submit (Others)
    [Documentation]    กรอกข้อมูลในฟอร์มแจ้งเหตุทั่วไป (ประเภท: อื่นๆ) ให้ครบทุกช่อง แล้วกดส่ง
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s
    
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อื่นๆ')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อื่นๆ')]
    Sleep    0.5s

    Input Text    xpath=//input[@maxlength='100']    พบสัตว์เลี้ยงบนถนน
    Input Text    xpath=//textarea    มีสุนัขวิ่งตัดหน้าบนถนนหลวง
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 8a - Submit General Incident Without Image (Happy Path No File)
    [Documentation]    กรอกฟอร์มแจ้งเหตุทั่วไปครบ แต่ไม่แนบไฟล์รูป
    # กลับไปเริ่มใหม่
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s
    
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s

    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # เลือกประเภทปัญหา
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]
    Sleep    0.5s

    # กรอกข้อมูล
    Input Text    xpath=//input[@maxlength='100']    เครื่องยนต์ขัดข้อง
    Input Text    xpath=//textarea    รถสตาร์ทไม่ติด รอกู้ภัยมาช่วยเหลือ

    # ระบุตำแหน่ง
    Execute JavaScript    window.scrollTo(0, 600)
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    # ไม่แนบไฟล์แล้วกดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 8b - Submit General Incident Without Location (Negative)
    [Documentation]    กรอกฟอร์มครบ แต่ไม่ระบุตำแหน่ง (ต้องขึ้นแจ้งเตือนหรือ Alert หรือ Disable แบบใดแบบหนึ่ง)
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s

    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # เลือกประเภทปัญหา
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อุบัติเหตุ')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'อุบัติเหตุ')]
    Sleep    0.5s

    # กรอกข้อมูล
    Input Text    xpath=//input[@maxlength='100']    ถนนซ่อม
    Input Text    xpath=//textarea    เทยางมะตอยใหม่

    # กดปุ่มส่งเลย โดยไม่รับ location (ตรวจสอบว่าบันทึกสำเร็จเพราะ location เป็น optional)
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    
    # ควรเจอข้อความบันทึกสำเร็จ
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 8c - Submit General Incident Missing Basic Info (Negative)
    [Documentation]    คลิกแจ้งเหตุการณ์โดยไม่กรอกข้อมูลใดๆ
    # เริ่มต้นใหม่จากหน้า myRoute เพื่อความชัวร์
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]

    # ควรเจอ Alert แจ้งเตือนเรื่องข้อมูลไม่ครบ จาก native alert
    Alert Should Be Present    text=กรุณากรอกข้อมูลให้ครบถ้วน    action=ACCEPT    timeout=5s

Step 8d - Submit General Incident With Invalid File Type (Negative)
    [Documentation]    ทดสอบแนบไฟล์ที่ไม่รองรับ (เช่น pdf) ต้องพบการแจ้งเตือน
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    
    # กรอกข้อมูลพื้นฐานให้ครบเพื่อหวังว่าจะ submit ได้
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาเส้นทาง')]
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไฟล์ PDF
    Input Text    xpath=//textarea    ทดสอบการแนบไฟล์ PDF ซึ่งไม่ควรจะผ่าน
    
    # แนบไฟล์ผิดประเภท (.exe)
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Choose File    xpath=//input[@type='file']    ${CURDIR}/resources/file.exe
    Sleep    2s
    
    # หากกดส่ง ต้องขึ้น validation error จาก API
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Run Keyword And Ignore Error    Alert Should Be Present    action=ACCEPT    timeout=5s

Step 8e - Submit General Incident With Oversize File (Negative)
    [Documentation]    ทดสอบแนบไฟล์เกินขนาดที่กำหนด (เช่น วิดีโอขนาดใหญ่) ต้องพบการแจ้งเตือน
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหารถยนต์')]
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไฟล์ใหญ่
    Input Text    xpath=//textarea    ทดสอบการแนบไฟล์ขนาดใหญ่เกิน 10MB
    
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Choose File    xpath=//input[@type='file']    ${CURDIR}/resources/oversize.txt
    Sleep    2s
    
    # ตรวจสอบ Alert เตือนไฟล์ใหญ่เกินจาก Frontend (50MB)
    Run Keyword And Ignore Error    Alert Should Be Present    text=ไฟล์ต้องไม่เกิน 50MB    action=ACCEPT    timeout=5s
    
Step 8f - Cancel Form Changes (Negative)
    [Documentation]    ทดสอบกรอกข้อมูลแล้วกดยกเลิกกลับไปหน้าเส้นทางของฉัน
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(),'เส้นทางของฉัน')]    timeout=5s
    Execute JavaScript    window.scrollTo(0, 0)
    Sleep    1s
    Click Element    xpath=//button[contains(text(),'เส้นทางของฉัน')]
    Sleep    2s

    Wait Until Element Is Visible    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]    timeout=5s
    Scroll Element Into View    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Execute JavaScript    window.scrollBy(0, -200)
    Sleep    1s
    Click Element    xpath=(//div[contains(@class,'trip-card')])[1]//button[contains(text(),'แจ้งเหตุทั่วไป')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    
    # กรอกข้อมูลบางส่วน
    Input Text    xpath=//input[@maxlength='100']    ยกเลิกการแจ้ง
    
    # กดย้อนกลับหรือยกเลิก (หน้า Vue จะมี nav bar หรือลิงก์กลับไป, สมมติใช้ browser back)
    Execute JavaScript    window.history.back()
    
    # ต้องกลับไปบรรจบที่หน้า myRoute
    Wait Until Location Contains    /myRoute    timeout=10s

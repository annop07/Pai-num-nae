*** Settings ***
Library           SeleniumLibrary
Suite Teardown    Close All Browsers

*** Variables ***
${BASE_URL}             http://localhost:3001
${PASSENGER_USERNAME}   TestPassenger_UAT
${PASSENGER_PASSWORD}   12345678Test
${BROWSER}              chrome
${CHROMEDRIVER}         C:\\Users\\porap\\.wdm\\drivers\\chromedriver\\win64\\145.0.7632.117\\chromedriver-win32\\chromedriver.exe

*** Test Cases ***
Step 2 - Login As Passenger
    [Documentation]    กรอกข้อมูลเข้าสู่ระบบด้วย TestPassenger_UAT
    # เปิด Browser ไปหน้า Login
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    ${service}=    Evaluate    sys.modules['selenium.webdriver.chrome.service'].Service(executable_path=r'${CHROMEDRIVER}')    sys
    Create Webdriver    Chrome    options=${options}    service=${service}
    Go To    ${BASE_URL}/login
    Maximize Browser Window

    # รอหน้า Login โหลด
    Wait Until Element Is Visible    id=identifier    timeout=10s

    # 1. กรอก Username
    Input Text    id=identifier    ${PASSENGER_USERNAME}

    # 2. กรอก Password
    Input Text    id=password    ${PASSENGER_PASSWORD}

    # 3. คลิกปุ่ม "เข้าสู่ระบบ"
    Click Button    xpath=//button[@type='submit']

    # ตรวจสอบผลลัพธ์: เข้าสู่ระบบสำเร็จ ระบบพากลับมาหน้า Home
    Wait Until Location Does Not Contain    /login    timeout=10s
    Location Should Be    ${BASE_URL}/

Step 3 - Navigate To My Trips
    [Documentation]    คลิกที่ "การเดินทางของฉัน" เพื่อไปหน้า myTrip
    # คลิกเมนู "การเดินทางของฉัน" (ลิงก์ตรง ไม่ใช่ dropdown)
    Click Element    xpath=//a[contains(text(),'การเดินทางของฉัน')]
    # ตรวจสอบว่าไปหน้า /myTrip แล้ว
    Wait Until Location Contains    /myTrip    timeout=10s

Step 5 - Click Confirmed Tab
    [Documentation]    คลิกแท็บ "ยืนยันแล้ว" เพื่อดูรายการที่ยืนยันแล้ว
    # รอให้หน้าโหลดเสร็จ
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    # คลิกแท็บ "ยืนยันแล้ว"
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    # ตรวจสอบว่าแท็บ active (มี class 'active')
    Element Should Contain    xpath=//button[contains(@class,'active') and contains(text(),'ยืนยันแล้ว')]    ยืนยันแล้ว

Step 6 - Click Report Incident Button
    [Documentation]    กดปุ่ม "แจ้งเหตุ" ในรายการที่ยืนยันแล้ว เพื่อไปหน้าฟอร์มแจ้งเหตุ
    # รอให้รายการโหลด
    Sleep    2s
    # คลิกปุ่ม "แจ้งเหตุ"
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    # ตรวจสอบว่าไปหน้า formIncident พร้อม bookingId
    Wait Until Location Contains    /formIncident    timeout=10s
    Location Should Contain    bookingId

Step 7 - Fill Incident Form And Submit (Happy Path)
    [Documentation]    กรอกข้อมูลในฟอร์มแจ้งเหตุให้ครบทุกช่อง แล้วกดส่ง
    # 1. ตรวจสอบว่าหน้าฟอร์มแจ้งเหตุการณ์โหลดแล้ว
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # 3. เลือกประเภทปัญหา (custom dropdown - คลิกเปิดแล้วเลือก)
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Sleep    0.5s

    # 4. ระดับความเร่งด่วน — กำหนดอัตโนมัติ (การล่วงละเมิด = เร่งด่วน)
    Wait Until Element Is Visible    xpath=//*[contains(text(),'เร่งด่วน')]    timeout=5s

    # 5. กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength='100']    รถชนท้ายบริเวณแยกไฟแดง

    # 6. กรอกรายละเอียดเหตุการณ์
    Input Text    xpath=//textarea    เกิดการล่วงละเมิดบนรถ

    # 7. ระบุตำแหน่งที่เกิดเหตุ (กดรับตำแหน่งปัจจุบัน)
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    # 8. แนบไฟล์หลักฐาน
    Choose File    xpath=//input[@type='file']    ${CURDIR}${/}resources${/}accident.jpg
    Sleep    1s

    # 9. คลิกปุ่ม รายงานเหตุการณ์
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s

    # ตรวจสอบผลลัพธ์: ระบบแสดงข้อความ "บันทึกสำเร็จ"
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 7b - Submit Without Image (Happy Path No File)
    [Documentation]    กรอกข้อมูลครบทุกช่องแต่ไม่แนบไฟล์ ยังส่งได้สำเร็จ
    # กลับไปหน้า myTrip → ยืนยันแล้ว → กดแจ้งเหตุ
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s

    # รอฟอร์มโหลด
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # เลือกประเภทปัญหา: ปัญหาความปลอดภัย
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาความปลอดภัย')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ปัญหาความปลอดภัย')]
    Sleep    0.5s

    # กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength='100']    ถนนปิดเส้นทางหลัก

    # กรอกรายละเอียด
    Input Text    xpath=//textarea    เส้นทางถูกปิดเนื่องจากงานก่อสร้าง ไม่สามารถผ่านได้

    # ระบุตำแหน่ง
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รับตำแหน่งปัจจุบัน')]
    Sleep    3s

    # ไม่แนบไฟล์ — ข้ามขั้นตอนนี้

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s

    # ตรวจสอบ: ส่งสำเร็จแม้ไม่แนบไฟล์
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

Step 7c - Submit Without Location (Happy Path No Location)
    [Documentation]    กรอกข้อมูลครบแต่ไม่ระบุตำแหน่ง ยังส่งได้สำเร็จ
    # กลับไปหน้า myTrip → ยืนยันแล้ว → กดแจ้งเหตุ
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    3s
    Wait Until Element Is Visible    xpath=//button[contains(text(),'แจ้งเหตุ')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s

    # รอฟอร์มโหลด
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # เลือกประเภทปัญหา: ข้อพิพาทการชำระเงิน
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ข้อพิพาทการชำระเงิน')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'ข้อพิพาทการชำระเงิน')]
    Sleep    0.5s

    # กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength='100']    ยางรถแบน

    # กรอกรายละเอียด
    Input Text    xpath=//textarea    ยางรถหลังขวาแบนระหว่างเดินทาง ต้องจอดข้างทาง

    # ไม่ระบุตำแหน่ง — ข้ามขั้นตอนนี้
    # ไม่แนบไฟล์ — ข้ามขั้นตอนนี้

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s

    # ตรวจสอบ: ส่งสำเร็จแม้ไม่ระบุตำแหน่ง
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

# ============================================================
#                     NEGATIVE CASES
# ============================================================

Step 8a - Submit Without Category (Negative)
    [Documentation]    ไม่เลือกประเภทปัญหา กรอกหัวข้อ+รายละเอียด → ส่งไม่ได้
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # ไม่เลือกประเภทปัญหา
    # กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไม่เลือกประเภท
    # กรอกรายละเอียด
    Input Text    xpath=//textarea    รายละเอียดทดสอบ

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    1s

    # ตรวจสอบ: ระบบแจ้งเตือน alert
    Alert Should Be Present    กรุณากรอกข้อมูลให้ครบถ้วน    action=ACCEPT

Step 8b - Submit Without Title (Negative)
    [Documentation]    เลือกประเภทแล้ว แต่ไม่กรอกหัวข้อ → ส่งไม่ได้
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # เลือกประเภทปัญหา
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Sleep    0.5s

    # ไม่กรอกหัวข้อ
    # กรอกรายละเอียด
    Input Text    xpath=//textarea    รายละเอียดทดสอบ

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    1s

    # ตรวจสอบ: ระบบแจ้งเตือน alert
    Alert Should Be Present    กรุณากรอกข้อมูลให้ครบถ้วน    action=ACCEPT

Step 8c - Submit Without Description (Negative)
    [Documentation]    เลือกประเภท+กรอกหัวข้อ แต่ไม่กรอกรายละเอียด → ส่งไม่ได้
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # เลือกประเภทปัญหา
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Sleep    0.5s

    # กรอกหัวข้อ
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไม่กรอกรายละเอียด
    # ไม่กรอกรายละเอียด

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    1s

    # ตรวจสอบ: ระบบแจ้งเตือน alert
    Alert Should Be Present    กรุณากรอกข้อมูลให้ครบถ้วน    action=ACCEPT

Step 8d - Upload File Exceeds 50MB (Negative)
    [Documentation]    แนบไฟล์ขนาดเกิน 50MB → ระบบแจ้งเตือนว่าไฟล์ต้องไม่เกิน 50MB
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    1s

    # จำลองการแนบไฟล์ขนาด 51MB ด้วย JavaScript เพื่อป้องการ browser ค้างจากการอัปโหลดไฟล์จริง
    Execute JavaScript    const dt = new DataTransfer(); dt.items.add(new File([new ArrayBuffer(51 * 1024 * 1024)], 'large.mp4', {type: 'video/mp4'})); const input = document.querySelector("input[type='file']"); input.files = dt.files; input.dispatchEvent(new Event('change', { bubbles: true }));
    Sleep    2s

    # ตรวจสอบ: ระบบแจ้งเตือน alert ว่าไฟล์เกินขนาด
    Alert Should Be Present    ไฟล์ต้องไม่เกิน 50MB    action=ACCEPT

    # ตรวจสอบ: ไฟล์ไม่ถูกเพิ่มเข้า preview (ไม่มี preview แสดง)
    Page Should Not Contain Element    xpath=//button[contains(text(),'✕')]

Step 8e - Upload Invalid File Type (Negative)
    [Documentation]    แนบไฟล์ .exe ซึ่งไม่ใช่รูปภาพหรือวิดีโอ → เมื่อกดส่งระบบจะแจ้ง error
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # กรอกข้อมูลครบ
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Sleep    0.5s
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไฟล์ผิดประเภท
    Input Text    xpath=//textarea    ทดสอบแนบไฟล์ .exe

    # แนบไฟล์ .exe (ไม่ใช่รูปหรือวิดีโอ)
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Choose File    xpath=//input[@type='file']    ${CURDIR}${/}resources${/}file.exe
    Sleep    1s

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s

    # ตรวจสอบ: ระบบจะแจ้ง error จาก backend (Only image files are allowed!)
    Alert Should Be Present    action=ACCEPT

Step 8f - Upload PDF File (Happy Path)
    [Documentation]    แนบไฟล์ .pdf ซึ่งตอนนี้ backend รองรับแล้ว → ส่งสำเร็จ
    Go To    ${BASE_URL}/myTrip
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'การเดินทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(),'ยืนยันแล้ว')]
    Sleep    2s
    Click Element    xpath=//button[contains(text(),'แจ้งเหตุ')]
    Wait Until Location Contains    /formIncident    timeout=10s
    Wait Until Element Is Visible    xpath=//h1[contains(text(),'แจ้งเหตุการณ์')]    timeout=10s
    Execute JavaScript    window.scrollTo(0, 300)
    Sleep    1s

    # กรอกข้อมูลครบ
    Click Element    xpath=//div[contains(@class,'cursor-pointer')]//span[contains(text(),'เลือกประเภทปัญหา')]
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]    timeout=5s
    Click Element    xpath=//div[contains(@class,'hover:bg-blue-50') and contains(text(),'การล่วงละเมิด')]
    Sleep    0.5s
    Input Text    xpath=//input[@maxlength='100']    ทดสอบไฟล์ PDF
    Input Text    xpath=//textarea    ทดสอบแนบไฟล์ .pdf

    # แนบไฟล์ .pdf (ตอนนี้ backend รองรับ)
    Execute JavaScript    window.scrollTo(0, 600)
    Sleep    0.5s
    Choose File    xpath=//input[@type='file']    ${CURDIR}${/}resources${/}document.pdf
    Sleep    1s

    # กดส่ง
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Click Element    xpath=//button[contains(text(),'รายงานเหตุการณ์')]
    Sleep    2s

    # ตรวจสอบ: ส่งสำเร็จ (PDF เป็นไฟล์ที่ backend รองรับแล้ว)
    Wait Until Element Is Visible    xpath=//*[contains(text(),'บันทึกสำเร็จ')]    timeout=15s

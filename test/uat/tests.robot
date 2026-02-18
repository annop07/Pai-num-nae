*** Settings ***
Library           SeleniumLibrary

Suite Setup       Open Browser To Site
Suite Teardown    Close All Browsers

*** Variables ***
${URL}            http://localhost:3001
${BROWSER}        Chrome
${EMAIL}          test1234@gmail.com
${PASSWORD}       11111111Dd
${DRIVER_EMAIL}   suphakit.xo@gmail.com
${DRIVER_PASSWORD}  11111111Dd

*** Test Cases ***
TC01 Open Website And Check Title
    [Documentation]    เปิดหน้าเว็บไซต์หลักและตรวจสอบ Title ของระบบ
    Go To    ${URL}
    Wait Until Page Contains    ไปนำแหน่    10s

TC02 Login สำเร็จด้วยบัญชี Passenger
    [Documentation]    ทดสอบการเข้าสู่ระบบด้วยบัญชี test1234@gmail.com / 11111111Dd
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    # หลังล็อกอิน ระบบจะพาไปหน้าแรก ตรวจสอบว่าหน้าแสดงคำว่า "การเดินทางของฉัน"
    Wait Until Page Contains    การเดินทางของฉัน    10s

TC03 Login ไม่สำเร็จเมื่อรหัสผ่านผิด
    [Documentation]    ทดสอบกรณีกรอกรหัสผ่านไม่ถูกต้อง และต้องมีข้อความแจ้งเตือน
    Go To    ${URL}/login
    Wait Until Page Contains Element    id=loginForm    10s
    Input Text    id=identifier    ${EMAIL}
    Input Text    id=password      11111111
    Click Button    xpath=//button[normalize-space(.)="เข้าสู่ระบบ"]
    Wait Until Page Contains    เข้าสู่ระบบไม่สำเร็จ    10s

TC04 เข้าหน้า "การเดินทางของฉัน" และเปิดฟอร์มแจ้งเหตุจากทริปที่ยืนยันแล้ว
    [Documentation]    ทดสอบ flow: Login → /myTrip → แท็บ ยืนยันแล้ว → เลือกทริป → ปุ่ม แจ้งเหตุ → หน้าแบบฟอร์มแจ้งเหตุ
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/myTrip
    # เลือกแท็บ "ยืนยันแล้ว"
    Wait Until Page Contains Element    xpath=//button[contains(., "ยืนยันแล้ว")]    10s
    Click Element    xpath=//button[contains(., "ยืนยันแล้ว")]
    # รอให้โหลดรายการเดินทาง
    Wait Until Page Contains    รายการการเดินทาง    10s
    # คลิกทริปแรกในรายการ (การ์ดการเดินทาง)
    Wait Until Page Contains Element    xpath=(//div[contains(@class, "trip-card")])[1]    10s
    Click Element    xpath=(//div[contains(@class, "trip-card")])[1]
    # ปิด Nuxt DevTools ที่บังปุ่ม (ถ้ามี)
    Hide Nuxt Devtools
    # คลิกปุ่ม "แจ้งเหตุ"
    Wait Until Page Contains Element    xpath=//button[contains(., "แจ้งเหตุ")]    10s
    Click Button    xpath=//button[contains(., "แจ้งเหตุ")]
    # ตรวจสอบว่าถูกพาไปหน้าแบบฟอร์มแจ้งเหตุ
    Wait Until Page Contains    แจ้งเหตุการณ์    10s

TC05-1 ฟอร์มแจ้งเหตุ - Validation (เว้น "ประเภทปัญหา")
    [Documentation]    กรอกครบทุกช่อง ยกเว้น "ประเภทปัญหา" แล้วต้องมี alert แจ้งเตือน
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    Prepare Alert Capture
    # ไม่เลือกประเภทปัญหา
    # เลือกระดับความเร่งด่วน "ปกติ"
    Click Button    xpath=//button[normalize-space(.)="ปกติ"]
    # กรอกหัวข้อ
    Input Text    xpath=//label[contains(., "หัวข้อ")]/following::input[1]    รถเสียกลางทาง
    # กรอกรายละเอียด
    Input Text    xpath=//label[contains(., "รายละเอียด")]/following::textarea[1]    รถเกิดปัญหาระหว่างเดินทาง ต้องการให้ช่วยประสานงาน
    # ส่งฟอร์ม
    Click Button    xpath=//button[contains(., "รายงานเหตุการณ์")]
    Wait Until Keyword Succeeds    10x    0.5s    Alert Message Should Contain    กรุณากรอกข้อมูลให้ครบถ้วน

TC05-2 ฟอร์มแจ้งเหตุ - Validation (เว้น "ระดับความเร่งด่วน")
    [Documentation]    กรอกครบทุกช่อง ยกเว้น "ระดับความเร่งด่วน" แล้วต้องมี alert แจ้งเตือน
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    Prepare Alert Capture
    # เลือกประเภทปัญหา
    Click Element    xpath=(//div[contains(@class,"cursor-pointer") and .//span[contains(., "เลือกประเภทปัญหา")]])[1]
    Wait Until Page Contains Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]    5s
    Click Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]
    # ไม่เลือกระดับความเร่งด่วน
    # กรอกหัวข้อ
    Input Text    xpath=//label[contains(., "หัวข้อ")]/following::input[1]    รถเสียกลางทาง
    # กรอกรายละเอียด
    Input Text    xpath=//label[contains(., "รายละเอียด")]/following::textarea[1]    รถเกิดปัญหาระหว่างเดินทาง ต้องการให้ช่วยประสานงาน
    # ส่งฟอร์ม
    Click Button    xpath=//button[contains(., "รายงานเหตุการณ์")]
    Wait Until Keyword Succeeds    10x    0.5s    Alert Message Should Contain    กรุณากรอกข้อมูลให้ครบถ้วน

TC05-3 ฟอร์มแจ้งเหตุ - Validation (เว้น "หัวข้อ")
    [Documentation]    กรอกครบทุกช่อง ยกเว้น "หัวข้อ" แล้วต้องมี alert แจ้งเตือน
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    Prepare Alert Capture
    # เลือกประเภทปัญหา
    Click Element    xpath=(//div[contains(@class,"cursor-pointer") and .//span[contains(., "เลือกประเภทปัญหา")]])[1]
    Wait Until Page Contains Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]    5s
    Click Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]
    # เลือกระดับความเร่งด่วน "ปกติ"
    Click Button    xpath=//button[normalize-space(.)="ปกติ"]
    # ไม่กรอกหัวข้อ
    # กรอกรายละเอียด
    Input Text    xpath=//label[contains(., "รายละเอียด")]/following::textarea[1]    รถเกิดปัญหาระหว่างเดินทาง ต้องการให้ช่วยประสานงาน
    # ส่งฟอร์ม
    Click Button    xpath=//button[contains(., "รายงานเหตุการณ์")]
    Wait Until Keyword Succeeds    10x    0.5s    Alert Message Should Contain    กรุณากรอกข้อมูลให้ครบถ้วน

TC05-4 ฟอร์มแจ้งเหตุ - Validation (เว้น "รายละเอียด")
    [Documentation]    กรอกครบทุกช่อง ยกเว้น "รายละเอียด" แล้วต้องมี alert แจ้งเตือน
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    Prepare Alert Capture
    # เลือกประเภทปัญหา
    Click Element    xpath=(//div[contains(@class,"cursor-pointer") and .//span[contains(., "เลือกประเภทปัญหา")]])[1]
    Wait Until Page Contains Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]    5s
    Click Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]
    # เลือกระดับความเร่งด่วน "ปกติ"
    Click Button    xpath=//button[normalize-space(.)="ปกติ"]
    # กรอกหัวข้อ
    Input Text    xpath=//label[contains(., "หัวข้อ")]/following::input[1]    รถเสียกลางทาง
    # ไม่กรอกรายละเอียด
    # ส่งฟอร์ม
    Click Button    xpath=//button[contains(., "รายงานเหตุการณ์")]
    Wait Until Keyword Succeeds    10x    0.5s    Alert Message Should Contain    กรุณากรอกข้อมูลให้ครบถ้วน

TC06 ฟอร์มแจ้งเหตุ - กรอกข้อมูลครบถ้วนและส่งสำเร็จ (ไม่บังคับแนบไฟล์/ตำแหน่ง)
    [Documentation]    ทดสอบการกรอกฟอร์มแจ้งเหตุให้ครบ และส่งข้อมูลสำเร็จจนขึ้น Success Modal
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    # เลือกประเภทปัญหา
    Click Element    xpath=(//div[contains(@class,"cursor-pointer") and .//span[contains(., "เลือกประเภทปัญหา")]])[1]
    Wait Until Page Contains Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]    5s
    Click Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]
    # เลือกระดับความเร่งด่วน "ปกติ"
    Click Button    xpath=//button[normalize-space(.)="ปกติ"]
    # กรอกหัวข้อ
    Input Text    xpath=//label[contains(., "หัวข้อ")]/following::input[1]    รถเสียกลางทาง
    # กรอกรายละเอียด
    Input Text    xpath=//label[contains(., "รายละเอียด")]/following::textarea[1]    รถเกิดปัญหาระหว่างเดินทาง ต้องการให้ช่วยประสานงาน
    # ส่งฟอร์ม
    Click Button    xpath=//button[contains(., "รายงานเหตุการณ์")]
    # รอ Success Modal แสดงข้อความ "ส่งข้อมูลเรียบร้อยแล้ว"
    Wait Until Page Contains    ส่งข้อมูลเรียบร้อยแล้ว    15s

TC07 ฟอร์มแจ้งเหตุ - ปุ่ม "รับตำแหน่งปัจจุบัน"
    [Documentation]    ทดสอบปุ่ม "รับตำแหน่งปัจจุบัน" ว่ามีการเริ่มดึงตำแหน่ง (ข้อความเปลี่ยนเป็น "กำลังรับตำแหน่ง...")
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    # กดปุ่ม "รับตำแหน่งปัจจุบัน"
    Click Button    xpath=//button[contains(., "รับตำแหน่งปัจจุบัน")]
    # ขณะกำลังดึงตำแหน่ง ข้อความบนปุ่มควรเปลี่ยนเป็น "กำลังรับตำแหน่ง..."
    Wait Until Page Contains    กำลังรับตำแหน่ง...    5s

TC08 ฟอร์มแจ้งเหตุ - ปฏิเสธสิทธิ์ตำแหน่ง (Location Denied)
    [Documentation]    จำลองกรณีผู้ใช้ไม่อนุญาตให้เข้าถึงตำแหน่ง แล้วต้องมีข้อความแจ้งเตือนเหมาะสม
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    Prepare Alert Capture
    # Override geolocation ให้เรียก error(code=1) ทันทีเหมือนผู้ใช้กด "ไม่อนุญาต"
    Execute Javascript    navigator.geolocation.getCurrentPosition = function(success, error){ if(error){ error({ code: 1, message: 'User denied Geolocation' }); } };
    Click Button    xpath=//button[contains(., "รับตำแหน่งปัจจุบัน")]
    Wait Until Keyword Succeeds    10x    0.5s    Alert Message Should Contain    คุณไม่อนุญาตให้เข้าถึงตำแหน่ง กรุณาเปิดสิทธิ์ในเบราว์เซอร์

TC09 ฟอร์มแจ้งเหตุ - อัปโหลดไฟล์หลักฐาน (ผ่าน)
    [Documentation]    ทดสอบการเลือกไฟล์ภาพเป็นหลักฐานแล้วมี preview แสดง และไม่ error
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    # เลือกไฟล์ภาพจากโฟลเดอร์ docs/img-formIncident
    Choose File    xpath=//input[@type="file"]    C:\\SoftwareEngineer\\Pai-num-nae\\docs\\img-formIncident\\FormIncident1.jpg
    # รอให้ preview แสดงรูปภาพอย่างน้อย 1 รูป (อาจใช้เวลาอ่านไฟล์ จึงเพิ่มเวลาเป็น 20 วินาที)
    Wait Until Page Contains Element    xpath=//div[contains(@class,"grid") and .//img]    20s

TC10 ติดตามเหตุการณ์ - เปิดหน้าติดตามจากเมนู
    [Documentation]    ทดสอบปุ่มเมนู "ติดตามเหตุการณ์" สำหรับ Passenger แล้วต้องพาไปหน้า /myIncidents
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}
    # คลิกลิงก์ "ติดตามเหตุการณ์" จากเมนู (desktop หรือ mobile ก็ได้)
    Wait Until Page Contains Element    xpath=//a[normalize-space(.)="ติดตามเหตุการณ์"]    15s
    Click Element    xpath=//a[normalize-space(.)="ติดตามเหตุการณ์"]
    # ตรวจว่าเข้าหน้า "ติดตามสถานะแจ้งเหตุการณ์"
    Wait Until Page Contains    ติดตามสถานะแจ้งเหตุการณ์    15s
    ${loc}=    Get Location
    Should Contain    ${loc}    /myIncidents

TC11 ติดตามเหตุการณ์ - ปุ่ม "แชทกับ Admin" พาไปหน้า Chat
    [Documentation]    ทดสอบปุ่ม "แชทกับ Admin" จากหน้าติดตามเหตุการณ์ ว่าสามารถเปิดหน้าระบบแชทได้
    Login With Credentials    ${EMAIL}    ${PASSWORD}
    Go To    ${URL}/myIncidents
    Wait Until Page Contains    ติดตามสถานะแจ้งเหตุการณ์    15s
    # ตรวจว่ามี incident ที่มีปุ่ม "แชทกับ Admin" ถ้าไม่มีก็ข้ามเทส
    ${has_chat}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=//button[normalize-space(.)="แชทกับ Admin"]    10s
    Run Keyword Unless    ${has_chat}    Pass Execution    ยังไม่มี incident ที่เปิดห้องแชทกับ Admin ให้ทดสอบ
    Click Button    xpath=(//button[normalize-space(.)="แชทกับ Admin"])[1]
    # ตรวจว่าเข้าหน้า Chat แล้ว (มีหัวข้อ Inbox)
    Wait Until Page Contains    Inbox    15s
    ${chat_loc}=    Get Location
    Should Contain    ${chat_loc}    /chat

TC12 Driver - เปิด "คำขอจองเส้นทางของฉัน" และฟอร์มแจ้งเหตุจากคำขอที่ยืนยันแล้ว
    [Documentation]    ทดสอบ flow ฝั่ง Driver: Login → เมนู การเดินทางทั้งหมด → คำขอจองเส้นทางของฉัน → แท็บ ยืนยันแล้ว → เลือกคำขอ → กด แจ้งเหตุ → เข้า formIncident
    Login As Driver
    Go To    ${URL}
    # เปิดเมนู "การเดินทางทั้งหมด"
    Wait Until Page Contains Element    xpath=(//*[self::button or self::a][normalize-space(.)="การเดินทางทั้งหมด"])[1]    15s
    Wait Until Element Is Visible       xpath=(//*[self::button or self::a][normalize-space(.)="การเดินทางทั้งหมด"])[1]    15s
    # เมนูนี้เป็น dropdown แบบ hover ในบางหน้าจอ → ใช้ Mouse Over เพื่อให้รายการย่อยแสดง
    Mouse Over                          xpath=(//*[self::button or self::a][normalize-space(.)="การเดินทางทั้งหมด"])[1]
    # เลือก "คำขอจองเส้นทางของฉัน"
    Wait Until Page Contains Element    xpath=//a[normalize-space(.)="คำขอจองเส้นทางของฉัน"]    10s
    Wait Until Element Is Visible       xpath=//a[normalize-space(.)="คำขอจองเส้นทางของฉัน"]    10s
    Click Element                       xpath=//a[normalize-space(.)="คำขอจองเส้นทางของฉัน"]
    # ตอนนี้อยู่หน้า /myRoute
    Wait Until Page Contains    คำขอจองเส้นทางของฉัน    15s
    ${loc_driver}=    Get Location
    Should Contain    ${loc_driver}    /myRoute
    # เลือกแท็บ "ยืนยันแล้ว" (อาจต้องเลื่อนลงก่อน)
    Wait Until Page Contains Element    xpath=//button[contains(., "ยืนยันแล้ว")]    15s
    Scroll Element Into View            xpath=//button[contains(., "ยืนยันแล้ว")]
    Click Element                       xpath=//button[contains(., "ยืนยันแล้ว")]
    # ต้องมีคำขอที่ยืนยันแล้วอย่างน้อย 1 รายการ
    ${has_confirmed}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=(//div[contains(@class,"trip-card")])[1]    20s
    Run Keyword Unless    ${has_confirmed}    Pass Execution    ยังไม่มีคำขอจองสถานะยืนยันแล้วให้ทดสอบ
    # คลิกการ์ดคำขอแรก (เพื่อให้รายละเอียดขึ้น)
    Scroll Element Into View            xpath=(//div[contains(@class,"trip-card")])[1]
    Click Element                       xpath=(//div[contains(@class,"trip-card")])[1]
    # คลิกปุ่ม "แจ้งเหตุ" ของคำขอ status confirmed (ต้องเลื่อน + ซ่อน Nuxt DevTools ที่บัง)
    Wait Until Page Contains Element    xpath=//button[normalize-space(.)="แจ้งเหตุ"]    10s
    Scroll Element Into View            xpath=(//button[normalize-space(.)="แจ้งเหตุ"])[1]
    Hide Nuxt Devtools
    Click Button                        xpath=(//button[normalize-space(.)="แจ้งเหตุ"])[1]
    # ตรวจว่าถูกพาไปหน้าแบบฟอร์มแจ้งเหตุ
    Wait Until Page Contains    แจ้งเหตุการณ์    15s

TC13 Driver - ฟอร์มแจ้งเหตุจากฝั่งคนขับ (กรอกครบและส่งสำเร็จ)
    [Documentation]    ทดสอบการกรอกฟอร์มแจ้งเหตุจาก flow คนขับให้ครบ และส่งสำเร็จจนขึ้น Success Modal
    Login As Driver
    Go To    ${URL}/formIncident
    Wait Until Page Contains    แจ้งเหตุการณ์    10s
    # เลือกประเภทปัญหา
    Click Element    xpath=(//div[contains(@class,"cursor-pointer") and .//span[contains(., "เลือกประเภทปัญหา")]])[1]
    Wait Until Page Contains Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]    5s
    Click Element    xpath=//div[contains(@class,"cursor-pointer") and normalize-space(.)="ปัญหาความปลอดภัย"]
    # เลือกระดับความเร่งด่วน "ปกติ"
    Click Button    xpath=//button[normalize-space(.)="ปกติ"]
    # กรอกหัวข้อ
    Input Text    xpath=//label[contains(., "หัวข้อ")]/following::input[1]    เหตุการณ์จากฝั่งคนขับ
    # กรอกรายละเอียด
    Input Text    xpath=//label[contains(., "รายละเอียด")]/following::textarea[1]    ทดสอบการแจ้งเหตุจากฝั่งคนขับผ่าน Robot Framework
    # ส่งฟอร์ม
    Click Button    xpath=//button[contains(., "รายงานเหตุการณ์")]
    # รอ Success Modal แสดงข้อความ "ส่งข้อมูลเรียบร้อยแล้ว"
    Wait Until Page Contains    ส่งข้อมูลเรียบร้อยแล้ว    20s

TC14 Driver - เปิดหน้าติดตามเหตุการณ์จากเมนู
    [Documentation]    ทดสอบปุ่มเมนู "ติดตามเหตุการณ์" สำหรับ Driver แล้วต้องพาไปหน้า /myIncidents
    Login As Driver
    Go To    ${URL}
    # คลิกลิงก์ "ติดตามเหตุการณ์" จากเมนูบน
    Wait Until Page Contains Element    xpath=//a[normalize-space(.)="ติดตามเหตุการณ์"]    15s
    Click Element    xpath=//a[normalize-space(.)="ติดตามเหตุการณ์"]
    # ตรวจว่าเข้าหน้า "ติดตามสถานะแจ้งเหตุการณ์"
    Wait Until Page Contains    ติดตามสถานะแจ้งเหตุการณ์    15s
    ${driver_inc_loc}=    Get Location
    Should Contain    ${driver_inc_loc}    /myIncidents

TC15 Driver - ปุ่ม "แชทกับ Admin" จากหน้าติดตามเหตุการณ์
    [Documentation]    ทดสอบปุ่ม "แชทกับ Admin" สำหรับ Driver บนหน้า /myIncidents ว่าสามารถเปิดหน้าระบบแชทได้
    Login As Driver
    Go To    ${URL}/myIncidents
    Wait Until Page Contains    ติดตามสถานะแจ้งเหตุการณ์    15s
    # ตรวจว่ามี incident ที่มีปุ่ม "แชทกับ Admin" ถ้าไม่มีก็ข้ามเทส
    ${d_has_chat}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=//button[normalize-space(.)="แชทกับ Admin"]    10s
    Run Keyword Unless    ${d_has_chat}    Pass Execution    (Driver) ยังไม่มี incident ที่เปิดห้องแชทกับ Admin ให้ทดสอบ
    Click Button    xpath=(//button[normalize-space(.)="แชทกับ Admin"])[1]
    # ตรวจว่าเข้าหน้า Chat แล้ว (มีหัวข้อ Inbox)
    Wait Until Page Contains    Inbox    15s
    ${d_chat_loc}=    Get Location
    Should Contain    ${d_chat_loc}    /chat


*** Keywords ***
Open Browser To Site
    Open Browser    about:blank    ${BROWSER}
    Maximize Browser Window

Login With Credentials
    [Arguments]    ${email}    ${password}
    Go To    ${URL}/login
    Wait Until Page Contains Element    id=loginForm    10s
    Input Text    id=identifier    ${email}
    Input Text    id=password      ${password}
    Click Button    xpath=//button[normalize-space(.)="เข้าสู่ระบบ"]

Login As Driver
    [Documentation]    ล็อกอินด้วยบัญชี Driver
    Go To    ${URL}/login
    Wait Until Page Contains Element    id=loginForm    15s
    Input Text    id=identifier    ${DRIVER_EMAIL}
    Input Text    id=password      ${DRIVER_PASSWORD}
    Click Button    xpath=//button[normalize-space(.)="เข้าสู่ระบบ"]
    Wait Until Page Contains Element    xpath=(//*[self::button or self::a][normalize-space(.)="การเดินทางทั้งหมด"])[1]    15s

Location Name Should Not Be Empty
    ${text}=    Get Text    xpath=//div[contains(@class,"border-2") and contains(., "สถานที่เกิดเหตุ")]//span[contains(@class,"truncate")]
    Should Not Be Empty    ${text}

Hide Nuxt Devtools
    # ซ่อน/ลบ nuxt-devtools-frame ที่บังปุ่มคลิก (หากมี)
    Execute Javascript    var el = document.querySelector('nuxt-devtools-frame'); if (el) { el.remove(); }

Prepare Alert Capture
    # Override window.alert เพื่อเก็บข้อความล่าสุดไว้ตรวจสอบในเทส
    Execute Javascript    window.__lastAlertMessage = null; window.alert = function(msg){ window.__lastAlertMessage = msg; };

Alert Message Should Contain
    [Arguments]    ${expected}
    ${text}=    Execute Javascript    return window.__lastAlertMessage;
    Should Not Be Empty    ${text}
    Should Contain    ${text}    ${expected}

Open Admin Incident Management
    [Documentation]    ไปยังหน้า Incident Management สำหรับ Admin
    Go To    ${URL}/admin/incidents
    Wait Until Page Contains    Incident Management    15s

Incident Status Should Be
    [Arguments]    ${expected}
    ${label}=    Get Selected List Label    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//select[@class="status-pill"])[1]
    Should Be Equal    ${label}    ${expected}

*** Settings ***
Library           SeleniumLibrary

Suite Setup       Open Browser To Site
Suite Teardown    Close All Browsers
Test Setup        Reset Auth State

*** Variables ***
${URL}             http://localhost:3001
${BROWSER}         Chrome
${ADMIN_EMAIL}     admin@example.com
${ADMIN_PASSWORD}  123456789
${USER_EMAIL}      test1234@gmail.com
${USER_PASSWORD}   11111111Dd

*** Test Cases ***
TC_ADMIN_01 Login Admin และเปิดหน้า Incident Management
    [Documentation]    ทดสอบการเข้าสู่ระบบ Admin และเข้าเมนู Incident Management
    Login As Admin
    # หลังล็อกอินควรไปหน้าแรก แล้วใช้เมนู Dashboard → เข้าสู่หน้า Admin
    Go To    ${URL}
    Wait Until Page Contains    เดินทางร่วมกัน    15s
    # เปิด dropdown โปรไฟล์ (admin)
    Wait Until Page Contains Element    xpath=(//div[contains(@class,"dropdown-trigger")]//span[contains(@class,"font-medium")])[last()]    15s
    Click Element    xpath=(//div[contains(@class,"dropdown-trigger")]//span[contains(@class,"font-medium")])[last()]
    # คลิก Dashboard
    Wait Until Page Contains Element    xpath=//a[normalize-space(.)="Dashboard"]    10s
    Click Element    xpath=//a[normalize-space(.)="Dashboard"]
    # ยืนยันว่าเข้าหน้า User Management (dashboard admin)
    Wait Until Page Contains    User Management    15s
    # จาก sidebar ไป Incident Management
    Wait Until Page Contains Element    xpath=//aside[@id="sidebar"]//span[normalize-space(.)="Incidents Management"]    15s
    Click Element    xpath=//aside[@id="sidebar"]//span[normalize-space(.)="Incidents Management"]/ancestor::a[1]
    Wait Until Page Contains    Incident Management    15s

TC_ADMIN_02 Incident Management - อัปเดตสถานะจากตาราง
    [Documentation]    ทดสอบการเปลี่ยนค่า Status ของ Incident แถวแรกผ่าน dropdown แล้วต้องบันทึกสำเร็จ
    Login As Admin
    Open Admin Incident Management
    # ตรวจว่ามีอย่างน้อย 1 แถวให้ทดสอบ ถ้าไม่มีให้ข้ามเทส
    ${has_rows}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr)[1]    20s
    Run Keyword Unless    ${has_rows}    Pass Execution    ไม่มี Incident ให้ทดสอบในตาราง
    ${current}=    Get Selected List Label    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//select[@class="status-pill"])[1]
    Run Keyword If    '${current}'=='INVESTIGATING'    Set Test Variable    ${new_status}    RESOLVED
    ...    ELSE    Set Test Variable    ${new_status}    INVESTIGATING
    Select From List By Label    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//select[@class="status-pill"])[1]    ${new_status}
    # รอให้ backend อัปเดตและหน้า refresh
    Wait Until Keyword Succeeds    5x    2s    Incident Status Should Be    ${new_status}

TC_ADMIN_03 Incident Management - View & Take Action (Cancel ไม่บันทึก)
    [Documentation]    ทดสอบเปิดโมดัล View & Take Action พิมพ์ Admin Resolution Note แล้วกด Cancel ต้องไม่บันทึกค่าใหม่
    Login As Admin
    Open Admin Incident Management
    ${has_rows}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr)[1]    20s
    Run Keyword Unless    ${has_rows}    Pass Execution    ไม่มี Incident ให้ทดสอบในตาราง
    # เปิดโมดัลจากแถวแรก
    Click Button    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//button[contains(@class,"btn-action") or contains(., "View & Take Action")])[1]
    Wait Until Page Contains    Admin Resolution Note    10s
    ${original}=    Get Value    xpath=//div[contains(@class,"modal-sheet")]//textarea
    Input Text    xpath=//div[contains(@class,"modal-sheet")]//textarea    ทดสอบ Cancel ไม่บันทึก
    Click Button    xpath=//div[contains(@class,"modal-foot")]//button[contains(@class,"btn-ghost") or normalize-space(.)="Cancel"]
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,"modal-sheet")]    10s
    # เปิดดูอีกครั้ง ต้องยังเป็นค่าเดิม
    Click Button    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//button[contains(@class,"btn-action") or contains(., "View & Take Action")])[1]
    Wait Until Page Contains    Admin Resolution Note    10s
    ${after}=    Get Value    xpath=//div[contains(@class,"modal-sheet")]//textarea
    Should Be Equal    ${after}    ${original}
    # ปิดโมดัล
    Click Button    xpath=//div[contains(@class,"modal-foot")]//button[contains(@class,"btn-ghost") or normalize-space(.)="Cancel"]

TC_ADMIN_04 Incident Management - View & Take Action (Confirm บันทึกสำเร็จ)
    [Documentation]    ทดสอบกรอก Admin Resolution Note แล้วกด Confirm Resolved ต้องบันทึกข้อความสำเร็จ
    Login As Admin
    Open Admin Incident Management
    ${has_rows}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr)[1]    20s
    Run Keyword Unless    ${has_rows}    Pass Execution    ไม่มี Incident ให้ทดสอบในตาราง
    Click Button    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//button[contains(@class,"btn-action") or contains(., "View & Take Action")])[1]
    Wait Until Page Contains    Admin Resolution Note    10s
    ${note}=    Set Variable    ทดสอบ Confirm บันทึกโดย Robot
    Input Text    xpath=//div[contains(@class,"modal-sheet")]//textarea    ${note}
    Click Button    xpath=//div[contains(@class,"modal-foot")]//button[contains(@class,"btn-submit") or contains(., "Confirm Resolved")]
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,"modal-sheet")]    15s
    # รอให้รีเฟรชข้อมูลแล้วเปิดดูใหม่
    Wait Until Page Contains Element    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr)[1]    20s
    Click Button    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//button[contains(@class,"btn-action") or contains(., "View & Take Action")])[1]
    Wait Until Page Contains    Admin Resolution Note    10s
    ${after_note}=    Get Value    xpath=//div[contains(@class,"modal-sheet")]//textarea
    Should Contain    ${after_note}    ทดสอบ Confirm บันทึกโดย Robot
    # ปิดโมดัล
    Click Button    xpath=//div[contains(@class,"modal-foot")]//button[contains(@class,"btn-ghost") or normalize-space(.)="Cancel"]

TC_ADMIN_05 Incident Management - Filter Status เป็น PENDING
    [Documentation]    ทดสอบ Filter Status ที่ด้านบนว่าใช้ได้และ incident แถวแรกต้องมีสถานะตรงกับที่เลือก
    Login As Admin
    Open Admin Incident Management
    # เลือกสถานะ PENDING จาก filter
    Wait Until Page Contains Element    xpath=//label[normalize-space(.)="Status"]/following::select[1]    15s
    Select From List By Label    xpath=//label[normalize-space(.)="Status"]/following::select[1]    PENDING
    ${has_rows}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr)[1]    20s
    Run Keyword Unless    ${has_rows}    Pass Execution    ไม่มี Incident ในสถานะ PENDING ให้ทดสอบ
    ${status_label}=    Get Selected List Label    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//select[@class="status-pill"])[1]
    Should Be Equal    ${status_label}    PENDING

TC_ADMIN_06 Incident Management - Filter Priority เป็น HIGH
    [Documentation]    ทดสอบ Filter Priority ที่ด้านบนเป็น HIGH แล้ว incident แถวแรกต้องมี Priority HIGH
    Login As Admin
    Open Admin Incident Management
    # เลือก Priority HIGH
    Wait Until Page Contains Element    xpath=//label[normalize-space(.)="Priority"]/following::select[1]    15s
    Select From List By Label    xpath=//label[normalize-space(.)="Priority"]/following::select[1]    HIGH
    ${has_rows}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr)[1]    20s
    Run Keyword Unless    ${has_rows}    Pass Execution    ไม่มี Incident ใน Priority HIGH ให้ทดสอบ
    ${priority_label}=    Get Text    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//span[contains(@class,"badge")])[1]
    Should Be Equal    ${priority_label}    HIGH

TC_ADMIN_07 Non-admin ไม่สามารถเข้า /admin/incidents ได้
    [Documentation]    ทดสอบว่าผู้ใช้ธรรมดา (Passenger) จะถูก redirect ออกจากหน้า Admin Incident Management
    Login As Passenger
    Go To    ${URL}/admin/incidents
    # ต้องถูกเด้งออก (โดย admin-auth) ออกจาก /admin/incidents และห้ามเห็นหน้า Incident Management
    Wait Until Keyword Succeeds    20x    0.5s    Should Be Redirected Away From Admin Incidents

*** Keywords ***
Open Browser To Site
    Open Browser    about:blank    ${BROWSER}
    Maximize Browser Window

Reset Auth State
    [Documentation]    ล้างสถานะ auth ให้สะอาดก่อนเริ่มแต่ละเทส (กัน session จากเทสก่อนหน้าค้าง)
    Go To    ${URL}
    Delete All Cookies
    Execute Javascript    try { window.localStorage.clear(); window.sessionStorage.clear(); } catch(e) {}

Login With Credentials
    [Arguments]    ${email}    ${password}
    Go To    ${URL}/login
    Wait Until Page Contains Element    id=loginForm    10s
    Input Text    id=identifier    ${email}
    Input Text    id=password      ${password}
    Click Button    xpath=//button[normalize-space(.)="เข้าสู่ระบบ"]

Login As Admin
    [Documentation]    ล็อกอินด้วยบัญชี Admin แล้วตรวจว่าหลุดจากหน้า login เรียบร้อย
    Go To    ${URL}/login
    Wait Until Page Contains Element    id=loginForm    15s
    Input Text    id=identifier    ${ADMIN_EMAIL}
    Input Text    id=password      ${ADMIN_PASSWORD}
    Click Button    xpath=//button[normalize-space(.)="เข้าสู่ระบบ"]
    # รอจนไม่อยู่หน้า login แล้ว ถ้ายังอยู่ให้ Fail ชัดเจน
    Wait Until Keyword Succeeds    10x    1s    Admin Should Be Logged In

Admin Should Be Logged In
    ${on_login}=    Run Keyword And Return Status    Page Should Contain Element    id=loginForm
    Run Keyword If    ${on_login}    Fail    ล็อกอิน Admin ไม่สำเร็จ ยังอยู่หน้า login

Login As Passenger
    [Documentation]    ล็อกอินด้วยบัญชีผู้ใช้ธรรมดา
    Go To    ${URL}/login
    Wait Until Page Contains Element    id=loginForm    15s
    Input Text    id=identifier    ${USER_EMAIL}
    Input Text    id=password      ${USER_PASSWORD}
    Click Button    xpath=//button[normalize-space(.)="เข้าสู่ระบบ"]
    # รอให้ล็อกอินเสร็จจริง (หลุดจากหน้า login) ก่อนทำ step ต่อไป
    Wait Until Keyword Succeeds    10x    1s    Passenger Should Be Logged In

Passenger Should Be Logged In
    ${on_login}=    Run Keyword And Return Status    Page Should Contain Element    id=loginForm
    Run Keyword If    ${on_login}    Fail    ล็อกอิน Passenger ไม่สำเร็จ ยังอยู่หน้า login

Should Not Be On Admin Incidents Page
    ${loc}=    Get Location
    Should Not Contain    ${loc}    /admin/incidents

Should Be Redirected Away From Admin Incidents
    ${loc}=    Get Location
    Should Not Contain    ${loc}    /admin/incidents
    # ต้องไปหน้า / หรือ /login อย่างใดอย่างหนึ่ง
    ${at_login}=    Run Keyword And Return Status    Page Should Contain Element    id=loginForm
    ${at_home}=     Run Keyword And Return Status    Page Should Contain    เดินทางร่วมกัน
    Run Keyword Unless    ${at_login} or ${at_home}    Fail    ถูก redirect ออกแล้ว แต่ไม่อยู่หน้า home/login (location=${loc})

Open Admin Incident Management
    [Documentation]    ไปยังหน้า Incident Management สำหรับ Admin ผ่าน Dashboard เหมือนผู้ใช้จริง
    Go To    ${URL}
    Wait Until Page Contains    เดินทางร่วมกัน    15s
    Wait Until Page Contains Element    xpath=(//div[contains(@class,"dropdown-trigger")]//span[contains(@class,"font-medium")])[last()]    15s
    Click Element    xpath=(//div[contains(@class,"dropdown-trigger")]//span[contains(@class,"font-medium")])[last()]
    Wait Until Page Contains Element    xpath=//a[normalize-space(.)="Dashboard"]    10s
    Click Element    xpath=//a[normalize-space(.)="Dashboard"]
    Wait Until Page Contains    User Management    15s
    Wait Until Page Contains Element    xpath=//aside[@id="sidebar"]//span[normalize-space(.)="Incidents Management"]    15s
    Click Element    xpath=//aside[@id="sidebar"]//span[normalize-space(.)="Incidents Management"]/ancestor::a[1]
    Wait Until Page Contains    Incident Management    15s

Incident Status Should Be
    [Arguments]    ${expected}
    ${label}=    Get Selected List Label    xpath=(//table[contains(@class,"smooth-table")]//tbody/tr[1]//select[@class="status-pill"])[1]
    Should Be Equal    ${label}    ${expected}



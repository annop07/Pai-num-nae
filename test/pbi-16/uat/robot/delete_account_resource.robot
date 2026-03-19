*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE_URL}                 https://cssekku3-5.cpkku.com/
${BROWSER}                  chrome

${PASSENGER_EMAIL_NORMAL}      TestPassengerDelete@gmail.com
${PASSENGER_EMAIL_BOOKING}     TestPassenger_Block@gmail.com
${PASSENGER_EMAIL_INCIDENT}    TestPassenger_Incident@gmail.com
${PASSENGER_PASSWORD}          12345678Test

${DRIVER_USERNAME_NORMAL}      TestDriverDelete@gmail.com
${DRIVER_USERNAME_ROUTE}       TestDriver_Block@gmail.com
${DRIVER_USERNAME_INCIDENT}    TestDriver_Incident@gmail.com
${DRIVER_PASSWORD}             12345678Test

${ADMIN_USERNAME}           admin@painamnae.com
${ADMIN_PASSWORD}           Admin@12345

*** Keywords ***
Open Login Page
    [Documentation]    เปิด Browser และไปหน้า Login (ใช้ครั้งเดียวใน Suite Setup)
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.4s
    Wait Until Page Contains    เข้าสู่ระบบ    15s

Navigate To Login Page
    [Documentation]    ไปหน้า Login โดยไม่เปิด Browser ใหม่ (ใช้ในแต่ละ Test Case)
    Go To    ${BASE_URL}/login
    Wait Until Page Contains    เข้าสู่ระบบ    15s

Login As Passenger With Email
    [Documentation]    Login ผู้โดยสารด้วยอีเมล
    [Arguments]    ${email}
    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${email}
    Input Text    id=password     ${PASSENGER_PASSWORD}
    Click Button  xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s

Login As Driver With Username
    [Documentation]    Login คนขับด้วย Username/Email
    [Arguments]    ${username}
    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${username}
    Input Text    id=password     ${DRIVER_PASSWORD}
    Click Button  xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s

Open Profile Page
    [Documentation]    เข้าหน้าโปรไฟล์ของฉัน
    Go To    ${BASE_URL}/profile
    Wait Until Location Contains    /profile    15s

Open Delete Account Modal
    [Documentation]    เลื่อนลงหา Danger Zone แล้วเปิด Modal ลบบัญชี
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ลบบัญชี')]    15s
    Click Button    xpath=//button[contains(text(),'ลบบัญชี')]
    Wait Until Element Is Visible    xpath=//h2[contains(text(),'คุณยืนยันที่จะลบบัญชีหรือไม่?')]    10s

Fill Delete Password And Confirm
    [Documentation]    กรอกรหัสผ่านใน Modal ลบบัญชี และกดยืนยัน
    [Arguments]    ${password}
    Wait Until Element Is Visible    xpath=//input[@placeholder='กรอกรหัสผ่าน']    10s
    Input Text    xpath=//input[@placeholder='กรอกรหัสผ่าน']    ${password}
    Wait Until Element Is Enabled    xpath=//button[contains(text(),'ลบบัญชีนี้')]    5s
    Click Button    xpath=//button[contains(text(),'ลบบัญชีนี้')]

Assert Toast Contains
    [Documentation]    ตรวจว่า Toast แสดงข้อความตามที่คาดหวัง
    [Arguments]    ${expected}
    Wait Until Page Contains    ${expected}    15s

Assert Delete Button Is Disabled
    [Documentation]    ตรวจว่าปุ่ม "ลบบัญชีนี้" ถูก disabled (เมื่อไม่กรอกรหัสผ่าน)
    Element Should Be Disabled    xpath=//button[contains(text(),'ลบบัญชีนี้')]

Assert Cannot Delete And Still Logged In
    [Documentation]    ใช้กับกรณี Blocking – ยังอยู่หน้าโปรไฟล์
    Wait Until Location Contains    /profile    10s

Assert Login Error Contains
    [Documentation]    ตรวจว่าหน้า login แสดงข้อความ error (ใน div สีแดง ไม่ใช่ toast)
    [Arguments]    ${expected}
    Wait Until Page Contains    ${expected}    15s

Login And Expect Error On Login Page
    [Documentation]    กรอก identifier + password แล้วกด submit โดยไม่รอ redirect (ใช้กับ deactivated account)
    [Arguments]    ${identifier}    ${password_value}
    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${identifier}
    Input Text    id=password     ${password_value}
    Click Button  xpath=//button[@type='submit']

Logout From System
    [Documentation]    ออกจากระบบจากเมนูด้านบน (ถ้ามี)
    Click Element    xpath=//button[contains(@aria-label,'profile') or contains(@aria-label,'โปรไฟล์')][1]
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ออกจากระบบ')]    10s
    Click Element    xpath=//button[contains(text(),'ออกจากระบบ')]
    Wait Until Location Contains    /login    15s

Login As Admin UAT
    [Documentation]    Login ด้วยบัญชี Admin_UAT เพื่อเช็คว่าไม่มีปุ่มลบบัญชี
    Wait Until Element Is Visible    id=identifier    15s
    Input Text    id=identifier    ${ADMIN_USERNAME}
    Input Text    id=password     ${ADMIN_PASSWORD}
    Click Button  xpath=//button[@type='submit']
    Wait Until Location Does Not Contain    /login    15s

Open Profile Page From Any Role
    [Documentation]    สำหรับใช้ซ้ำทั้ง Passenger / Driver / Admin
    Go To    ${BASE_URL}/profile
    Wait Until Location Contains    /profile    15s

Assert Delete Button Not Visible
    [Documentation]    ใช้ตรวจว่าไม่มีปุ่มลบบัญชีบนหน้าโปรไฟล์
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight)
    Sleep    0.5s
    Page Should Not Contain Element    xpath=//button[contains(text(),'ลบบัญชี')]

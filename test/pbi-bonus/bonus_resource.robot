*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem

*** Variables ***
${BASE_URL}           http://localhost:3001
${BROWSER}            chrome
${DRIVER_EMAIL}       driver@gmail.com
${PASSENGER_EMAIL}    sa@gmail.com
${PASSWORD}           12345678Za

*** Keywords ***
# --- OPEN / CLOSE ---
Open Browser To Login Page
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains    เข้าสู่ระบบ    15s

Close Browser Session
    Close Browser

# --- LOGIN ---
Login As User
    [Arguments]    ${email}    ${password}
    Wait Until Element Is Visible    id=identifier    15s
    Input Text      id=identifier    ${email}
    Input Text      id=password      ${password}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Location Does Not Contain    /login    15s

# --- NAVIGATION ---
Go To My Payments
    Go To    ${BASE_URL}/my-payments
    Wait Until Page Contains    การชำระเงินของฉัน    15s

Go To Check Payments
    Go To    ${BASE_URL}/check-payments
    Wait Until Page Contains    ตรวจสอบการชำระเงิน    15s

# --- SUBMIT PAYMENT (ฝั่งผู้โดยสาร - แก้ไขจุดคลิกแนบหลักฐาน) ---
Submit Payment Proof
    [Arguments]    ${index}    ${amount}    ${note}    ${file_path}=${EMPTY}
    
    # ใช้ XPath ที่ยืดหยุ่น หา <a> ที่มีคำว่า 'แนบหลักฐาน'
    ${attach_btn}=    Set Variable    xpath=//a[contains(.,'แนบหลักฐาน')]
    
    Wait Until Element Is Visible    ${attach_btn}    15s
    Scroll Element Into View         ${attach_btn}
    Sleep    1s    # ให้ UI โหลดสถานะปุ่ม
    
    # ใช้ Selenium Click ปกติ (ถ้าไม่ได้ค่อยใช้ JS แบบแก้ Quote แล้วข้างล่าง)
    Click Element    ${attach_btn}

    Wait Until Page Contains         แนบหลักฐานการชำระเงิน    15s
    Wait Until Element Is Visible    xpath=//select    10s
    Select From List By Index        xpath=//select    ${index}

    Input Text    xpath=//input[@type='number']    ${amount}
    Input Text    xpath=//textarea                ${note}

    IF    '${file_path}' != '${EMPTY}'
        Choose File    xpath=//input[@type='file']    ${file_path}
    END

    # เปลี่ยนจาก JS Click มาเป็น Click Button ปกติ
    Wait Until Element Is Visible    xpath=//button[contains(.,'ส่งหลักฐาน')]    10s
    Click Button                    xpath=//button[contains(.,'ส่งหลักฐาน')]
    Wait Until Page Contains         บันทึกสำเร็จ    20s

# --- DRIVER VERIFICATION (ฝั่งคนขับ) ---
Go To Passenger Verification
    Wait Until Element Is Visible    xpath=//button[contains(.,'ตรวจสอบ')]    15s
    Click Button                   xpath=//button[contains(.,'ตรวจสอบ')]
    
    Wait Until Page Contains        ผู้โดยสารทั้งหมด    15s
    Sleep    1s    # รอ Modal นิ่ง

    ${verify_btn}=    Set Variable    xpath=//button[contains(.,'ตรวจสอบการชำระเงิน')]
    Wait Until Element Is Visible    ${verify_btn}    15s
    Click Button                   ${verify_btn}

    Wait Until Location Contains    /verify/    20s
    Wait Until Page Contains         รายละเอียด    15s

Verify Payment Flow
    [Arguments]    ${index}
    Wait Until Page Contains    รายละเอียด    20s
    Wait Until Element Is Visible    xpath=//select    15s
    Select From List By Index        xpath=//select    ${index}

    Wait Until Element Is Visible    xpath=//button[contains(.,'ยืนยันหลักฐาน')]    10s
    Click Button                    xpath=//button[contains(.,'ยืนยันหลักฐาน')]
    Wait Until Page Contains         สำเร็จ    20s

Issue Document
    [Arguments]    ${index}
    Wait Until Page Contains    ออกเอกสารการเงิน    15s
    Wait Until Element Is Visible    xpath=(//select)[last()]    10s
    Select From List By Index        xpath=(//select)[last()]    ${index}
    
    Wait Until Element Is Visible    xpath=//button[contains(.,'ออกเอกสาร')]    10s
    Click Button                    xpath=//button[contains(.,'ออกเอกสาร')]
    Wait Until Page Contains         สำเร็จ    15s
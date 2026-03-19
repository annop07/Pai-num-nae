*** Settings ***
Documentation     UAT - Passenger Delete Account (Password Validation)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers
Test Teardown     Sleep    2s

*** Test Cases ***
PA-02 - Empty Password Not Allowed
    [Documentation]    PA-02: ไม่กรอกรหัสผ่าน ปุ่มลบบัญชีนี้ต้อง disabled
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_NORMAL}
    Open Profile Page
    Open Delete Account Modal
    # ไม่กรอกรหัสผ่าน -> ปุ่มต้อง disabled
    Assert Delete Button Is Disabled
    Assert Cannot Delete And Still Logged In

PA-03 - Wrong Password Shows Error
    [Documentation]    PA-03: กรอกรหัสผ่านผิด
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_NORMAL}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    WrongPassword123
    Assert Toast Contains    รหัสผ่านไม่ถูกต้อง
    Assert Cannot Delete And Still Logged In

PA-04 - One Character Off Shows Error
    [Documentation]    PA-04: รหัสผ่านผิดไป 1 ตัวอักษร
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_NORMAL}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    123456789Tes
    Assert Toast Contains    รหัสผ่านไม่ถูกต้อง
    Assert Cannot Delete And Still Logged In

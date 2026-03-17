*** Settings ***
Documentation     UAT - Driver Delete Account (Password Validation)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers

*** Test Cases ***
DR-02 - Empty Password Not Allowed
    [Documentation]    DR-02: ไม่กรอกรหัสผ่าน ปุ่มลบบัญชีนี้ต้อง disabled
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_NORMAL}
    Open Profile Page From Any Role
    Open Delete Account Modal
    # ไม่กรอกรหัสผ่าน -> ปุ่มต้อง disabled
    Assert Delete Button Is Disabled
    Assert Cannot Delete And Still Logged In

DR-03 - Wrong Password Shows Error
    [Documentation]    DR-03: รหัสผ่านผิด
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_NORMAL}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    WrongPassword123
    Assert Toast Contains    รหัสผ่านไม่ถูกต้อง
    Assert Cannot Delete And Still Logged In

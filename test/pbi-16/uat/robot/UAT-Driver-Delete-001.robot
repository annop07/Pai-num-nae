*** Settings ***
Documentation     UAT - Driver Delete Account (Happy Path)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers

*** Test Cases ***
DR-01 - Driver Delete Success
    [Documentation]    DR-01: คนขับลบบัญชีสำเร็จ เมื่อไม่มี Route/Booking/Incident ค้าง
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_NORMAL}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    บัญชีของคุณจะถูกลบถาวรภายใน 90 วัน
    Wait Until Page Contains    เข้าสู่ระบบ    15s

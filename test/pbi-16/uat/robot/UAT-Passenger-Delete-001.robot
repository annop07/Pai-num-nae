*** Settings ***
Documentation     UAT - Passenger Delete Account (Happy Path)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers

*** Test Cases ***
PA-01 - Passenger Delete Success
    [Documentation]    PA-01: ผู้โดยสารลบบัญชีสำเร็จ เมื่อไม่มี Booking/Incident ค้าง
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_NORMAL}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${PASSENGER_PASSWORD}
    Assert Toast Contains    บัญชีของคุณจะถูกลบถาวรภายใน 90 วัน
    Wait Until Page Contains    เข้าสู่ระบบ    15s

*** Settings ***
Documentation     UAT - Passenger Delete Account (Blocking Active Booking)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers
Test Teardown     Sleep    3s

*** Test Cases ***
PA-05 - Block Delete When Booking PENDING
    [Documentation]    PA-05: มี Booking สถานะ PENDING ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_BOOKING}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${PASSENGER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

PA-06 - Block Delete When Booking CONFIRMED
    [Documentation]    PA-06: มี Booking สถานะ CONFIRMED ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_BOOKING}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${PASSENGER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

*** Settings ***
Documentation     UAT - Driver Delete Account (Blocking Route/Booking)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers

*** Test Cases ***
DR-04 - Block Delete When Route AVAILABLE
    [Documentation]    DR-04: มี Route สถานะ AVAILABLE ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_ROUTE}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

DR-05 - Block Delete When Route IN_TRANSIT
    [Documentation]    DR-05: มี Route สถานะ IN_TRANSIT ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_ROUTE}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

DR-06 - Block Delete When Booking PENDING On Route
    [Documentation]    DR-06: มี Booking PENDING บน Route ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_ROUTE}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

DR-07 - Block Delete When Booking CONFIRMED On Route
    [Documentation]    DR-07: มี Booking CONFIRMED บน Route ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_ROUTE}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

*** Settings ***
Documentation     UAT - Driver Delete Account (Blocking Incident)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers
Test Teardown     Sleep    2s

*** Test Cases ***
DR-08 - Block Delete When Incident PENDING
    [Documentation]    DR-08: มี Incident PENDING ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_INCIDENT}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

DR-09 - Block Delete When Incident INVESTIGATING
    [Documentation]    DR-09: มี Incident INVESTIGATING ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_INCIDENT}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

DR-10 - Block Delete When Incident ESCALATED
    [Documentation]    DR-10: มี Incident ESCALATED ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Driver With Username    ${DRIVER_USERNAME_INCIDENT}
    Open Profile Page From Any Role
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${DRIVER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

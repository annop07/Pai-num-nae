*** Settings ***
Documentation     UAT - Passenger Delete Account (Blocking Incident)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers

*** Test Cases ***
PA-07 - Block Delete When Incident PENDING
    [Documentation]    PA-07: มี Incident สถานะ PENDING ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_INCIDENT}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${PASSENGER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

PA-08 - Block Delete When Incident INVESTIGATING
    [Documentation]    PA-08: มี Incident สถานะ INVESTIGATING ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_INCIDENT}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${PASSENGER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

PA-09 - Block Delete When Incident ESCALATED
    [Documentation]    PA-09: มี Incident สถานะ ESCALATED ไม่ควรลบบัญชีได้
    Navigate To Login Page
    Login As Passenger With Email    ${PASSENGER_EMAIL_INCIDENT}
    Open Profile Page
    Open Delete Account Modal
    Fill Delete Password And Confirm    ${PASSENGER_PASSWORD}
    Assert Toast Contains    ไม่สามารถลบบัญชีได้
    Assert Cannot Delete And Still Logged In

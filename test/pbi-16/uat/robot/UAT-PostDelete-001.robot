*** Settings ***
Documentation     UAT - Login After Account Deleted (Passenger & Driver)
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers

*** Test Cases ***
PD-01 - Passenger Cannot Login After Delete
    [Documentation]    PD-01: ผู้โดยสารที่ถูกลบบัญชีแล้วไม่ควร Login ได้
    Navigate To Login Page
    Login And Expect Error On Login Page    ${PASSENGER_EMAIL_NORMAL}    ${PASSENGER_PASSWORD}
    Assert Login Error Contains    Your account has been deactivated.

PD-02 - Driver Cannot Login After Delete
    [Documentation]    PD-02: คนขับที่ถูกลบบัญชีแล้วไม่ควร Login ได้
    Navigate To Login Page
    Login And Expect Error On Login Page    ${DRIVER_USERNAME_NORMAL}    ${DRIVER_PASSWORD}
    Assert Login Error Contains    Your account has been deactivated.

*** Settings ***
Library    SeleniumLibrary

*** Keywords ***

Open Browser To Login
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.3s

Close Test Browser
    Close Browser


Login As Admin
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${ADMIN_EMAIL}
    Input Text    id=password      ${ADMIN_PASSWORD}
    Click Button    xpath=//button[@type="submit"]
    Wait Until Location Contains    /    5s


Login As Driver
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${DRIVER_EMAIL}
    Input Text    id=password      ${DRIVER_PASSWORD}
    Click Button    xpath=//button[@type="submit"]
    Wait Until Location Contains    /    5s


Login As Passenger
    Wait Until Element Is Visible    id=identifier    10s
    Input Text    id=identifier    ${PASS_EMAIL}
    Input Text    id=password      ${PASS_PASSWORD}
    Click Button    xpath=//button[@type="submit"]
    Wait Until Location Contains    /    5s

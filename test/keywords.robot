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
    Click Element    ${LOGIN_BTN}
    Wait Until Element Is Visible    ${USERNAME_INPUT}
    Input Text    ${USERNAME_INPUT}    ${ADMIN_USERNAME}
    Input Password    ${PASSWORD_INPUT}    ${ADMIN_PASSWORD}
    Click Button    ${SUBMIT_LOGIN}
    Wait Until Page Contains    Dashboard


Go To Incident Management
    Click Element    ${DASHBOARD_MENU}
    Wait Until Element Is Visible    ${INCIDENT_MENU}
    Click Element    ${INCIDENT_MENU}
    Wait Until Page Contains    Incident


Select Incident And Open Form
    Click Element    ${VIEW_TAKE_ACTION_BTN}
    Wait Until Element Is Visible    ${CONFIRM_BTN}
    Click Element    ${CONFIRM_BTN}
    Wait Until Element Is Visible    ${DETAIL_INPUT}


Fill Change Status Form
    [Arguments]    ${detail}
    Input Text    ${DETAIL_INPUT}    ${detail}
    Click Element    ${SUBMIT_BTN}


Verify Success
    Wait Until Element Is Visible    ${SUCCESS_MESSAGE}


Verify Validation Message
    Wait Until Element Is Visible    ${VALIDATION_MESSAGE}

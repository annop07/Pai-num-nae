*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE_URL}           http://localhost:3001
${BROWSER}            chrome
${ADMIN_USERNAME}     admin123
${ADMIN_PASSWORD}     Admin@12345

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains    เข้าสู่ระบบ    15s

Login As Admin
    Wait Until Element Is Visible    xpath=//input[@type='text']    15s
    Input Text    xpath=//input[@type='text']    ${ADMIN_USERNAME}
    Input Text    xpath=//input[@type='password']    ${ADMIN_PASSWORD}
    Click Element    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Location Contains    /admin    15s

Go To Admin Users
    Go To    ${BASE_URL}/admin/users
    Wait Until Location Contains    /admin/users    15s

Go To Incident Management
    Go To    ${BASE_URL}/admin/incidents
    Wait Until Location Contains    /admin/incidents    15s


Select Incident By Status
    [Arguments]    ${status}
    Wait Until Page Contains    ${status}    15s
    Click Element    xpath=//td[contains(.,'${status}')]/following::button[1]

Confirm View Action
    Wait Until Element Is Visible    xpath=//button[contains(.,'ดูรายละเอียด')]    10s
    Click Element    xpath=//button[contains(.,'ดูรายละเอียด')]

Fill Change Status Form
    [Arguments]    ${comment}    ${new_status}
    Wait Until Element Is Visible    xpath=//textarea    10s
    Input Text    xpath=//textarea    ${comment}
    Click Element    xpath=//select
    Select From List By Label    xpath=//select    ${new_status}
    Click Element    xpath=//button[contains(.,'บันทึก')]

Verify Status Changed
    [Arguments]    ${expected_status}
    Wait Until Page Contains    ${expected_status}    15s


Open Admin Menu
    Wait Until Element Is Visible    xpath=//div[.//span[contains(text(),'System')]]    10s
    Click Element    xpath=//div[.//span[contains(text(),'System')]]


Click Admin Menu
    Wait Until Element Is Visible    xpath=//a[contains(@href,'/admin')]    10s
    Click Element    xpath=//a[contains(@href,'/admin')]
    Wait Until Location Contains    /admin    15s

Go To Incident Page
    Wait Until Element Is Visible    xpath=//a[contains(@href,'incident')]    10s
    Click Element    xpath=//a[contains(@href,'incident')]
    Wait Until Location Contains    incident    15s


Close Browser Session
    Close Browser

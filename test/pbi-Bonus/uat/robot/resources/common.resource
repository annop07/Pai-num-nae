*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
${BROWSER}              chrome
${TIMEOUT}              10s
${IMPLICIT_WAIT}        5s
${DEMO_SPEED}           1s    # Delay between actions for demo/observation

*** Keywords ***
Open Browser To Website
    [Documentation]    Open browser and navigate to base URL
    Open Browser    ${BASE_URL}    ${BROWSER}
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Set Selenium Timeout    ${TIMEOUT}
    Set Selenium Speed    ${DEMO_SPEED}    # Set delay between all Selenium commands
    Maximize Browser Window

Close Browser Session
    [Documentation]    Close the browser
    Close Browser

Wait And Click
    [Documentation]    Wait for element to be clickable and click
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Wait Until Element Is Enabled    ${locator}    ${TIMEOUT}
    Click Element    ${locator}
    Sleep    ${DEMO_SPEED}    # Pause after click for observation

Wait And Input Text
    [Documentation]    Wait for element and input text
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Input Text    ${locator}    ${text}
    Sleep    ${DEMO_SPEED}    # Pause after input for observation

Wait And Select From List By Value
    [Documentation]    Wait for select element and select by value
    [Arguments]    ${locator}    ${value}
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Select From List By Value    ${locator}    ${value}

Wait For Element
    [Documentation]    Wait until element is visible
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}

Wait For Element Contains Text
    [Documentation]    Wait until element contains specific text
    [Arguments]    ${locator}    ${text}
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Wait Until Element Contains    ${locator}    ${text}    ${TIMEOUT}

Element Should Be Disabled
    [Documentation]    Verify element is disabled
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Element Should Be Disabled    ${locator}

Element Should Be Enabled
    [Documentation]    Verify element is enabled
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    ${TIMEOUT}
    Element Should Be Enabled    ${locator}

Verify Page Contains Text
    [Documentation]    Verify page contains expected text
    [Arguments]    ${text}
    Wait Until Page Contains    ${text}    ${TIMEOUT}

Verify Page Does Not Contain Text
    [Documentation]    Verify page does not contain text
    [Arguments]    ${text}
    Page Should Not Contain    ${text}

Take Screenshot On Failure
    [Documentation]    Capture screenshot when test fails
    Capture Page Screenshot

Login As User
    [Documentation]    Login with username and password
    [Arguments]    ${username}    ${password}
    Go To    ${BASE_URL}/login
    Wait And Input Text    id=identifier    ${username}
    Wait And Input Text    id=password    ${password}
    Wait And Click    xpath=//button[contains(text(), 'เข้าสู่ระบบ') or contains(text(), 'Login')]
    Sleep    2s    # Wait for login to complete
    Wait Until Location Does Not Contain    /login    ${TIMEOUT}

Logout
    [Documentation]    Logout from the system
    Wait And Click    xpath=//button[contains(@class, 'logout') or contains(text(), 'ออกจากระบบ')]
    Wait Until Location Contains    /login

Get Current URL
    [Documentation]    Get current page URL
    ${url}=    Get Location
    RETURN    ${url}

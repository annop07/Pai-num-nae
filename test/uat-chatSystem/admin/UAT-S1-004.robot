*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     SeleniumLibrary

*** Test Cases ***

UAT-S1-004 Admin Update Incident Status

    # Step 1: Login เป็น Admin
    Open Browser To Login
    Login As Admin
    Go To    ${BASE_URL}/admin/incidents
    Wait Until Page Contains    Incident Management    10s

    # Step 2: ตรวจสอบ Summary Card
    Page Should Contain    Total Incidents
    Page Should Contain    Pending
    Page Should Contain    Urgent

    # Step 3: ใช้ Filter Status
    Select From List By Label    xpath=(//select)[1]    PENDING
    Sleep    2s

    # Step 4: ใช้ Filter Priority
    Select From List By Label    xpath=(//select)[2]    LOW
    Sleep    2s

    # Step 5: เปลี่ยนเป็น INVESTIGATING
    Select From List By Label    xpath=(//table//select)[1]    INVESTIGATING
    Sleep    2s
    Reload Page
    Wait Until Page Contains    INVESTIGATING    10s

    # Step 6: Refresh หน้า
    Reload Page
    Wait Until Page Contains    Incident Management    10s

    # Step 7: เปลี่ยนเป็น RESOLVED
    Select From List By Label    xpath=(//table//select)[1]    RESOLVED
    Sleep    2s
    Reload Page
    Wait Until Page Contains    RESOLVED    10s

    Capture Page Screenshot
    Close Browser

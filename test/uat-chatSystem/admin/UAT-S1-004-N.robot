*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     SeleniumLibrary

*** Test Cases ***

UAT-S1-004-N Driver View Incident Page

    # Step 1: Driver Login
    Open Browser To Login
    Login As Driver

    # ตรวจสอบว่าอยู่หน้า Home
    Wait Until Page Contains    เดินทางร่วมกัน    10s

    # Step 2: คลิกเมนู "ติดตามเหตุการณ์"
    Click Element    xpath=//a[contains(text(),"ติดตามเหตุการณ์")]

    # Step 3: ตรวจสอบว่าเข้า /myIncidents สำเร็จ
    Wait Until Location Contains    /myIncidents    10s
    Wait Until Page Contains    ติดตามสถานะแจ้งเหตุการณ์    10s

    Capture Page Screenshot
    Close Browser

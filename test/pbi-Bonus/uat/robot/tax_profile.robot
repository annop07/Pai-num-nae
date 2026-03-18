*** Settings ***
Documentation    UAT-Bonus-TaxProfile-001: Tax Profile (Driver)
...              ทดสอบการกรอก/validation/bypass ของ Tax Profile modal
...              Total: 8 test cases

Library          SeleniumLibrary
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
TC-001 Driver Login
    Login As Driver
    ${url}=    Get Location
    Should Not Contain    ${url}    /login

TC-002 Open Confirmed Verification
    Login As Driver
    Open First Payment Verification Confirmed

TC-003 Open Tax Profile Modal When Missing
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    ${has_modal}=    Run Keyword And Return Status    Wait Until Page Contains    กรอกข้อมูลภาษีครั้งแรก    3s
    IF    not ${has_modal}
        Skip    ไม่พบ modal (อาจมี tax profile อยู่แล้ว)
    END

TC-004 Tax Profile Required Fields
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    ${has_modal}=    Run Keyword And Return Status    Wait Until Page Contains    กรอกข้อมูลภาษีครั้งแรก    3s
    IF    not ${has_modal}
        Skip    ไม่พบ modal
    END
    Click Element    xpath=//button[contains(.,'บันทึก')]
    Wait Until Page Contains    ต้องมี 13 หลัก    10s

TC-005 TaxId Must Be 13 Digits
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    ${has_modal}=    Run Keyword And Return Status    Wait Until Page Contains    กรอกข้อมูลภาษีครั้งแรก    3s
    IF    not ${has_modal}
        Skip    ไม่พบ modal
    END
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    123
    Click Element    xpath=//button[contains(.,'บันทึก')]
    Wait Until Page Contains    13 หลัก    10s

TC-006 Save Tax Profile Success
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    ${has_modal}=    Run Keyword And Return Status    Wait Until Page Contains    กรอกข้อมูลภาษีครั้งแรก    3s
    IF    not ${has_modal}
        Skip    ไม่พบ modal
    END
    Input Text    xpath=//label[contains(.,'ชื่อผู้เสียภาษี')]/following::input[1]    Test Taxpayer
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    1234567890123
    Input Text    xpath=//label[contains(.,'ที่อยู่')]/following::textarea[1]    Khon Kaen
    Click Element    xpath=//button[contains(.,'บันทึก')]
    # modal ควรปิด
    Wait Until Page Does Not Contain    กรอกข้อมูลภาษีครั้งแรก    15s

TC-007 Issue Tax Invoice After Save
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    Handle Tax Profile Modal If Present
    Verify Document Issued List Contains    ใบกำกับภาษี

TC-008 Modal Should Not Appear After Saved
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    ${has_modal}=    Run Keyword And Return Status    Wait Until Page Contains    กรอกข้อมูลภาษีครั้งแรก    2s
    Should Be True    not ${has_modal}

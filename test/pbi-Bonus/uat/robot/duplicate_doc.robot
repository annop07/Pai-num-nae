*** Settings ***
Documentation    UAT-Bonus-DuplicateDoc-001: ป้องกันออกเอกสารซ้ำ
...              Total: 4 test cases

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

TC-002 Open Confirmed Verification
    Open First Payment Verification Confirmed

TC-003 Issue Payment Voucher Once
    Select Document Type For Issue    PAYMENT_VOUCHER
    Click Issue Document Button
    Verify Document Issued List Contains    ใบสำคัญรับเงิน

TC-004 Issue Same Type Again Should Be Blocked
    # ถ้าปุ่ม disable หรือขึ้นข้อความเตือนถือว่าผ่าน
    ${disabled}=    Run Keyword And Return Status
    ...    Element Should Be Disabled    xpath=//button[contains(.,'ออกเอกสาร')]
    ${warn}=    Run Keyword And Return Status
    ...    Wait Until Page Contains    เอกสารประเภทนี้ถูกออกแล้ว    5s
    IF    not ${disabled} and not ${warn}
        Click Issue Document Button
        ${warn}=    Run Keyword And Return Status
        ...    Wait Until Page Contains    เอกสารประเภทนี้ถูกออกแล้ว    8s
    END
    Should Be True    ${disabled} or ${warn}

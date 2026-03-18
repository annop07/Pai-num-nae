*** Settings ***
Documentation    UAT-Bonus-Receipt-001: Receipt / Document View
...              ทดสอบการเปิดหน้าเอกสารและการแสดงผลเอกสาร (ใบเสร็จ/ใบกำกับภาษี/ใบสำคัญรับเงิน)
...              Total: 7 test cases

Library          SeleniumLibrary
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
TC-001 Passenger Login
    Login As Passenger
    ${url}=    Get Location
    Should Not Contain    ${url}    /login

TC-002 Open My Payments Confirmed Tab
    Navigate To My Payments
    Click Element    xpath=//button[contains(.,'ยืนยันแล้ว')]
    Sleep    2s

TC-003 Open First Document Link If Exists
    Navigate To My Payments
    Click Element    xpath=//button[contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    ${has_doc}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//a[contains(.,'ดาวน์โหลดเอกสาร')]    6s
    IF    not ${has_doc}
        Skip    ไม่พบลิงก์ดาวน์โหลดเอกสาร (ต้องมีรายการ CONFIRMED และมีเอกสาร)
    END
    Click Element    xpath=(//a[contains(.,'ดาวน์โหลดเอกสาร')])[1]
    Wait Until Location Contains    /my-payments/document/    ${TIMEOUT}

TC-004 Document Page Should Show Print Button
    Wait Until Page Contains    พิมพ์เอกสาร    ${TIMEOUT}

TC-005 Document Page Shows Some Document Title
    ${has_tax}=    Run Keyword And Return Status    Wait Until Page Contains    ใบกำกับภาษี    3s
    ${has_voucher}=    Run Keyword And Return Status    Wait Until Page Contains    ใบสำคัญรับเงิน    3s
    ${has_receipt}=    Run Keyword And Return Status    Wait Until Page Contains    ใบเสร็จรับเงิน    3s
    Should Be True    ${has_tax} or ${has_voucher} or ${has_receipt}

TC-006 Back Button Works
    Click Element    xpath=//button[contains(.,'ย้อนกลับ')]
    Wait Until Location Contains    /my-payments    ${TIMEOUT}

TC-007 Confirmed Tab Still Accessible
    Click Element    xpath=//button[contains(.,'ยืนยันแล้ว')]
    Wait Until Page Contains    ยืนยันแล้ว    ${TIMEOUT}

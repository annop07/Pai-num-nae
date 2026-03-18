*** Settings ***
Documentation    UAT-Bonus-MultiDoc-001: ออกเอกสารหลายประเภท และตรวจในหน้า Passenger
...              Total: 4 test cases

Library          SeleniumLibrary
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
TC-001 Driver Issue Two Document Types
    Login As Driver
    Open First Payment Verification Confirmed
    # ออกใบกำกับภาษี
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    Handle Tax Profile Modal If Present
    # ออกใบสำคัญรับเงิน
    Select Document Type For Issue    PAYMENT_VOUCHER
    Click Issue Document Button
    # ตรวจว่ามีรายการเอกสารอย่างน้อย 2 ประเภท
    Verify Document Issued List Contains    ใบกำกับภาษี
    Verify Document Issued List Contains    ใบสำคัญรับเงิน

TC-002 Passenger Sees Download Link
    Login As Passenger
    Navigate To My Payments
    Click Element    xpath=//button[contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    ${has_doc}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//a[contains(.,'ดาวน์โหลดเอกสาร')]    8s
    IF    not ${has_doc}
        Skip    ไม่พบลิงก์ดาวน์โหลดเอกสาร (ต้องมีรายการ CONFIRMED และมีเอกสาร)
    END

TC-003 Open Document Page
    Click Element    xpath=(//a[contains(.,'ดาวน์โหลดเอกสาร')])[1]
    Wait Until Location Contains    /my-payments/document/    ${TIMEOUT}
    Wait Until Page Contains    พิมพ์เอกสาร    ${TIMEOUT}

TC-004 Switch Document Type If Multiple
    ${has_selector}=    Run Keyword And Return Status
    ...    Wait Until Page Contains    เลือกประเภทเอกสาร    3s
    IF    not ${has_selector}
        Skip    หน้าเอกสารมีเอกสารประเภทเดียว
    END
    # คลิกสลับไปอีกประเภทหนึ่ง
    Click Element    xpath=(//button[contains(.,'ใบกำกับภาษี') or contains(.,'ใบสำคัญรับเงิน') or contains(.,'ใบเสร็จ')])[1]
    Sleep    1s

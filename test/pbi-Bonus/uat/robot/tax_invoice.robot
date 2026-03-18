*** Settings ***
Documentation    UAT-Bonus-TaxInvoice-001: ออกใบกำกับภาษี (TAX_INVOICE)
...              ทดสอบการออกใบกำกับภาษีในหน้า Driver ตรวจสอบการชำระเงิน
...              รวมทั้งกรณีต้องกรอก Tax Profile ครั้งแรก
...
...              Total: 6 test cases

Library          SeleniumLibrary
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
TC-001 Driver Login
    [Documentation]    Login ด้วยบัญชี Driver
    Login As Driver
    ${url}=    Get Location
    Should Not Contain    ${url}    /login

TC-002 Open Confirmed Verification Case
    [Documentation]    เปิดเคสสถานะยืนยันแล้ว (CONFIRMED) อัตโนมัติ
    Login As Driver
    Open First Payment Verification Confirmed
    Wait Until Page Contains    ออกเอกสารการเงิน    ${TIMEOUT}

TC-003 Issue Tax Invoice Success
    [Documentation]    เลือก TAX_INVOICE และออกเอกสารสำเร็จ (ถ้ามี modal tax profile ให้กรอก)
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    Handle Tax Profile Modal If Present
    # หลังออกเอกสารควรมีรายการเอกสาร
    Verify Document Issued List Contains    ใบกำกับภาษี

TC-004 Issue Tax Invoice Without Confirm Should Be Blocked
    [Documentation]    ถ้าเคสยังไม่ CONFIRMED ปุ่มออกเอกสารควรถูกบล็อก/มีข้อความแจ้งเตือน
    Login As Driver
    Open First Payment Verification Needing Review
    # สถานะ PROOF_SUBMITTED -> มีข้อความบอกต้องยืนยันก่อน
    Wait Until Page Contains    ต้องยืนยันหลักฐานก่อน    ${TIMEOUT}

TC-005 Tax Profile Modal Validation (TaxId 13 digits)
    [Documentation]    กรณี modal tax profile โผล่ ให้ตรวจ validation เลขผู้เสียภาษี 13 หลัก
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    Click Issue Document Button
    ${has_modal}=    Run Keyword And Return Status    Wait Until Page Contains    กรอกข้อมูลภาษีครั้งแรก    3s
    IF    not ${has_modal}
        Skip    ไม่พบ modal Tax Profile (อาจมีข้อมูลภาษีอยู่แล้ว)
    END
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    123
    Click Element    xpath=//button[contains(.,'บันทึก')]
    Wait Until Page Contains    13 หลัก    ${TIMEOUT}

TC-006 Duplicate Tax Invoice Should Be Blocked
    [Documentation]    ออก TAX_INVOICE ซ้ำควรขึ้นข้อความว่าเอกสารถูกออกแล้ว หรือปุ่มถูก disable
    Login As Driver
    Open First Payment Verification Confirmed
    Select Document Type For Issue    TAX_INVOICE
    ${disabled}=    Run Keyword And Return Status
    ...    Element Should Be Disabled    xpath=//button[contains(.,'ออกเอกสาร')]
    ${warn}=    Run Keyword And Return Status
    ...    Wait Until Page Contains    เอกสารประเภทนี้ถูกออกแล้ว    5s
    # ถ้าไม่ disabled ให้ลองกด 1 ครั้งและดูว่าขึ้น warn
    IF    not ${disabled}
        Click Issue Document Button
        ${warn}=    Run Keyword And Return Status
        ...    Wait Until Page Contains    เอกสารประเภทนี้ถูกออกแล้ว    8s
    END
    Should Be True    ${disabled} or ${warn}

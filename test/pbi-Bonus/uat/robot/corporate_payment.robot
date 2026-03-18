*** Settings ***
Documentation    UAT-Bonus-Corporate-001: Corporate Payment (ขอใบกำกับภาษีในนามนิติบุคคล)
...              ทดสอบการกรอกข้อมูลนิติบุคคล/บริษัทและ validation บนหน้าแนบหลักฐาน
...              Total: 9 test cases

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

TC-002 Open Upload Page
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Wait Until Page Contains    แนบหลักฐานการชำระเงิน    ${TIMEOUT}

TC-003 Toggle Corporate Request Shows Form
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    # ต้องเลือก TAX_INVOICE อย่างน้อย 1 รายการ (default เป็น TAX_INVOICE)
    Select Document Type Tax Invoice
    # เปิด checkbox ต้องการออกใบกำกับภาษีในนามนิติบุคคล
    Wait Until Element Is Visible    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]    ${TIMEOUT}
    Click Element    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]
    Wait Until Page Contains    ข้อมูลนิติบุคคล/บริษัท    ${TIMEOUT}

TC-004 Corporate Validation Missing Company Name
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Upload Slip File    ${SLIP_JPG}
    Select Payment Method    ${METHOD_PROMPTPAY}
    Input Payment Amount    100
    Select Document Type Tax Invoice
    Click Element    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]
    # กรอก tax id + address แต่ไม่กรอกชื่อบริษัท
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    1234567890123
    Input Text    xpath=//label[contains(.,'ที่อยู่ตามทะเบียนภาษี')]/following::textarea[1]    Test Address
    Click Submit Proof Button
    Wait Until Page Contains    กรุณาระบุชื่อบริษัท    ${TIMEOUT}

TC-005 Corporate Validation Invalid TaxId
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Upload Slip File    ${SLIP_JPG}
    Select Payment Method    ${METHOD_PROMPTPAY}
    Input Payment Amount    100
    Select Document Type Tax Invoice
    Click Element    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]
    Input Text    xpath=//label[contains(.,'ชื่อบริษัท')]/following::input[1]    Test Co
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    123
    Input Text    xpath=//label[contains(.,'ที่อยู่ตามทะเบียนภาษี')]/following::textarea[1]    Test Address
    Click Submit Proof Button
    Wait Until Page Contains    13 หลัก    ${TIMEOUT}

TC-006 Corporate Validation Missing Address
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Upload Slip File    ${SLIP_JPG}
    Select Payment Method    ${METHOD_PROMPTPAY}
    Input Payment Amount    100
    Select Document Type Tax Invoice
    Click Element    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]
    Input Text    xpath=//label[contains(.,'ชื่อบริษัท')]/following::input[1]    Test Co
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    1234567890123
    Click Submit Proof Button
    Wait Until Page Contains    กรุณาระบุที่อยู่ตามทะเบียนภาษี    ${TIMEOUT}

TC-007 Corporate Submit Success
    [Documentation]    ส่งหลักฐานพร้อม corporate info (ถ้า booking นี้ยังไม่ถูกส่งมาก่อน)
    Login As Passenger
    ${booking_id}=    Open First Unpaid Upload Slip Page
    Upload Slip File    ${SLIP_JPG}
    Select Payment Method    ${METHOD_PROMPTPAY}
    Input Payment Amount    100
    Select Document Type Tax Invoice
    Click Element    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]
    Input Text    xpath=//label[contains(.,'ชื่อบริษัท')]/following::input[1]    Test Co
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    1234567890123
    Input Text    xpath=//label[contains(.,'ที่อยู่ตามทะเบียนภาษี')]/following::textarea[1]    Test Address
    Click Submit Proof Button
    ${ok}=    Run Keyword And Return Status    Verify Upload Success
    IF    not ${ok}
        Fail    ส่งหลักฐานไม่สำเร็จสำหรับ booking_id=${booking_id} (ตรวจ log.html/output.xml เพื่อดูสาเหตุจริง)
    END

TC-008 Post Submit Status Under Review
    Navigate To My Payments
    Wait Until Page Contains    รอตรวจสอบ    ${TIMEOUT}

TC-009 Corporate Toggle Off Hides Form
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Select Document Type Tax Invoice
    Click Element    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]
    Wait Until Page Contains    ข้อมูลนิติบุคคล/บริษัท    ${TIMEOUT}
    Click Element    xpath=//label[contains(.,'ต้องการออกใบกำกับภาษีในนามนิติบุคคล')]/preceding::input[1]
    Wait Until Page Does Not Contain    ข้อมูลนิติบุคคล/บริษัท    ${TIMEOUT}

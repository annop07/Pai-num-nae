*** Settings ***
Documentation    UAT-Bonus-SlipUpload-003: Passenger อัปโหลด Slip ประเภท PDF
...              ทดสอบการอัปโหลดหลักฐานการชำระเงิน (Slip) ประเภท PDF
...              ระบบต้องรับไฟล์ได้
...
...              Test Case: SL-07
...              Total: 4 test cases

Library          SeleniumLibrary
Library          OperatingSystem
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Setup       Login As Passenger
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
TC-001 Login As Passenger For PDF Upload
    [Documentation]    เปิดเว็บไซต์และ Login ด้วยบัญชี Passenger
    [Tags]    UAT-Bonus-SlipUpload-003    SL-07
    ${url}=    Get Location
    Should Not Contain    ${url}    /login

TC-002 Navigate To Booking Upload Page For PDF
    [Documentation]    เข้าหน้าชำระเงินที่มีสถานะรอชำระเงิน และกดปุ่ม 'อัปโหลดหลักฐาน'
    [Tags]    UAT-Bonus-SlipUpload-003    SL-07
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Wait For Element    xpath=//h1[contains(text(), 'แนบหลักฐานการชำระเงิน')]
    Wait For Element    xpath=//div[contains(@class, 'border-dashed')]

TC-003 Upload PDF Slip Successfully
    [Documentation]    SL-07: เลือกไฟล์ slip_payment.pdf ขนาด 2 MB และกด Submit
    ...                อัปโหลดสำเร็จ ระบบบันทึกไฟล์ PDF
    [Tags]    UAT-Bonus-SlipUpload-003    SL-07    critical
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Sleep    2s
    # Verify PDF file exists
    File Should Exist    ${SLIP_PDF}
    # Upload PDF file
    Upload Slip File    ${SLIP_PDF}
    # Note: PDF won't show image preview, but file should be accepted
    Sleep    1s
    # Select payment method
    Select Payment Method    ${METHOD_PROMPTPAY}
    Sleep    0.5s
    # Fill required fields: amount (required by validateBeforeSubmit)
    Input Payment Amount    100
    Sleep    0.5s
    # TAX_INVOICE เป็น default — keyword จะตรวจก่อน ไม่ toggle ปิด
    Select Document Type Tax Invoice
    Sleep    1s
    # Submit
    Click Submit Proof Button
    # Verify success
    Verify Upload Success

TC-004 Verify Booking Status Updated After PDF Upload
    [Documentation]    ตรวจสอบว่าสถานะ Booking เปลี่ยนเป็น 'รอ Driver ยืนยัน'
    [Tags]    UAT-Bonus-SlipUpload-003    SL-07
    Navigate To My Payments
    # Verify status updated
    Wait For Element    xpath=//*[contains(text(), 'รอตรวจสอบ') or contains(text(), 'UNDER_REVIEW') or contains(text(), 'PROOF_SUBMITTED')]

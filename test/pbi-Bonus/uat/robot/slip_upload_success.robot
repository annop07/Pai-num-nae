*** Settings ***
Documentation    UAT-Bonus-SlipUpload-001: Passenger อัปโหลด Slip สำเร็จ (JPG/PNG)
...              ทดสอบการอัปโหลดหลักฐานการชำระเงิน (Slip) ประเภท JPG และ PNG
...              ระบบต้องรับไฟล์และแสดงตัวอย่างได้
...
...              Test Cases: SL-01, SL-02
...              Total: 5 test cases

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
TC-001 Open Website And Login As Passenger
    [Documentation]    เปิดเว็บไซต์และ Login ด้วยบัญชี Passenger
    [Tags]    UAT-Bonus-SlipUpload-001    SL-01    smoke
    # Login is done in Test Setup
    ${url}=    Get Location
    Should Not Contain    ${url}    /login

TC-002 Navigate To Booking Upload Page
    [Documentation]    เข้าหน้าชำระเงินที่มีสถานะรอชำระเงิน และกดปุ่ม 'อัปโหลดหลักฐาน'
    [Tags]    UAT-Bonus-SlipUpload-001    SL-01
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Wait For Element    xpath=//h1[contains(text(), 'แนบหลักฐานการชำระเงิน')]
    # Verify file upload dialog/area is visible
    Wait For Element    xpath=//div[contains(@class, 'border-dashed')]
    Wait For Element    xpath=//span[contains(text(), 'อัปโหลดรูป/PDF')]

TC-003 Upload JPG Slip Successfully
    [Documentation]    SL-01: เลือกไฟล์ slip_payment.jpg ขนาด 2 MB และกด Submit
    ...                อัปโหลดสำเร็จ ระบบแสดงตัวอย่าง Slip (Preview)
    [Tags]    UAT-Bonus-SlipUpload-001    SL-01    critical
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    # Wait for page to be ready
    Sleep    2s
    # Upload JPG file
    Upload Slip File    ${SLIP_JPG}
    # Verify preview is displayed
    Verify Preview Displayed
    Sleep    1s
    # Select payment method (already selected by default)
    Select Payment Method    ${METHOD_PROMPTPAY}
    Sleep    1s
    # TAX_INVOICE is selected by default on this page
    # Wait for form to be ready
    Sleep    2s
    # Submit
    Click Submit Proof Button
    # Verify success
    Verify Upload Success

TC-004 Upload PNG Slip Successfully
    [Documentation]    SL-02: เลือกไฟล์ slip_payment.png ขนาด 3 MB และกด Submit
    ...                อัปโหลดสำเร็จ ระบบแสดงตัวอย่าง Slip (Preview)
    [Tags]    UAT-Bonus-SlipUpload-001    SL-02    critical
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID_2}
    # Wait for page to be ready
    Sleep    2s
    # Upload PNG file
    Upload Slip File    ${SLIP_PNG}
    # Verify preview is displayed
    Verify Preview Displayed
    Sleep    1s
    # Select payment method
    Select Payment Method    ${METHOD_BANK_TRANSFER}
    Sleep    1s
    # Select document type
    Select Document Type Payment Voucher
    Sleep    1s
    # Wait for form to be ready
    Sleep    2s
    # Submit
    Click Submit Proof Button
    # Verify success
    Verify Upload Success

TC-005 Verify Booking Status Updated After Upload
    [Documentation]    ตรวจสอบว่าสถานะ Booking เปลี่ยนเป็น 'รอตรวจสอบ'
    [Tags]    UAT-Bonus-SlipUpload-001    SL-01    SL-02
    # Navigate to My Payments to check status
    Navigate To My Payments
    # Look for the booking and verify status
    Verify Page Contains Text    รอตรวจสอบ
    # Alternative check for status display
    Wait For Element    xpath=//*[contains(text(), 'UNDER_REVIEW') or contains(text(), 'รอตรวจสอบ') or contains(text(), 'PROOF_SUBMITTED')]

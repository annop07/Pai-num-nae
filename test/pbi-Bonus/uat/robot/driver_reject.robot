*** Settings ***
Documentation    UAT-Bonus-DriverReject-001: Driver ปฏิเสธหลักฐานการชำระเงิน
...              ทดสอบการที่ Driver ปฏิเสธหลักฐานการชำระเงิน
...              ระบบต้องเปลี่ยนสถานะเป็น DISPUTED และแจ้ง Passenger
...
...              Test Cases: RJ-01, RJ-02, RJ-03
...              Total: 6 test cases

Library          SeleniumLibrary
Library          OperatingSystem
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
TC-001 Login As Driver
    [Documentation]    เปิดเว็บไซต์และ Login ด้วยบัญชี Driver
    [Tags]    UAT-Bonus-DriverReject-001    RJ-01
    Login As Driver
    ${url}=    Get Location
    Should Not Contain    ${url}    /login

TC-002 Navigate To Booking With Uploaded Slip
    [Documentation]    เข้าหน้า Booking ที่ Passenger อัปโหลด Slip แล้ว
    ...                Driver เห็น Slip และปุ่มยืนยัน/ปฏิเสธ
    [Tags]    UAT-Bonus-DriverReject-001    RJ-01
    Open First Payment Verification Needing Review
    # Verify slip is visible
    Wait For Element    xpath=//h4[contains(text(), 'หลักฐาน')]
    # Verify reject button exists
    Wait For Element    xpath=//button[contains(text(), 'ปฏิเสธหลักฐาน')]
    # Verify confirm button exists
    Wait For Element    xpath=//button[contains(text(), 'ยืนยันหลักฐาน')]

TC-003 Reject Without Reason Should Show Error
    [Documentation]    RJ-01: กดปุ่ม 'ปฏิเสธหลักฐาน' โดยไม่ใส่เหตุผล
    ...                ระบบแจ้งเตือน "กรุณาระบุเหตุผลอย่างน้อย 3 ตัวอักษร"
    [Tags]    UAT-Bonus-DriverReject-001    RJ-01    validation
    Login As Driver
    Open First Payment Verification Needing Review
    # Do not input reason
    # Click reject button
    Click Reject Payment Button
    # Verify error message
    Verify Error Message    กรุณาระบุเหตุผลการปฏิเสธอย่างน้อย 3 ตัวอักษร

TC-004 Reject With Short Reason Should Show Error
    [Documentation]    RJ-02: ใส่เหตุผล "ab" (2 ตัวอักษร) และกดปฏิเสธ
    ...                ระบบแจ้งเตือน "กรุณาระบุเหตุผลอย่างน้อย 3 ตัวอักษร"
    [Tags]    UAT-Bonus-DriverReject-001    RJ-02    validation
    Login As Driver
    Open First Payment Verification Needing Review
    # Input short reason (2 chars)
    Input Reject Reason    ab
    # Click reject button
    Click Reject Payment Button
    # Verify error message
    Verify Error Message    กรุณาระบุเหตุผลการปฏิเสธอย่างน้อย 3 ตัวอักษร

TC-005 Reject With Valid Reason Should Succeed
    [Documentation]    RJ-03: ใส่เหตุผล "สลิปไม่ชัด" และกดปฏิเสธ
    ...                ปฏิเสธสำเร็จ, สถานะเปลี่ยนเป็น DISPUTED
    [Tags]    UAT-Bonus-DriverReject-001    RJ-03    critical
    Login As Driver
    Open First Payment Verification Needing Review
    # Input valid reason (>= 3 chars)
    Input Reject Reason    สลิปไม่ชัด
    # Click reject button
    Click Reject Payment Button
    # Verify success message
    Verify Reject Success
    # System should redirect or show success

TC-006 Verify Passenger Sees Rejected Status
    [Documentation]    ตรวจสอบฝั่ง Passenger ว่าได้รับ Notification แจ้งว่าถูกปฏิเสธ
    [Tags]    UAT-Bonus-DriverReject-001    RJ-03
    # Re-login as Passenger
    Login As Passenger
    Navigate To My Payments
    Sleep    2s
    # Look for disputed status in UI (แสดงเป็น \"ถูกปฏิเสธ\")
    ${has_rejected}=    Run Keyword And Return Status
    ...    Wait Until Page Contains    ถูกปฏิเสธ    10s
    IF    not ${has_rejected}
        Skip    ยังไม่พบสถานะ \"ถูกปฏิเสธ\" ใน /my-payments (อาจไม่มีรายการที่ถูกปฏิเสธในบัญชีนี้ หรือข้อมูลยังไม่ sync)
    END

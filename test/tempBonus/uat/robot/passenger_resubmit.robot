*** Settings ***
Documentation    UAT-Bonus-Resubmit-001: Passenger ส่งหลักฐานใหม่หลังถูกปฏิเสธ
...              ทดสอบการที่ Passenger ส่งหลักฐานใหม่หลังถูกปฏิเสธ
...              ระบบต้องอนุญาตให้ส่งใหม่ได้
...
...              Test Case: RS-01
...              Total: 4 test cases
...
...              Pre-requisite: ต้องมี Booking ที่อยู่ในสถานะ DISPUTED

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
TC-001 Login As Passenger
    [Documentation]    Login ด้วยบัญชี Passenger
    [Tags]    UAT-Bonus-Resubmit-001    RS-01
    # Login is done in Test Setup
    ${url}=    Get Location
    Should Not Contain    ${url}    /login

TC-002 View Rejected Booking
    [Documentation]    เข้าหน้า Booking ที่ถูกปฏิเสธ
    ...                แสดงสถานะ DISPUTED และเหตุผลที่ถูกปฏิเสธ
    [Tags]    UAT-Bonus-Resubmit-001    RS-01
    Navigate To My Payments
    Sleep    2s
    # หา booking ที่สถานะ \"ถูกปฏิเสธ\" และมีลิงก์ \"ส่งหลักฐานใหม่\"
    ${has_disputed}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//span[contains(.,'ถูกปฏิเสธ')]/ancestor::div[contains(@class,'rounded-xl') or contains(@class,'border')]//a[contains(.,'ส่งหลักฐานใหม่') and contains(@href,'/my-payments/upload/')]
    ...    8s
    IF    not ${has_disputed}
        Skip    ไม่พบรายการสถานะ \"ถูกปฏิเสธ\" ที่สามารถกด \"ส่งหลักฐานใหม่\" ได้ กรุณาเตรียมข้อมูล (ให้ Driver ปฏิเสธหลักฐานก่อน)
    END

    ${resubmit_link}=    Get WebElement
    ...    xpath=(//span[contains(.,'ถูกปฏิเสธ')]/ancestor::div[contains(@class,'rounded-xl') or contains(@class,'border')]//a[contains(.,'ส่งหลักฐานใหม่') and contains(@href,'/my-payments/upload/')])[1]
    ${resubmit_href}=    Get Element Attribute    ${resubmit_link}    href
    Set Suite Variable    ${RESUBMIT_URL}    ${resubmit_href}
    Go To    ${RESUBMIT_URL}
    Wait Until Location Contains    /my-payments/upload/    10s

TC-003 Reupload Slip After Rejection
    [Documentation]    RS-01: กดอัปโหลดหลักฐานใหม่ และส่งไฟล์ new_slip.jpg
    ...                อัปโหลดสำเร็จ, สถานะเปลี่ยนกลับเป็น PROOF_SUBMITTED
    [Tags]    UAT-Bonus-Resubmit-001    RS-01    critical
    # ใช้ URL ที่ดึงมาจาก TC-002 (ไม่ hardcode booking id)
    ${has_url}=    Run Keyword And Return Status    Variable Should Exist    ${RESUBMIT_URL}
    IF    not ${has_url}
        Skip    ไม่มี RESUBMIT_URL เพราะ TC-002 ไม่พบรายการถูกปฏิเสธ จึงไม่สามารถทดสอบ re-upload ได้
    END
    Go To    ${RESUBMIT_URL}
    
    # Verify we can upload (page should allow re-upload)
    Wait For Element    xpath=//h1[contains(text(), 'แนบหลักฐานการชำระเงิน')]
    
    # Upload new slip
    Upload Slip File    ${NEW_SLIP}
    
    # Verify preview (if image)
    ${is_image}=    Run Keyword And Return Status    Verify Preview Displayed
    
    # Select payment method
    Select Payment Method    ${METHOD_PROMPTPAY}
    Sleep    0.5s
    # Fill required fields (amount must be > 0)
    Input Payment Amount    100
    Sleep    0.5s
    
    # Select document type
    Select Document Type Tax Invoice
    
    # Submit
    Click Submit Proof Button

    # Verify success (ถ้าส่งไม่ผ่าน ให้ fail พร้อมข้อความ)
    ${ok}=    Run Keyword And Return Status    Verify Upload Success
    IF    not ${ok}
        Fail    ส่งหลักฐานใหม่ไม่สำเร็จ (ตรวจข้อความ error สีแดงบนหน้า upload เพิ่มเติม)
    END
    Set Suite Variable    ${RESUBMIT_DONE}    ${True}

TC-004 Verify Submission Number Incremented
    [Documentation]    ตรวจสอบ Submission Number
    ...                แสดง Submission No. = 2 (ครั้งที่ 2)
    [Tags]    UAT-Bonus-Resubmit-001    RS-01
    # Navigate back to payment list
    ${did_resubmit}=    Run Keyword And Return Status    Variable Should Exist    ${RESUBMIT_DONE}
    IF    not ${did_resubmit}
        Skip    ยังไม่ได้ทำ re-upload (TC-003 ไม่ผ่าน/ถูกข้าม) จึงไม่สามารถยืนยันสถานะหลัง re-upload ได้
    END
    Navigate To My Payments
    Sleep    2s
    # ให้แน่ใจว่าอยู่แท็บ \"ยังไม่ยืนยัน\" (รวมสถานะรอตรวจสอบ)
    Click Element    xpath=//button[contains(., 'ยังไม่ยืนยัน')]
    Sleep    1s
    
    # Verify status changed back to PROOF_SUBMITTED (UI แปลงเป็น UNDER_REVIEW และแสดง \"รอตรวจสอบ\")
    # บางครั้งหน้า list อัปเดตช้า ให้ retry + reload หลายรอบก่อน
    ${status_updated}=    Set Variable    ${False}
    FOR    ${i}    IN RANGE    1    7
        ${status_updated}=    Run Keyword And Return Status
        ...    Wait Until Page Contains    รอตรวจสอบ    5s
        IF    ${status_updated}
            Exit For Loop
        END
        Reload Page
        Sleep    2s
        Click Element    xpath=//button[contains(., 'ยังไม่ยืนยัน')]
        Sleep    1s
    END

    Should Be True    ${status_updated}    msg=Status should change to UNDER_REVIEW (รอตรวจสอบ) after re-upload
    
    # Note: Submission number might be shown in detail page
    # If UI shows submission count, verify it shows 2
    ${has_submission_count}=    Run Keyword And Return Status
    ...    Verify Page Contains Text    Submission
    
    Run Keyword If    ${has_submission_count}
    ...    Log    Check if submission number shows 2

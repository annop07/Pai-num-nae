*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource   common.resource
Resource   variables.resource

*** Keywords ***
# =============================================================================
# Login Keywords
# =============================================================================
Login As Passenger
    [Documentation]    Login with passenger credentials
    Go To    ${LOGIN_URL}
    Wait Until Element Is Visible    id=identifier    ${TIMEOUT}
    Input Text    id=identifier    ${PASSENGER_EMAIL}
    Input Text    id=password    ${PASSENGER_PASSWORD}
    Click Button    xpath=//button[contains(text(), 'เข้าสู่ระบบ') or @type='submit']
    Wait Until Location Does Not Contain    /login    ${TIMEOUT}

Login As Driver
    [Documentation]    Login with driver credentials
    Go To    ${LOGIN_URL}
    Wait Until Element Is Visible    id=identifier    ${TIMEOUT}
    Input Text    id=identifier    ${DRIVER_EMAIL}
    Input Text    id=password    ${DRIVER_PASSWORD}
    Click Button    xpath=//button[contains(text(), 'เข้าสู่ระบบ') or @type='submit']
    Wait Until Location Does Not Contain    /login    ${TIMEOUT}

# =============================================================================
# Navigation Keywords - Passenger
# =============================================================================
Navigate To My Payments
    [Documentation]    Navigate to My Payments page
    Go To    ${MY_PAYMENTS_URL}
    Wait Until Location Contains    /my-payments    ${TIMEOUT}

Navigate To Upload Slip Page
    [Documentation]    Navigate to slip upload page for specific booking
    [Arguments]    ${booking_id}
    Go To    ${BASE_URL}/my-payments/upload/${booking_id}
    Wait Until Location Contains    /my-payments/upload    ${TIMEOUT}
    Wait For Element    xpath=//h1[contains(text(), 'แนบหลักฐานการชำระเงิน')]

Open First Unpaid Upload Slip Page
    [Documentation]    เปิดหน้าแนบหลักฐานของรายการแรกที่ยังแนบได้ (UNPAID) แล้วคืนค่า booking_id
    Navigate To My Payments
    # เลือกแท็บ "ยังไม่ยืนยัน" ถ้ามี
    ${has_unpaid_tab}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//*[self::button or self::a][contains(.,'ยังไม่ยืนยัน')]
    ...    2s
    IF    ${has_unpaid_tab}
        Click Element    xpath=//*[self::button or self::a][contains(.,'ยังไม่ยืนยัน')]
    END
    ${has_attach}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=(//*[self::a or self::button][contains(.,'แนบหลักฐาน')])[1]
    ...    5s
    IF    not ${has_attach}
        Fail    ไม่พบปุ่ม "แนบหลักฐาน" ในหน้า การชำระเงินของฉัน (ต้องมี booking UNPAID ที่ยังไม่เคยส่งหลักฐาน)
    END
    Click Element    xpath=(//*[self::a or self::button][contains(.,'แนบหลักฐาน')])[1]
    Wait Until Location Contains    /my-payments/upload/    ${TIMEOUT}
    ${url}=    Get Location
    ${booking_id}=    Replace String Using Regexp    ${url}    .*/my-payments/upload/([^/?#]+).*    \\1
    Should Not Be Equal    ${booking_id}    ${url}
    RETURN    ${booking_id}

Navigate To Payment Document Page
    [Documentation]    Navigate to document page (requires confirmation id)
    [Arguments]    ${confirmation_id}
    Go To    ${BASE_URL}/my-payments/document/${confirmation_id}
    Wait Until Location Contains    /my-payments/document    ${TIMEOUT}

# =============================================================================
# Navigation Keywords - Driver
# =============================================================================
Navigate To Check Payments
    [Documentation]    Navigate to Check Payments page (Driver)
    Go To    ${CHECK_PAYMENTS_URL}
    Wait Until Location Contains    /check-payments    ${TIMEOUT}

Navigate To Verify Payment Page
    [Documentation]    Navigate to payment verification page for specific confirmation
    [Arguments]    ${confirmation_id}
    Go To    ${BASE_URL}/check-payments/verify/${confirmation_id}
    Wait Until Location Contains    /check-payments/verify    ${TIMEOUT}
    Wait For Element    xpath=//h4[contains(text(), 'หลักฐาน')]

Open First Payment Verification Needing Review
    [Documentation]    เปิดหน้า Verify ของเคสแรกที่มีหลักฐาน (รอตรวจ) อัตโนมัติ
    ...    ใช้จากหน้า /check-payments -> กด \"ตรวจสอบ\" route แรก -> เลือกผู้โดยสารที่สถานะ \"รอตรวจ\"
    Go To    ${BASE_URL}/check-payments
    Wait Until Location Contains    /check-payments    ${TIMEOUT}
    Wait Until Page Contains    ตรวจสอบการชำระเงิน    ${TIMEOUT}
    # เปิด modal รายชื่อผู้โดยสารของ route แรก
    Wait Until Element Is Visible    xpath=(//button[contains(.,'ตรวจสอบ')])[1]    ${TIMEOUT}
    Click Element    xpath=(//button[contains(.,'ตรวจสอบ')])[1]
    Wait Until Page Contains    ผู้โดยสารทั้งหมด    ${TIMEOUT}
    # เลือกแถวที่ \"รอตรวจ\" และมีลิงก์ตรวจสอบการชำระเงิน
    ${has_review}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//span[contains(.,'รอตรวจ')]/ancestor::div[contains(@class,'rounded-xl')]//a[contains(.,'ตรวจสอบการชำระเงิน')]    8s
    IF    not ${has_review}
        Skip    ไม่พบผู้โดยสารสถานะ \"รอตรวจ\" (ต้องมีเคสที่ผู้โดยสารส่งหลักฐานแล้ว) กรุณาเตรียมข้อมูลก่อนรัน test
    END
    Click Element    xpath=(//span[contains(.,'รอตรวจ')]/ancestor::div[contains(@class,'rounded-xl')]//a[contains(.,'ตรวจสอบการชำระเงิน')])[1]
    Wait Until Location Contains    /check-payments/verify/    ${TIMEOUT}
    Wait For Element    xpath=//h4[contains(text(), 'หลักฐาน')]

# =============================================================================
# Upload Keywords
# =============================================================================
Click Upload Area
    [Documentation]    Click on the upload area to trigger file input
    Wait And Click    xpath=//div[contains(@class, 'border-dashed')]

Upload Slip File
    [Documentation]    Upload a slip file
    [Arguments]    ${file_path}
    # Convert to absolute path to avoid "path is not canonical" error
    ${abs_path}=    Normalize Path    ${file_path}
    Log    Uploading file: ${abs_path}
    ${input}=    Get WebElement    xpath=//input[@type='file']
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${input}
    Choose File    xpath=//input[@type='file']    ${abs_path}
    Sleep    2s    # Wait for file processing and preview

Verify Preview Displayed
    [Documentation]    Verify that image preview is displayed
    Wait For Element    xpath=//img[contains(@alt, 'Preview') or contains(@class, 'object-contain')]

Verify No Preview Displayed
    [Documentation]    Verify that no preview image is shown
    Element Should Not Be Visible    xpath=//img[contains(@alt, 'Preview')]

# =============================================================================
# Form Input Keywords
# =============================================================================
Select Payment Method
    [Documentation]    Select payment method from dropdown
    [Arguments]    ${method}
    Wait And Select From List By Value    xpath=//select[contains(@class, 'border-gray-300')]    ${method}

Input Payment Amount
    [Documentation]    Input payment amount
    [Arguments]    ${amount}
    Wait And Input Text    xpath=//input[@type='number']    ${amount}

Input Payment Note
    [Documentation]    Input note in textarea
    [Arguments]    ${note}
    Wait And Input Text    xpath=//textarea    ${note}

Select Document Type Tax Invoice
    [Documentation]    เปิด TAX_INVOICE — ถ้า active อยู่แล้วไม่ click ซ้ำ (กันปิด)
    ${class}=    Get Element Attribute    xpath=//button[contains(text(), 'ใบกำกับภาษี')]    class
    ${is_active}=    Run Keyword And Return Status    Should Contain    ${class}    border-blue-600
    IF    not ${is_active}
        Wait And Click    xpath=//button[contains(text(), 'ใบกำกับภาษี')]
    END

Select Document Type Payment Voucher
    [Documentation]    เปิด PAYMENT_VOUCHER — ถ้า active อยู่แล้วไม่ click ซ้ำ (กันปิด)
    ${class}=    Get Element Attribute    xpath=//button[contains(text(), 'ใบสำคัญรับเงิน')]    class
    ${is_active}=    Run Keyword And Return Status    Should Contain    ${class}    border-blue-600
    IF    not ${is_active}
        Wait And Click    xpath=//button[contains(text(), 'ใบสำคัญรับเงิน')]
    END

# =============================================================================
# Submit Keywords
# =============================================================================
Click Submit Proof Button
    [Documentation]    Click the submit proof button
    ...    ใช้ .//* แทน text() เพราะข้อความอยู่ใน <span> ลูก ไม่ใช่ใน <button> โดยตรง
    ${button}=    Set Variable    xpath=//button[.//*[contains(text(), 'ส่งหลักฐาน')] or .//*[contains(text(), 'กำลังส่ง')]]
    Sleep    1s
    Execute JavaScript    Array.from(document.querySelectorAll("button")).find(b => b.textContent.trim().includes("ส่งหลักฐาน"))?.scrollIntoView({block:"center"})
    Sleep    1s
    Wait Until Element Is Visible    ${button}    ${TIMEOUT}
    Wait Until Element Is Enabled    ${button}    ${TIMEOUT}
    Click Element    ${button}
    Sleep    ${DEMO_SPEED}

Verify Upload Success
    [Documentation]    Verify that upload was successful
    Wait For Element    xpath=//h2[contains(text(), 'บันทึกสำเร็จ')]
    Verify Page Contains Text    บันทึกสำเร็จ

Verify Error Message
    [Documentation]    Verify error message is displayed
    [Arguments]    ${expected_message}
    Wait For Element    xpath=//div[contains(@class, 'text-red') or contains(@class, 'bg-red')]
    Verify Page Contains Text    ${expected_message}

Verify Validation Error
    [Documentation]    Verify form validation error
    [Arguments]    ${expected_message}
    Wait For Element Contains Text    xpath=//div[contains(@class, 'border-red')]    ${expected_message}

# =============================================================================
# Driver Verification Keywords
# =============================================================================
View Uploaded Slip
    [Documentation]    View the slip uploaded by passenger
    Wait For Element    xpath=//img[contains(@alt, 'evidence') or contains(@class, 'object-contain')]

Click Confirm Payment Button
    [Documentation]    Click confirm payment button (Driver)
    Wait And Click    xpath=//button[contains(text(), 'ยืนยันหลักฐาน')]

Click Reject Payment Button
    [Documentation]    Click reject payment button (Driver)
    Wait And Click    xpath=//button[contains(text(), 'ปฏิเสธหลักฐาน')]

Input Reject Reason
    [Documentation]    Input rejection reason
    [Arguments]    ${reason}
    Wait And Input Text    xpath=//textarea[contains(@placeholder, 'ปฏิเสธ') or @id='rejectReason']    ${reason}

Input Method Mismatch Reason
    [Documentation]    Input reason for method mismatch
    [Arguments]    ${reason}
    Wait And Input Text    xpath=//textarea[preceding-sibling::label[contains(text(), 'เหตุผลเมื่อวิธีชำระไม่ตรงกัน')]]    ${reason}

Select Verified Payment Method
    [Documentation]    Select verified payment method (Driver)
    [Arguments]    ${method}
    Wait And Select From List By Value    xpath=//select[following-sibling::*[contains(text(), 'วิธีรับเงินจริง')] or preceding-sibling::label[contains(text(), 'วิธีรับเงินจริง')]]    ${method}

Verify Confirm Success
    [Documentation]    Verify payment confirmation success
    Wait For Element    xpath=//div[contains(@class, 'text-green') or contains(@class, 'bg-green')]
    Verify Page Contains Text    ยืนยันหลักฐานสำเร็จ

Verify Reject Success
    [Documentation]    Verify payment rejection success
    Verify Page Contains Text    ปฏิเสธหลักฐานสำเร็จ

# =============================================================================
# Driver Document Issuance Keywords (Tax Invoice / Payment Voucher)
# =============================================================================
Open First Payment Verification Confirmed
    [Documentation]    เปิดหน้า Verify ของเคสแรกที่สถานะ \"ยืนยันแล้ว\" อัตโนมัติ (มี confirmationId)
    Go To    ${BASE_URL}/check-payments
    Wait Until Location Contains    /check-payments    ${TIMEOUT}
    Wait Until Page Contains    ตรวจสอบการชำระเงิน    ${TIMEOUT}
    Wait Until Element Is Visible    xpath=(//button[contains(.,'ตรวจสอบ')])[1]    ${TIMEOUT}
    Click Element    xpath=(//button[contains(.,'ตรวจสอบ')])[1]
    Wait Until Page Contains    ผู้โดยสารทั้งหมด    ${TIMEOUT}
    ${has_confirmed}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//span[contains(.,'ยืนยันแล้ว')]/ancestor::div[contains(@class,'rounded-xl')]//a[contains(.,'ตรวจสอบการชำระเงิน')]
    ...    8s
    IF    not ${has_confirmed}
        Skip    ไม่พบผู้โดยสารสถานะ \"ยืนยันแล้ว\" ที่มีลิงก์ตรวจสอบการชำระเงิน กรุณาเตรียมข้อมูลก่อนรัน
    END
    Click Element    xpath=(//span[contains(.,'ยืนยันแล้ว')]/ancestor::div[contains(@class,'rounded-xl')]//a[contains(.,'ตรวจสอบการชำระเงิน')])[1]
    Wait Until Location Contains    /check-payments/verify/    ${TIMEOUT}
    Wait For Element    xpath=//h4[contains(text(), 'หลักฐาน')]

Select Document Type For Issue
    [Arguments]    ${doc_type}
    [Documentation]    เลือกประเภทเอกสารในหน้า verify (TAX_INVOICE / PAYMENT_VOUCHER)
    Wait Until Element Is Visible    xpath=//label[contains(.,'ประเภทเอกสาร')]/following::select[1]    ${TIMEOUT}
    Select From List By Value    xpath=//label[contains(.,'ประเภทเอกสาร')]/following::select[1]    ${doc_type}

Click Issue Document Button
    [Documentation]    กดปุ่ม \"ออกเอกสาร\" (ต้องอยู่สถานะ CONFIRMED)
    Wait Until Element Is Visible    xpath=//button[.//*[contains(.,'ออกเอกสาร')] or contains(.,'ออกเอกสาร')]    ${TIMEOUT}
    Scroll Element Into View    xpath=//button[.//*[contains(.,'ออกเอกสาร')] or contains(.,'ออกเอกสาร')]
    Click Element    xpath=//button[.//*[contains(.,'ออกเอกสาร')] or contains(.,'ออกเอกสาร')]

Verify Document Issued List Contains
    [Arguments]    ${expected_type_th}
    [Documentation]    ตรวจว่าในส่วน \"เอกสารที่ออกแล้ว\" มีรายการตามประเภทที่คาดหวัง
    Wait Until Page Contains    เอกสารที่ออกแล้ว    ${TIMEOUT}
    Wait Until Page Contains    ${expected_type_th}    ${TIMEOUT}

Handle Tax Profile Modal If Present
    [Documentation]    ถ้า modal \"กรอกข้อมูลภาษีครั้งแรก\" โผล่ขึ้นมา ให้กรอกขั้นต่ำและบันทึก
    ${has_modal}=    Run Keyword And Return Status
    ...    Wait Until Page Contains    กรอกข้อมูลภาษีครั้งแรก    3s
    IF    not ${has_modal}
        RETURN
    END
    # กรอกแบบบุคคลธรรมดา (ขั้นต่ำ)
    Wait Until Element Is Visible    xpath=//label[contains(.,'ชื่อผู้เสียภาษี')]/following::input[1]    ${TIMEOUT}
    Input Text    xpath=//label[contains(.,'ชื่อผู้เสียภาษี')]/following::input[1]    Test Taxpayer
    Input Text    xpath=//label[contains(.,'เลขผู้เสียภาษี')]/following::input[1]    1234567890123
    Input Text    xpath=//label[contains(.,'ที่อยู่')]/following::textarea[1]    Khon Kaen University
    Click Element    xpath=//button[contains(.,'บันทึก') and (contains(.,'ออกใบกำกับภาษี') or contains(.,'บันทึก'))]
    # รอข้อความสำเร็จหรือ modal ปิด
    Wait Until Page Does Not Contain    กรอกข้อมูลภาษีครั้งแรก    15s

# =============================================================================
# Document Keywords
# =============================================================================
Verify Download Button Disabled
    [Documentation]    Verify download button is disabled
    Element Should Be Disabled    xpath=//button[contains(text(), 'ดาวน์โหลด') or contains(text(), 'Download')]

Verify Download Button Enabled
    [Documentation]    Verify download button is enabled
    Wait Until Element Is Enabled    xpath=//button[contains(text(), 'ดาวน์โหลด') or contains(text(), 'Download')]    ${TIMEOUT}

Verify No Download Available
    [Documentation]    Verify no download options are shown
    Verify Page Contains Text    ไม่มีรายการดาวน์โหลด
    
# =============================================================================
# Status Keywords
# =============================================================================
Verify Payment Status
    [Documentation]    Verify current payment status
    [Arguments]    ${expected_status}
    Verify Page Contains Text    ${expected_status}

Verify Booking Status Waiting Driver
    [Documentation]    Verify booking status is waiting for driver confirmation
    Verify Page Contains Text    รอ Driver ยืนยัน

Verify Booking Status Disputed
    [Documentation]    Verify booking status is disputed
    Verify Page Contains Text    DISPUTED

Verify Submission Number
    [Documentation]    Verify the submission number
    [Arguments]    ${expected_number}
    Verify Page Contains Text    Submission No. = ${expected_number}

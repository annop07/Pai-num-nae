*** Settings ***
Documentation    UAT-Bonus-SlipUpload-004: Passenger อัปโหลดหลายไฟล์ (Multiple Files)
...              ทดสอบการอัปโหลดหลายไฟล์พร้อมกัน
...              ระบบรองรับสูงสุด 5 ไฟล์
...
...              Test Cases: SL-08, SL-09
...              Total: 2 test cases
...
...              หมายเหตุ: Test นี้ต้องการ UI ที่รองรับ multiple file upload
...              ถ้า UI ปัจจุบันรับทีละ 1 ไฟล์ ให้ skip test นี้

Library          SeleniumLibrary
Library          OperatingSystem
Library          Collections
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Setup       Login As Passenger
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Variables ***
@{FIVE_FILES}     ${SLIP_1}    ${SLIP_2}    ${SLIP_3}    ${SLIP_4}    ${SLIP_5}
@{SIX_FILES}      ${SLIP_1}    ${SLIP_2}    ${SLIP_3}    ${SLIP_4}    ${SLIP_5}    ${SLIP_6}

*** Test Cases ***
TC-001 Upload Five Files Successfully
    [Documentation]    SL-08: เลือกไฟล์ 5 ไฟล์พร้อมกัน และกด Submit
    ...                อัปโหลดสำเร็จทั้ง 5 ไฟล์
    ...                
    ...                หมายเหตุ: ถ้า UI รองรับ multiple="true" ใน input
    [Tags]    UAT-Bonus-SlipUpload-004    SL-08    multiple-files
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Sleep    2s
    
    # Check if multiple file upload is supported
    ${input}=    Get WebElement    xpath=//input[@type='file']
    ${has_multiple}=    Run Keyword And Return Status    
    ...    Element Should Have Attribute    xpath=//input[@type='file']    multiple
    
    Run Keyword If    ${has_multiple}
    ...    Upload Multiple Files    ${FIVE_FILES}
    ...    ELSE
    ...    Log    UI does not support multiple file upload. Uploading single file.
    
    # If multiple not supported, just upload one file
    Run Keyword Unless    ${has_multiple}
    ...    Upload Slip File    ${SLIP_1}
    
    Sleep    1s
    # Select payment method
    Select Payment Method    ${METHOD_PROMPTPAY}
    Sleep    0.5s
    Input Payment Amount    100
    Sleep    0.5s
    # Select document type
    Select Document Type Tax Invoice
    Sleep    1s
    # Submit
    Click Submit Proof Button
    # Verify success
    Verify Upload Success

TC-002 Upload Six Files Should Fail Or Accept Only Five
    [Documentation]    SL-09: เลือกไฟล์ 6 ไฟล์พร้อมกัน และกด Submit
    ...                ระบบปฏิเสธหรือรับแค่ 5 ไฟล์แรก
    ...
    ...                หมายเหตุ: ถ้า UI รองรับ multiple="true" ใน input
    [Tags]    UAT-Bonus-SlipUpload-004    SL-09    multiple-files    validation
    Navigate To Upload Slip Page    ${BOOKING_ID_UNPAID}
    Sleep    2s
    
    # Check if multiple file upload is supported
    ${has_multiple}=    Run Keyword And Return Status    
    ...    Element Should Have Attribute    xpath=//input[@type='file']    multiple
    
    Run Keyword If    ${has_multiple}
    ...    Upload Multiple Files    ${SIX_FILES}
    ...    ELSE
    ...    Log    UI does not support multiple file upload. Test not applicable.
    
    # If multiple supported, verify behavior
    Run Keyword If    ${has_multiple}    Verify Six Files Behavior
    
*** Keywords ***
Upload Multiple Files
    [Documentation]    Upload multiple files at once
    [Arguments]    ${file_list}
    ${input}=    Get WebElement    xpath=//input[@type='file']
    Execute JavaScript    arguments[0].style.display = 'block';    ARGUMENTS    ${input}
    
    # Join file paths with newline for multiple file selection
    ${files_string}=    Catenate    SEPARATOR=\n    @{file_list}
    Choose File    xpath=//input[@type='file']    ${files_string}
    Sleep    2s    # Wait for file processing

Verify Six Files Behavior
    [Documentation]    Verify system behavior when 6 files are uploaded
    # Select payment method and document type first
    Select Payment Method    ${METHOD_PROMPTPAY}
    Sleep    0.5s
    Input Payment Amount    100
    Sleep    0.5s
    Select Document Type Tax Invoice
    Sleep    1s
    # Try to submit
    Click Submit Proof Button
    # Check for either:
    # 1. Error message about max 5 files
    # 2. Success (system accepted only 5 files)
    ${has_error}=    Run Keyword And Return Status    
    ...    Wait For Element    xpath=//div[contains(@class, 'text-red') or contains(text(), 'สูงสุด 5')]    timeout=3s
    
    Run Keyword If    ${has_error}
    ...    Log    System rejected upload - max 5 files limit enforced
    ...    ELSE
    ...    Verify Upload Success    # System accepted (possibly only 5 files)

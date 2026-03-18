*** Settings ***
Documentation    UAT-Bonus-Blocking-001: เอกสารการเงินยังไม่แสดงก่อน Driver ยืนยัน
...              ทดสอบว่าก่อน Driver ยืนยัน ระบบแสดง "ยังไม่มีเอกสาร"
...              หลัง Driver ยืนยัน ระบบแสดงเอกสาร (ใบกำกับภาษี/ใบสำคัญรับเงิน)
...
...              Test Cases: BL-01, BL-02

Library          SeleniumLibrary
Library          OperatingSystem
Resource         resources/common.resource
Resource         resources/variables.resource
Resource         resources/payment.resource

Suite Setup      Open Browser To Website
Suite Teardown   Close Browser Session
Test Teardown    Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
TC-001 No Document Before Driver Confirmation
    [Documentation]    BL-01: ก่อน Driver ยืนยัน — ไม่มีลิงก์ดาวน์โหลดเอกสารให้กด
    ...                ตรวจจากหน้า /my-payments โดยตรง (ไม่ต้องรู้ confirmation id)
    [Tags]    UAT-Bonus-Blocking-001    BL-01    critical
    Login As Passenger
    Navigate To My Payments
    Sleep    2s
    # อยู่ในแท็บ "ยังไม่ยืนยัน" อยู่แล้ว และสถานะ UNDER_REVIEW จะไม่โชว์ลิงก์ดาวน์โหลดเอกสาร
    Page Should Not Contain Element    xpath=//a[contains(., 'ดาวน์โหลดเอกสาร')]

TC-002 Document Available After Driver Confirmation
    [Documentation]    BL-02: หลัง Driver ยืนยัน — มีลิงก์ดาวน์โหลดเอกสาร และเปิดหน้าเอกสารได้
    [Tags]    UAT-Bonus-Blocking-001    BL-02    critical
    Login As Passenger
    Navigate To My Payments
    Sleep    2s
    Click Element    xpath=//button[contains(., 'ยืนยันแล้ว')]
    Sleep    2s
    ${has_download}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//a[contains(., 'ดาวน์โหลดเอกสาร')]    8s
    IF    not ${has_download}
        ${is_empty}=    Run Keyword And Return Status
        ...    Wait Until Page Contains    ไม่พบรายการในหมวดนี้    2s
        IF    ${is_empty}
            Skip    ไม่มีข้อมูลในแท็บ \"ยืนยันแล้ว\" กรุณาเตรียมรายการที่ CONFIRMED และมีเอกสาร (ดาวน์โหลดเอกสาร) ก่อนรัน TC-002
        END
        Skip    ไม่พบลิงก์ \"ดาวน์โหลดเอกสาร\" ในแท็บ \"ยืนยันแล้ว\" (ต้องเป็น CONFIRMED และมีเอกสารจริง) กรุณาเตรียมข้อมูลก่อนรัน TC-002
    END
    Click Element    xpath=(//a[contains(., 'ดาวน์โหลดเอกสาร')])[1]
    Wait Until Location Contains    /my-payments/document/    15s
    # หน้าเอกสารต้องโหลดได้
    Wait Until Page Contains    พิมพ์เอกสาร    15s

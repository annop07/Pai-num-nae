*** Settings ***
Documentation     UAT - Soft Delete 90 Days Simulation (Post-Delete Behavior)
Library           Process
Library           OperatingSystem

*** Variables ***
${SCRIPTS_DIR}    ${CURDIR}/resources

*** Test Cases ***
PD-03 - Deleted User Data Still Exists Before Purge Job
    [Documentation]    PD-03: ตั้ง deleted_at ย้อนหลัง 90 วัน แล้วตรวจสอบว่าข้อมูลยังอยู่ครบก่อน Purge Job รัน
    # Step 1: Set deleted_at to 90 days ago
    ${result}=    Run Process    node    ${SCRIPTS_DIR}/set_deleted_at_90days.js    TestPassenger_UAT@gmail.com
    Log    STDOUT: ${result.stdout}
    Log    STDERR: ${result.stderr}
    Should Contain    ${result.stdout}    UPDATED:1

    # Step 2: Verify user still exists in DB
    ${check}=    Run Process    node    ${SCRIPTS_DIR}/check_user_exists.js    TestPassenger_UAT@gmail.com
    Log    STDOUT: ${check.stdout}
    Log    STDERR: ${check.stderr}
    Should Contain    ${check.stdout}    USER_EXISTS:TestPassenger_UAT@gmail.com

PD-04 - User Data Permanently Deleted After Purge Job
    [Documentation]    PD-04: รัน Purge Job แบบ Manual แล้วตรวจสอบว่าข้อมูลผู้ใช้ถูกลบถาวร
    # Step 1: Run purge job
    ${result}=    Run Process    node    ${SCRIPTS_DIR}/run_purge_job.js
    Log    STDOUT: ${result.stdout}
    Log    STDERR: ${result.stderr}
    Should Contain    ${result.stdout}    PURGE_COMPLETED

    # Step 2: Verify user no longer exists
    ${check}=    Run Process    node    ${SCRIPTS_DIR}/check_user_exists.js    TestPassenger_UAT@gmail.com
    Log    STDOUT: ${check.stdout}
    Log    STDERR: ${check.stderr}
    Should Contain    ${check.stdout}    USER_NOT_FOUND

PD-05 - Related Data Handled After Purge
    [Documentation]    PD-05: หลัง Purge Job รัน ตรวจสอบข้อมูลที่เกี่ยวข้อง เช่น Booking History, Incident ว่าถูกจัดการตามนโยบาย
    ${check}=    Run Process    node    ${SCRIPTS_DIR}/check_related_data.js    TestPassenger_UAT@gmail.com
    Log    STDOUT: ${check.stdout}
    Log    STDERR: ${check.stderr}
    Should Contain    ${check.stdout}    RELATED_DATA_CLEANED

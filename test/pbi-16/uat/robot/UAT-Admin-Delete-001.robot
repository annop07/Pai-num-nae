*** Settings ***
Documentation     UAT - Admin Profile Has No Delete Account Button
Library           SeleniumLibrary
Resource          delete_account_resource.robot
Suite Setup       Open Login Page
Suite Teardown    Close All Browsers

*** Test Cases ***
AD-01 - Admin Cannot See Delete Button
    [Documentation]    AD-01: Admin เข้า Profile แล้วต้องไม่มีปุ่มลบบัญชี
    Navigate To Login Page
    Login As Admin UAT
    Open Profile Page From Any Role
    Assert Delete Button Not Visible

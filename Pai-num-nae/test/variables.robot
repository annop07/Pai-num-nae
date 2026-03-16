*** Variables ***

# =========================
# ENVIRONMENT
# =========================
${BASE_URL}         http://localhost:3001
${LOGIN_URL}        ${BASE_URL}/login
${BROWSER}          chrome

# =========================
# LOGIN
# =========================
${ADMIN_USERNAME}  admin@example.com
${ADMIN_PASSWORD}  Admin@12345

# =========================
# LOCATORS
# =========================
${USERNAME_INPUT}     id=email
${PASSWORD_INPUT}     id=password
${LOGIN_BTN}          xpath=//button[@type='submit']

${INCIDENT_MENU}      xpath=//a[contains(text(),'Incident')]
${DETAIL_INPUT}       id=detail
${STATUS_DROPDOWN}    id=status
${SUBMIT_BTN}         xpath=//button[@type='submit']

${SUCCESS_MESSAGE}    xpath=//div[contains(@class,'success')]
${ERROR_MESSAGE}      xpath=//div[contains(@class,'error')]

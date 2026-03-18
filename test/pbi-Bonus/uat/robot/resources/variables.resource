*** Variables ***
# =============================================================================
# Environment Configuration
# =============================================================================
${BASE_URL}                     http://localhost:3001
${BROWSER}                      chrome
${TIMEOUT}                      10s
${DEMO_SPEED}                   1s    # Delay between actions (0s=fast, 1s=slow, 2s=very slow)

# =============================================================================
# Test User Credentials - Passenger
# =============================================================================
${PASSENGER_EMAIL}              PassengerSlip_UAT
${PASSENGER_PASSWORD}           12345678Test

# =============================================================================
# Test User Credentials - Driver
# =============================================================================
${DRIVER_EMAIL}                 annop.sa@gmail.com
${DRIVER_PASSWORD}              0611044772za

# =============================================================================
# Test Data - Booking IDs (Update these before testing)
# =============================================================================
${BOOKING_ID_UNPAID}            cmmvv3lim000k1jztpt8km34m
${BOOKING_ID_UNPAID_2}          cmmvv3lim000k1jztpt8km34m
${BOOKING_ID_PROOF_SUBMITTED}   cmmvv3lim000k1jztpt8km34m
${BOOKING_ID_CONFIRMED}         cmmvv3lim000k1jztpt8km34m
${BOOKING_ID_DISPUTED}          cmmvv3lim000k1jztpt8km34m

# =============================================================================
# Test Data - Payment Confirmation IDs (for document/verify pages)
# IMPORTANT: document page uses /payments/confirmations/:id (NOT booking id)
# =============================================================================
${CONFIRMATION_ID_PROOF_SUBMITTED}    REPLACE_WITH_CONFIRMATION_CUID
${CONFIRMATION_ID_CONFIRMED}          REPLACE_WITH_CONFIRMATION_CUID
${CONFIRMATION_ID_FOR_VERIFY}         REPLACE_WITH_CONFIRMATION_CUID

# =============================================================================
# Test Files Path
# =============================================================================
${TEST_DATA_DIR}                /Users/annopsangsila/Desktop/Year3_2/Software_EN/Sprint/SE/Pai-num-nae/test/pbi-Bonus/uat/robot/test_data
${SLIP_JPG}                     ${TEST_DATA_DIR}/slip_payment.jpg
${SLIP_PNG}                     ${TEST_DATA_DIR}/slip_payment.png
${SLIP_PDF}                     ${TEST_DATA_DIR}/slip_payment.pdf
${FILE_MP4}                     ${TEST_DATA_DIR}/document.mp4
${FILE_LARGE}                   ${TEST_DATA_DIR}/large_slip.jpg
${FILE_EXE}                     ${TEST_DATA_DIR}/virus.exe
${NEW_SLIP}                     ${TEST_DATA_DIR}/new_slip.jpg

# Multiple files for upload test
${SLIP_1}                       ${TEST_DATA_DIR}/slip1.jpg
${SLIP_2}                       ${TEST_DATA_DIR}/slip2.jpg
${SLIP_3}                       ${TEST_DATA_DIR}/slip3.png
${SLIP_4}                       ${TEST_DATA_DIR}/slip4.png
${SLIP_5}                       ${TEST_DATA_DIR}/slip5.jpg
${SLIP_6}                       ${TEST_DATA_DIR}/slip6.jpg

# =============================================================================
# Page URLs
# =============================================================================
${LOGIN_URL}                    ${BASE_URL}/login
${MY_PAYMENTS_URL}              ${BASE_URL}/my-payments
${CHECK_PAYMENTS_URL}           ${BASE_URL}/check-payments

# =============================================================================
# Payment Methods
# =============================================================================
${METHOD_CASH}                  CASH
${METHOD_PROMPTPAY}             PROMPTPAY
${METHOD_BANK_TRANSFER}         BANK_TRANSFER
${METHOD_CARD}                  CARD
${METHOD_OTHER}                 OTHER

# =============================================================================
# Payment Status
# =============================================================================
${STATUS_UNPAID}                UNPAID
${STATUS_PROOF_SUBMITTED}       PROOF_SUBMITTED
${STATUS_CONFIRMED}             CONFIRMED
${STATUS_DISPUTED}              DISPUTED

# =============================================================================
# Document Types
# =============================================================================
${DOC_TAX_INVOICE}              TAX_INVOICE
${DOC_PAYMENT_VOUCHER}          PAYMENT_VOUCHER
${DOC_RECEIPT}                  RECEIPT

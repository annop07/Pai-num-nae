# Robot Framework UAT Tests - Person 1 (Slip Upload Flow)

## Overview

This directory contains Robot Framework UAT test cases for **Person 1** assignment:
- **Slip Upload Tests** (UAT-Bonus-SlipUpload-001 to 004)
- **Driver Reject Tests** (UAT-Bonus-DriverReject-001)
- **Passenger Resubmit Tests** (UAT-Bonus-Resubmit-001)
- **Download Blocking Tests** (UAT-Bonus-Blocking-001)

## Test Scenarios Coverage

| Scenario ID | Name | Test Cases | Robot File |
|-------------|------|------------|------------|
| UAT-Bonus-SlipUpload-001 | Passenger อัปโหลด Slip สำเร็จ (JPG/PNG) | 5 | `slip_upload_success.robot` |
| UAT-Bonus-SlipUpload-002 | Passenger อัปโหลด Slip ล้มเหลว — Validation | 4 | `slip_upload_validation.robot` |
| UAT-Bonus-SlipUpload-003 | Passenger อัปโหลด Slip ประเภท PDF | 4 | `slip_upload_pdf.robot` |
| UAT-Bonus-SlipUpload-004 | Multiple Files Upload | 2 | `slip_upload_multiple.robot` |
| UAT-Bonus-DriverReject-001 | Driver ปฏิเสธหลักฐานการชำระเงิน | 6 | `driver_reject.robot` |
| UAT-Bonus-Resubmit-001 | Passenger ส่งหลักฐานใหม่หลังถูกปฏิเสธ | 4 | `passenger_resubmit.robot` |
| UAT-Bonus-Blocking-001 | ปุ่มดาวน์โหลด Disabled ก่อน/หลัง Driver ยืนยัน | 2 | `download_blocking.robot` |

**Total: 27 Test Cases**

## Prerequisites

### 1. Install Dependencies
```bash
pip install robotframework
pip install robotframework-seleniumlibrary
pip install webdrivermanager
```

### 2. WebDriver Setup
```bash
# Install ChromeDriver
webdrivermanager chrome --linkpath /usr/local/bin

# Or download manually from:
# https://chromedriver.chromium.org/downloads
```

### 3. Prepare Test Data
Place test files in `test_data/` directory. See `test_data/README.md` for details.

### 4. Update Configuration
Edit `resources/variables.resource` to update:
- `${BASE_URL}` - Your test server URL
- `${PASSENGER_EMAIL}` / `${PASSENGER_PASSWORD}` - Test passenger credentials
- `${DRIVER_EMAIL}` / `${DRIVER_PASSWORD}` - Test driver credentials
- `${BOOKING_ID_*}` - Actual booking IDs from your test environment
- `${CONFIRMATION_ID}` - Payment confirmation ID for testing

## Directory Structure

```
robot/
├── README.md                       # This file
├── resources/
│   ├── common.resource             # Shared keywords
│   ├── variables.resource          # Configuration & variables
│   └── payment.resource            # Payment-specific keywords
├── test_data/
│   ├── README.md                   # Test data instructions
│   ├── slip_payment.jpg            # Test slip (JPG)
│   ├── slip_payment.png            # Test slip (PNG)
│   └── ...                         # Other test files
├── slip_upload_success.robot       # UAT-Bonus-SlipUpload-001
├── slip_upload_validation.robot    # UAT-Bonus-SlipUpload-002
├── slip_upload_pdf.robot           # UAT-Bonus-SlipUpload-003
├── slip_upload_multiple.robot      # UAT-Bonus-SlipUpload-004
├── driver_reject.robot             # UAT-Bonus-DriverReject-001
├── passenger_resubmit.robot        # UAT-Bonus-Resubmit-001
└── download_blocking.robot         # UAT-Bonus-Blocking-001
```

## Running Tests

### Run All Tests
```bash
cd test/pbi-Bonus/uat/robot
robot --outputdir ../results .
```

### Run Specific Test File
```bash
robot --outputdir ../results slip_upload_success.robot
```

### Run Tests by Tag
```bash
# Run only critical tests
robot --include critical --outputdir ../results .

# Run specific scenario
robot --include UAT-Bonus-SlipUpload-001 --outputdir ../results .

# Run validation tests
robot --include validation --outputdir ../results .
```

### Run with Verbose Output
```bash
robot --loglevel DEBUG --outputdir ../results .
```

### Run Headless (No Browser Window)
```bash
robot --variable BROWSER:headlesschrome --outputdir ../results .
```

## Test Tags

| Tag | Description |
|-----|-------------|
| `smoke` | Basic functionality tests |
| `critical` | Critical path tests |
| `validation` | Input validation tests |
| `security` | Security-related tests |
| `multiple-files` | Multiple file upload tests |
| `integration` | Integration/flow tests |
| `UAT-Bonus-*` | Scenario-specific tags |
| `SL-*` | Slip upload test case IDs |
| `RJ-*` | Reject test case IDs |
| `RS-*` | Resubmit test case IDs |
| `BL-*` | Blocking test case IDs |

## Test Reports

After running tests, reports are generated in `../results/`:
- `report.html` - Summary report
- `log.html` - Detailed log
- `output.xml` - Machine-readable output

## Troubleshooting

### Common Issues

1. **ChromeDriver version mismatch**
   ```bash
   # Check Chrome version
   google-chrome --version
   
   # Download matching ChromeDriver
   webdrivermanager chrome
   ```

2. **Element not found**
   - Increase `${TIMEOUT}` in `variables.resource`
   - Check if locators match current UI

3. **Login fails**
   - Verify credentials in `variables.resource`
   - Check if test server is running

4. **File upload fails**
   - Ensure test files exist in `test_data/`
   - Check file permissions

## Authors

- **Person 1 Assignment**
- Part of PBI-Bonus Payment Confirmation UAT Testing

## Related Documents

- `Test_Design_PBL-Bonus_2.md` - Test Design Document
- Backend: `/backend/src/services/payment.service.js`
- Frontend: `/frontend/pages/my-payments/upload/[id].vue`

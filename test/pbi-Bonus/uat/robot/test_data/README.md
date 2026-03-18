# Test Data Directory

This directory contains test files for Robot Framework UAT testing.

## Required Files

Before running tests, please create/place the following test files in this directory:

### Slip Upload Tests (Person 1)

| File Name | Size | Description |
|-----------|------|-------------|
| `slip_payment.jpg` | ~2 MB | Valid JPG slip image |
| `slip_payment.png` | ~3 MB | Valid PNG slip image |
| `slip_payment.pdf` | ~2 MB | Valid PDF slip document |
| `document.mp4` | ~10 MB | Invalid file type for testing |
| `large_slip.jpg` | ~15 MB | Oversized file for testing |
| `virus.exe` | ~1 MB | Invalid/unsafe file extension |
| `new_slip.jpg` | ~1 MB | Slip for re-upload test |
| `slip1.jpg` - `slip6.jpg` | ~1 MB each | Multiple files for batch upload test |

### How to Create Test Files

#### Create Dummy Image Files (macOS/Linux):
```bash
# Create 2MB JPG
dd if=/dev/urandom bs=1024 count=2048 | convert - slip_payment.jpg

# Or use ImageMagick
convert -size 1920x1080 xc:white slip_payment.jpg
convert -size 1920x1080 xc:white slip_payment.png

# Create large file (15MB)
convert -size 4000x4000 xc:white large_slip.jpg
```

#### Create Dummy PDF:
```bash
# Using ImageMagick
convert slip_payment.jpg slip_payment.pdf
```

#### Create Dummy Invalid Files:
```bash
# Create empty exe file (for testing file type validation)
touch virus.exe

# Create dummy mp4
touch document.mp4
```

### Alternative: Download Sample Files

You can also download real payment slip images from the internet for testing purposes.
Make sure the files are appropriate sizes for testing the validation rules.

## Notes

- The actual content of these files doesn't matter for most tests
- File SIZE matters for testing size limits
- File EXTENSION matters for testing file type validation
- For image preview tests, use real image files

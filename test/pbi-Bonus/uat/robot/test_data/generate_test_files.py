#!/usr/bin/env python3
"""
Generate test files for Robot Framework UAT testing
Person 1: Slip Upload Tests
"""

from PIL import Image, ImageDraw
import os
import random

# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def create_slip_image(filename, width, height, text, bg_color=(255, 255, 255), text_color=(0, 0, 0)):
    """Create a payment slip image with text"""
    img = Image.new('RGB', (width, height), color=bg_color)
    draw = ImageDraw.Draw(img)
    
    # Draw border
    draw.rectangle([10, 10, width-10, height-10], outline=(200, 200, 200), width=2)
    
    # Draw header
    draw.rectangle([10, 10, width-10, 60], fill=(52, 152, 219), outline=(41, 128, 185))
    draw.text((width//2 - 80, 25), "PAYMENT SLIP", fill=(255, 255, 255))
    
    # Draw main text
    y_position = 100
    for line in text.split('\n'):
        draw.text((30, y_position), line, fill=text_color)
        y_position += 30
    
    # Draw amount box
    draw.rectangle([30, height-120, width-30, height-60], outline=(46, 204, 113), width=2)
    draw.text((50, height-100), "Amount: 500.00 THB", fill=(39, 174, 96))
    
    # Draw timestamp
    draw.text((30, height-40), "Date: 2026-03-18 12:00:00", fill=(150, 150, 150))
    
    filepath = os.path.join(SCRIPT_DIR, filename)
    img.save(filepath, quality=95)
    print(f"Created: {filename} ({os.path.getsize(filepath):,} bytes)")
    return filepath

def create_large_image(filename, target_size_mb=15):
    """Create a large image file for size validation testing"""
    # Start with a large size
    width, height = 5000, 5000
    img = Image.new('RGB', (width, height), color=(255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Add some content
    draw.text((100, 100), "LARGE FILE TEST", fill=(255, 0, 0))
    draw.text((100, 150), f"Target size: {target_size_mb}MB", fill=(0, 0, 0))
    
    # Add random noise to increase file size
    pixels = img.load()
    if pixels is not None:
        for i in range(0, width, 2):
            for j in range(0, height, 2):
                pixels[i, j] = (
                    random.randint(200, 255),
                    random.randint(200, 255),
                    random.randint(200, 255)
                )
    
    filepath = os.path.join(SCRIPT_DIR, filename)
    # Save with high quality to increase size
    img.save(filepath, quality=100, subsampling=0)
    
    actual_size = os.path.getsize(filepath)
    print(f"Created: {filename} ({actual_size:,} bytes = {actual_size/1024/1024:.2f} MB)")
    return filepath

def create_pdf_slip(filename):
    """Create a simple PDF payment slip"""
    filepath = os.path.join(SCRIPT_DIR, filename)
    
    # Create a simple valid PDF manually
    pdf_content = b"""%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj

2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj

3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>
endobj

4 0 obj
<< /Length 200 >>
stream
BT
/F1 24 Tf
100 700 Td
(PAYMENT SLIP) Tj
/F1 12 Tf
0 -40 Td
(Transaction: TXN-2026031800001) Tj
0 -20 Td
(From: Test Passenger) Tj
0 -20 Td
(To: Test Driver) Tj
0 -20 Td
(Amount: 500.00 THB) Tj
0 -20 Td
(Date: 2026-03-18) Tj
ET
endstream
endobj

5 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj

xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000266 00000 n 
0000000518 00000 n 

trailer
<< /Size 6 /Root 1 0 R >>
startxref
595
%%EOF
"""
    
    with open(filepath, 'wb') as f:
        f.write(pdf_content)
    
    print(f"Created: {filename} ({os.path.getsize(filepath):,} bytes)")
    return filepath

def create_dummy_file(filename, content=b'dummy'):
    """Create a dummy file with minimal content"""
    filepath = os.path.join(SCRIPT_DIR, filename)
    with open(filepath, 'wb') as f:
        f.write(content)
    print(f"Created: {filename} ({os.path.getsize(filepath):,} bytes)")
    return filepath

def main():
    print("=" * 60)
    print("Generating Test Files for Robot Framework UAT")
    print("=" * 60)
    print()
    
    # 1. slip_payment.jpg (2MB target)
    print("[1/13] Creating slip_payment.jpg...")
    create_slip_image(
        "slip_payment.jpg",
        1200, 800,
        "Transaction: TXN-001\nFrom: Passenger\nTo: Driver\nRoute: Bangkok - Khon Kaen\nMethod: PromptPay"
    )
    
    # 2. slip_payment.png (3MB target)
    print("\n[2/13] Creating slip_payment.png...")
    create_slip_image(
        "slip_payment.png",
        1600, 1200,
        "Transaction: TXN-002\nFrom: Passenger\nTo: Driver\nRoute: Bangkok - Khon Kaen\nMethod: Bank Transfer",
        bg_color=(245, 245, 245)
    )
    
    # 3. slip_payment.pdf
    print("\n[3/13] Creating slip_payment.pdf...")
    create_pdf_slip("slip_payment.pdf")
    
    # 4. large_slip.jpg (15MB+ for size validation)
    print("\n[4/13] Creating large_slip.jpg (this may take a moment)...")
    create_large_image("large_slip.jpg", target_size_mb=15)
    
    # 5. new_slip.jpg (for re-upload test)
    print("\n[5/13] Creating new_slip.jpg...")
    create_slip_image(
        "new_slip.jpg",
        1000, 700,
        "Transaction: TXN-RESUBMIT\nFrom: Passenger\nTo: Driver\nNote: Re-uploaded slip\nMethod: PromptPay",
        bg_color=(255, 250, 240)
    )
    
    # 6-11. slip1.jpg to slip6.jpg (for multiple upload test)
    print("\n[6-11/13] Creating slip1.jpg to slip6.jpg...")
    for i in range(1, 7):
        create_slip_image(
            f"slip{i}.jpg",
            800, 600,
            f"Transaction: TXN-MULTI-{i:03d}\nFile: {i} of 6\nFor: Multiple upload test",
            bg_color=(240 + i*2, 240 + i*2, 255)
        )
    
    # 12. document.mp4 (invalid file type)
    print("\n[12/13] Creating document.mp4 (dummy)...")
    # Create a minimal MP4-like header
    mp4_header = bytes([
        0x00, 0x00, 0x00, 0x20,  # size
        0x66, 0x74, 0x79, 0x70,  # ftyp
        0x69, 0x73, 0x6F, 0x6D,  # isom
        0x00, 0x00, 0x00, 0x01,  # version
        0x69, 0x73, 0x6F, 0x6D,  # isom
        0x61, 0x76, 0x63, 0x31,  # avc1
    ])
    create_dummy_file("document.mp4", mp4_header + b'\x00' * 1000)
    
    # 13. virus.exe (unsafe file extension)
    print("\n[13/13] Creating virus.exe (dummy)...")
    # Create a minimal PE-like header (but not a real executable)
    exe_header = b'MZ' + b'\x00' * 100 + b'This is not a real executable - for testing only'
    create_dummy_file("virus.exe", exe_header)
    
    print()
    print("=" * 60)
    print("All test files created successfully!")
    print("=" * 60)
    
    # List all files
    print("\nFiles in test_data/:")
    for f in sorted(os.listdir(SCRIPT_DIR)):
        if f.endswith(('.jpg', '.png', '.pdf', '.mp4', '.exe')):
            size = os.path.getsize(os.path.join(SCRIPT_DIR, f))
            print(f"  {f:25s} {size:>12,} bytes ({size/1024/1024:.2f} MB)")

if __name__ == "__main__":
    main()

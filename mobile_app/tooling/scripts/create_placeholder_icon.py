#!/usr/bin/env python3
"""
Script tạo icon placeholder cho app CaoThuLive
Sử dụng tạm thời cho đến khi có icon chính thức
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os
    
    # Tạo icon 1024x1024
    size = 1024
    img = Image.new('RGB', (size, size), color='#FF6B35')  # Màu cam nổi bật
    draw = ImageDraw.Draw(img)
    
    # Vẽ gradient background (đơn giản)
    for i in range(size):
        color = int(255 * (1 - i/size))
        draw.line([(0, i), (size, i)], fill=(255, 107+color//5, 53+color//10))
    
    # Vẽ chữ "C" lớn ở giữa
    try:
        font = ImageFont.truetype("arial.ttf", 600)
    except:
        font = ImageFont.load_default()
    
    text = "C"
    # Lấy kích thước text
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Vẽ text ở giữa
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 50
    
    # Shadow
    draw.text((x+10, y+10), text, fill='#000000', font=font)
    # Main text
    draw.text((x, y), text, fill='#FFFFFF', font=font)
    
    # Vẽ text nhỏ phía dưới
    try:
        small_font = ImageFont.truetype("arial.ttf", 80)
    except:
        small_font = font
    
    small_text = "CaoThuLive"
    bbox2 = draw.textbbox((0, 0), small_text, font=small_font)
    small_width = bbox2[2] - bbox2[0]
    draw.text(((size - small_width)//2, y + text_height + 50), small_text, fill='#FFFFFF', font=small_font)
    
    # Lưu file
    output_path = os.path.join(os.path.dirname(__file__), 'app_icon.png')
    img.save(output_path, 'PNG', quality=100)
    print(f"✅ Icon placeholder đã được tạo: {output_path}")
    print("⚠️  Đây chỉ là icon tạm thời. Hãy thay thế bằng icon chính thức!")
    
except ImportError:
    print("❌ Cần cài đặt Pillow: pip install Pillow")
    print("Hoặc tạo icon thủ công với kích thước 1024x1024 và đặt tên 'app_icon.png'")

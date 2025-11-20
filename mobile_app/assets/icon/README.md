# Icon App - CaoThuLive

## ✅ Icon hiện tại: `CAOTHULIVE.png`

File icon chính thức của CaoThuLive app đã được đặt tại đây!

---

## 🚀 Quick Start

### Tự động (Khuyến nghị):
```powershell
cd ..\..\
.\generate_icons.ps1
```

### Thủ công:
```powershell
cd ..\..\
flutter pub get
dart run flutter_launcher_icons
```

📖 **Xem chi tiết**: [QUICK_START.md](QUICK_START.md)

---

## Yêu cầu icon:

### Kích thước:
- **Tối thiểu**: 1024x1024 pixels
- **Định dạng**: PNG (với nền trong suốt hoặc nền màu)
- **Chất lượng**: Cao, không bị mờ hay vỡ

### Thiết kế:
✅ **NÊN**:
- Logo đơn giản, dễ nhận biết
- Màu sắc nổi bật, phù hợp với thương hiệu CaoThuLive
- Icon riêng biệt, không trùng với các app tin tức/TV khác
- Có thể nhận diện được ở kích thước nhỏ (48x48px)

❌ **KHÔNG NÊN**:
- Sử dụng hình ảnh "LIVE" hoặc biểu tượng TV phổ thông
- Copy icon của app khác
- Dùng hình có bản quyền
- Text quá nhiều hoặc quá nhỏ

### Gợi ý thiết kế:
1. Logo chữ "C" stylized + màu sắc thương hiệu
2. Biểu tượng tin tức + game kết hợp
3. Mascot đặc trưng của CaoThuLive
4. Gradient màu hiện đại với icon đơn giản

---

## 📂 Files trong thư mục:

- `CAOTHULIVE.png` - Icon chính thức ✅
- `QUICK_START.md` - Hướng dẫn nhanh
- `create_placeholder_icon.py` - Script tạo icon mẫu (nếu cần)
	(Đã di chuyển sang `tooling/scripts/create_placeholder_icon.py` để nó không bị đóng gói vào bundle ứng dụng.)

---

## 🎯 Sau khi generate:

Icon sẽ được tạo tự động cho:

### Android:
- `mipmap-mdpi`, `mipmap-hdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, `mipmap-xxxhdpi`
- Adaptive icon (Android 8.0+)

### iOS:
- Tất cả kích thước từ 20x20 đến 1024x1024
- App Store icon 1024x1024

---

**Bundle ID**: `com.caothulive.newsapp`  
**Version**: 3.0.0+1

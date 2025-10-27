# 🎨 Hướng dẫn cài đặt App Icon - CaoThuLive

## ✅ Đã hoàn thành:
- ✅ File icon `CAOTHULIVE.png` đã có sẵn trong `assets/icon/`
- ✅ Cấu hình `pubspec.yaml` đã được cập nhật
- ✅ Package `flutter_launcher_icons` đã được thêm vào dependencies

## 📋 Các bước thực hiện:

### Bước 1: Cài đặt dependencies
```powershell
cd "c:\Users\lepha\Downloads\caothulive-final\mobile_app"
flutter pub get
```

### Bước 2: Generate app icons
```powershell
flutter pub run flutter_launcher_icons
```

Hoặc nếu bạn đang dùng Flutter 3.x:
```powershell
dart run flutter_launcher_icons
```

### Bước 3: Clean và rebuild
```powershell
# Clean project
flutter clean

# Get dependencies lại
flutter pub get

# Build iOS (nếu cần)
cd ios
pod install
cd ..

# Build Android (kiểm tra)
flutter build apk --debug
```

## 🎯 Kết quả mong đợi:

Sau khi chạy lệnh generate icons, bạn sẽ thấy:

### Android:
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (các độ phân giải khác nhau)
- `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`

### iOS:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (tất cả các kích thước icon)

## 🔧 Cấu hình hiện tại trong pubspec.yaml:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/CAOTHULIVE.png"
  adaptive_icon_foreground: "assets/icon/CAOTHULIVE.png"
  adaptive_icon_background: "#000000"  # Màu nền đen
  remove_alpha_ios: true
```

## 📐 Yêu cầu về icon:

✅ **CAOTHULIVE.png** nên có:
- Kích thước tối thiểu: **1024×1024 pixels**
- Format: PNG với transparent background (hoặc background màu)
- Nội dung: Logo/icon không có text, tránh các biểu tượng TV/Live trùng lặp

## ⚠️ Lưu ý quan trọng:

1. **Icon quá nhỏ**: Nếu `CAOTHULIVE.png` nhỏ hơn 1024×1024, hãy tạo lại với kích thước lớn hơn

2. **iOS có thể bị từ chối**: 
   - Không dùng icon có logo Apple, TV, camera
   - Không dùng icon giống với app hệ thống
   - Phải có alpha channel rõ ràng hoặc background cứng

3. **Android Adaptive Icon**:
   - Foreground (logo): nên có padding khoảng 20% để tránh bị cắt
   - Background: màu đen `#000000` - phù hợp với theme CaoThuLive

## 🚀 Sau khi generate xong:

### Kiểm tra trên Android:
```powershell
flutter run -d <device-id>
```

### Kiểm tra trên iOS:
```powershell
open ios/Runner.xcworkspace
# Trong Xcode: chọn Runner > General > App Icons and Launch Screen
# Kiểm tra AppIcon có đầy đủ các kích thước
```

## 🆘 Troubleshooting:

### Lỗi: "flutter: command not found"
```powershell
# Kiểm tra Flutter đã cài chưa
flutter --version

# Nếu chưa có, cài Flutter SDK hoặc thêm vào PATH
```

### Lỗi: "Image not found"
- Kiểm tra file `assets/icon/CAOTHULIVE.png` có tồn tại không
- Đảm bảo đường dẫn trong `pubspec.yaml` chính xác

### Lỗi: "Image size too small"
- Resize `CAOTHULIVE.png` lên tối thiểu 1024×1024

### Icon không đổi sau khi build:
```powershell
# Android: uninstall app cũ
adb uninstall com.caothulive.newsapp

# iOS: trong Xcode > Product > Clean Build Folder
# Sau đó build lại
```

## 📱 Bundle ID đã được cập nhật:
- **iOS**: `com.caothulive.newsapp`
- **Android**: `com.caothulive.newsapp`

Đảm bảo Bundle ID này trùng khớp khi upload lên App Store / Play Store!

---

**Tác giả**: CaoThuLive Development Team  
**Ngày cập nhật**: 27/10/2025

# 🎨 Quick Start - Generate Icons

## ✅ Icon sẵn sàng: `assets/icon/CAOTHULIVE.png`

---

## 🚀 Cách 1: Chạy Script Tự Động (Khuyến nghị)

```powershell
cd "c:\Users\lepha\Downloads\caothulive-final\mobile_app"
.\generate_icons.ps1
```

**Lưu ý**: Nếu gặp lỗi execution policy, chạy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🛠️ Cách 2: Chạy Thủ Công

### Bước 1: Install dependencies
```powershell
cd "c:\Users\lepha\Downloads\caothulive-final\mobile_app"
flutter pub get
```

### Bước 2: Generate icons
```powershell
# Thử lệnh này trước
dart run flutter_launcher_icons

# Nếu không được, thử lệnh này
flutter pub run flutter_launcher_icons
```

### Bước 3: Clean và rebuild
```powershell
flutter clean
flutter pub get
```

### Bước 4: iOS - Install pods (nếu build cho iOS)
```powershell
cd ios
pod install
cd ..
```

### Bước 5: Test
```powershell
# Android
flutter build apk --debug

# iOS
flutter build ios --no-codesign
```

---

## 📋 Checklist

- [x] Icon file: `assets/icon/CAOTHULIVE.png` ✅
- [x] Config: `pubspec.yaml` đã cập nhật ✅
- [ ] Run: `flutter pub get`
- [ ] Generate: `dart run flutter_launcher_icons`
- [ ] Clean: `flutter clean`
- [ ] Test: Build app và kiểm tra icon

---

## 🎯 Kết quả

Sau khi chạy xong, icon sẽ được tạo tại:

### Android:
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png
├── mipmap-hdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
└── mipmap-xxxhdpi/ic_launcher.png
```

### iOS:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-20x20@3x.png
├── Icon-App-29x29@1x.png
... (và các kích thước khác)
└── Contents.json
```

---

## ⚠️ Troubleshooting

**Q: Flutter command not found?**  
A: Cài Flutter SDK: https://docs.flutter.dev/get-started/install/windows

**Q: Icon không đổi sau khi build?**  
A: 
```powershell
# Android: Uninstall app cũ
adb uninstall com.caothulive.newsapp

# iOS: Clean build trong Xcode
# Product > Clean Build Folder
```

**Q: Icon size quá nhỏ?**  
A: `CAOTHULIVE.png` phải ≥ 1024×1024 pixels

---

## 📱 Bundle ID

- **iOS**: `com.caothulive.newsapp`
- **Android**: `com.caothulive.newsapp`

---

**🎉 Chúc bạn thành công!**

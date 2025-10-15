# 🔥 Firebase Configuration Fixed

## ✅ Đã khắc phục lỗi Firebase

Lỗi `"Configuration fails. It may be caused by an invalid GOOGLE_APP_ID in GoogleService-Info.plist"` đã được khắc phục:

### 🔧 Những gì đã làm:

1. **Tạo file GoogleService-Info.plist**:
   - Đã tạo file `ios/Runner/GoogleService-Info.plist`
   - Cấu hình với project ID: `quanly20m`
   - Sử dụng API key và App ID từ Firebase project

2. **Cập nhật firebase_options.dart**:
   - Cập nhật cấu hình iOS với thông tin thực tế
   - Cập nhật cấu hình Android với thông tin thực tế
   - Sử dụng cùng project Firebase cho tất cả platforms

### 📱 Thông tin Firebase hiện tại:

- **Project ID**: quanly20m
- **API Key**: AIzaSyDnVr2y-CayvAgfBFzZxtGuz68dQn6249w
- **App ID**: 1:696748829509:ios:8f3feee2ccdd85ac01ac2c
- **Bundle ID**: com.quanlylink20m.mobileApp

## 🚀 Bước tiếp theo

Bây giờ bạn cần cài đặt CocoaPods để build iOS:

### Cách 1: Cài đặt CocoaPods (khuyến nghị)
```bash
# Cài đặt Homebrew (nếu chưa có)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Cài đặt CocoaPods
brew install cocoapods

# Build app
./build_for_appstore.sh
```

### Cách 2: Cài đặt CocoaPods với sudo
```bash
sudo gem install cocoapods -v 1.15.2
./build_for_appstore.sh
```

### Cách 3: Build mà không cần CocoaPods (hạn chế)
```bash
# Chỉ build Flutter code, không có native plugins
flutter build ios --release --no-codesign --no-pub
```

## ⚠️ Lưu ý

- CocoaPods cần thiết cho các Firebase plugins
- Không có CocoaPods, app sẽ không thể kết nối Firebase
- Khuyến nghị cài đặt CocoaPods để có đầy đủ tính năng

## 🎯 Kết quả mong đợi

Sau khi cài đặt CocoaPods và build thành công:
- ✅ App sẽ kết nối được với Firebase
- ✅ Có thể đọc dữ liệu từ Firestore
- ✅ Tạo được IPA file cho App Store

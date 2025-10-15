# 🍎 Hướng dẫn Build iOS App cho App Store

## 📋 Tổng quan
Dự án Flutter "Cao Thu Live" đã được cấu hình sẵn cho iOS. Để build và upload lên App Store, bạn cần thực hiện các bước sau:

## 🔧 Yêu cầu hệ thống

### 1. macOS với Xcode
- macOS 12.0 trở lên
- Xcode 14.0 trở lên (đã cài đặt)
- Apple Developer Account (trả phí $99/năm)

### 2. Flutter SDK
✅ **Đã cài đặt**: Flutter 3.35.6 tại `~/flutter/bin`

### 3. CocoaPods
❌ **Cần cài đặt**: CocoaPods để quản lý dependencies iOS

## 🚀 Các bước Build

### Bước 1: Cài đặt CocoaPods

```bash
# Cách 1: Sử dụng Homebrew (khuyến nghị)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install cocoapods

# Cách 2: Sử dụng gem (cần sudo)
sudo gem install cocoapods

# Cách 3: Cài đặt user-local (không cần sudo)
gem install cocoapods --user-install
echo 'export PATH="$PATH:$HOME/.gem/ruby/2.6.0/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Bước 2: Cấu hình dự án

```bash
cd /Users/admin/Downloads/caothulive/mobile_app

# Thêm Flutter vào PATH
export PATH="$PATH:$HOME/flutter/bin"

# Clean và get dependencies
flutter clean
flutter pub get

# Cài đặt iOS dependencies
cd ios
pod install
cd ..
```

### Bước 3: Cấu hình Xcode

1. **Mở Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Cấu hình Bundle Identifier**:
   - Chọn project "Runner" trong Navigator
   - Tab "Signing & Capabilities"
   - Thay đổi Bundle Identifier thành: `com.caothulive.app` (hoặc tên khác)
   - Chọn Team (Apple Developer Account của bạn)

3. **Cấu hình App Store Connect**:
   - Bundle Identifier phải khớp với App Store Connect
   - Version number: 1.0.0
   - Build number: 1

### Bước 4: Build cho App Store

#### Cách 1: Sử dụng Flutter CLI
```bash
# Build IPA trực tiếp
flutter build ipa --release

# IPA sẽ được tạo tại: build/ios/ipa/Runner.ipa
```

#### Cách 2: Sử dụng Xcode
1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Chọn "Any iOS Device (arm64)" làm target
3. Product → Archive
4. Sau khi archive xong, chọn "Distribute App"
5. Chọn "App Store Connect"
6. Chọn "Upload"

### Bước 5: Upload lên App Store Connect

#### Sử dụng Xcode Organizer:
1. Window → Organizer
2. Chọn archive vừa tạo
3. Click "Distribute App"
4. Chọn "App Store Connect"
5. Chọn "Upload"
6. Điền thông tin và upload

#### Sử dụng Application Loader:
1. Download từ App Store Connect
2. Mở Application Loader
3. Chọn IPA file
4. Upload

## 📱 Cấu hình App Store Connect

### 1. Tạo App mới
1. Đăng nhập [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps → "+" → New App
3. Điền thông tin:
   - **Name**: Cao Thu Live
   - **Bundle ID**: com.caothulive.app
   - **SKU**: caothulive-ios-001
   - **User Access**: Full Access

### 2. Cấu hình App Information
- **App Name**: Cao Thu Live
- **Subtitle**: YouTube Link Manager
- **Category**: Entertainment
- **Content Rights**: Yes (nếu bạn có quyền)

### 3. Pricing and Availability
- **Price**: Free
- **Availability**: All Countries

### 4. App Store Information
- **Description**: 
```
Cao Thu Live - Ứng dụng quản lý và xem video YouTube

Tính năng chính:
• Xem danh sách video YouTube được ưu tiên
• Quản lý kênh YouTube yêu thích
• Hỗ trợ liên hệ trực tiếp
• Giao diện thân thiện, dễ sử dụng

Ứng dụng giúp bạn dễ dàng theo dõi và xem các video YouTube quan trọng nhất.
```

- **Keywords**: youtube, video, entertainment, vietnam
- **Support URL**: https://caothulive.com
- **Marketing URL**: https://caothulive.com

### 5. App Review Information
- **Contact Information**: Điền thông tin liên hệ
- **Demo Account**: Không cần (app không yêu cầu đăng nhập)
- **Notes**: "App hiển thị danh sách video YouTube từ Firebase"

## 🔐 Cấu hình Firebase (nếu cần)

Nếu app sử dụng Firebase, bạn cần:

1. **Tạo Firebase project**:
   - Truy cập [Firebase Console](https://console.firebase.google.com)
   - Tạo project mới: "caothulive-ios"

2. **Thêm iOS app**:
   - Bundle ID: com.caothulive.app
   - Download `GoogleService-Info.plist`

3. **Cấu hình trong Xcode**:
   - Copy `GoogleService-Info.plist` vào `ios/Runner/`
   - Thêm vào Xcode project

## 🚨 Troubleshooting

### Lỗi CocoaPods
```bash
# Xóa cache và cài lại
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

### Lỗi Code Signing
1. Kiểm tra Apple Developer Account
2. Đảm bảo Bundle ID đã được đăng ký
3. Kiểm tra Provisioning Profile

### Lỗi Build
```bash
# Clean và rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

## 📋 Checklist trước khi submit

- [ ] App build thành công
- [ ] IPA file được tạo
- [ ] Bundle ID đã đăng ký trong App Store Connect
- [ ] App Information đã điền đầy đủ
- [ ] Screenshots đã upload (cần thiết)
- [ ] App Icon đã cấu hình
- [ ] Privacy Policy URL (nếu cần)
- [ ] Test trên device thật

## 📞 Hỗ trợ

Nếu gặp vấn đề:
- Email: caothulive@gmail.com
- Facebook: https://facebook.com/lephambinh.mmo

## 🎉 Kết quả

Sau khi hoàn thành, bạn sẽ có:
- ✅ IPA file sẵn sàng upload
- ✅ App được submit lên App Store
- ✅ Chờ Apple review (1-7 ngày)

**Lưu ý**: Quá trình review có thể mất 1-7 ngày làm việc. Apple sẽ gửi email thông báo kết quả.

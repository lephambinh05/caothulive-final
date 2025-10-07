# 📱 Mobile App Build Guide

## 🎯 Tổng quan
Mobile app được xây dựng bằng Flutter, có giao diện tương tự như web với 3 trang chính:
- **Videos**: Danh sách video YouTube với filter theo priority
- **Channels**: Danh sách kênh YouTube
- **Support**: Thông tin liên hệ hỗ trợ

## 🛠️ Cấu trúc dự án

```
mobile_app/
├── lib/
│   ├── config.dart              # Cấu hình URLs và constants
│   ├── main.dart                # Entry point
│   ├── models/
│   │   ├── youtube_link.dart    # Model cho YouTube links
│   │   └── youtube_channel.dart # Model cho YouTube channels
│   ├── screens/
│   │   ├── home_screen.dart     # Main screen với bottom navigation
│   │   ├── channels_screen.dart # Trang danh sách channels
│   │   └── support_screen.dart  # Trang hỗ trợ
│   └── widgets/
│       └── link_card.dart       # Widget hiển thị video card
├── android/                     # Android configuration
├── ios/                         # iOS configuration
└── pubspec.yaml                 # Dependencies
```

## 📦 Dependencies chính

- `firebase_core`: Firebase integration
- `cloud_firestore`: Firestore database
- `url_launcher`: Mở URLs và external apps
- `cached_network_image`: Cache và hiển thị images
- `youtube_explode_dart`: Lấy metadata YouTube videos

## 🚀 Build Instructions

### Android APK

```bash
# 1. Clean project
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build APK
flutter build apk --release

# 4. APK sẽ được tạo tại:
# build/app/outputs/flutter-apk/app-release.apk
```

### iOS IPA (chỉ trên macOS)

```bash
# 1. Chạy script build iOS
chmod +x build_ios.sh
./build_ios.sh

# 2. Hoặc build thủ công:
flutter build ios --release
```

## 🔧 Configuration

### URLs và API endpoints
Tất cả được quản lý trong `lib/config.dart`:

```dart
const String API_BASE_URL = 'https://api.caothulive.com/api';
const String WEBSITE_DOMAIN = 'https://caothulive.com';
```

### Firebase Configuration
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config

## 📱 Features

### 1. Videos Tab
- Hiển thị danh sách video YouTube từ Firestore
- Filter theo priority (1-5)
- Pull-to-refresh
- Tap để mở video trong YouTube app
- Hiển thị thumbnail, title, description, duration

### 2. Channels Tab
- Hiển thị danh sách kênh YouTube
- Hiển thị avatar, subscriber count, video count
- Tap để mở kênh trong YouTube app

### 3. Support Tab
- Thông tin liên hệ từ Firestore settings
- Facebook, Email, SMS, Telegram, Zalo
- Tap để mở app tương ứng

## 🎨 UI/UX Features

- **Material Design 3**: Modern UI components
- **Bottom Navigation**: Dễ dàng chuyển đổi giữa các tab
- **Priority Colors**: Màu sắc phân biệt mức độ ưu tiên
- **Responsive Design**: Tối ưu cho nhiều kích thước màn hình
- **Error Handling**: Xử lý lỗi network và hiển thị thông báo
- **Loading States**: Hiển thị loading khi tải dữ liệu

## 🔄 Data Flow

1. **Firebase Firestore**: Lưu trữ dữ liệu
2. **StreamBuilder**: Real-time updates
3. **Cached Images**: Tối ưu hiệu suất
4. **Error Recovery**: Retry mechanisms

## 📋 Testing

```bash
# Run tests
flutter test

# Run on device/emulator
flutter run

# Debug mode
flutter run --debug
```

## 🚀 Deployment

### Android
1. Build APK: `flutter build apk --release`
2. Upload lên Google Play Store
3. Hoặc distribute APK trực tiếp

### iOS
1. Build trên macOS: `flutter build ios`
2. Archive trong Xcode
3. Upload lên App Store Connect

## 🔧 Troubleshooting

### Common Issues

1. **Firebase connection failed**
   - Kiểm tra google-services.json
   - Kiểm tra internet connection

2. **Build failed**
   - Chạy `flutter clean`
   - Chạy `flutter pub get`
   - Kiểm tra Flutter version

3. **Images not loading**
   - Kiểm tra internet connection
   - Kiểm tra URL format

## 📞 Support

Nếu có vấn đề, liên hệ:
- Email: caothulive@gmail.com
- Facebook: https://facebook.com/lephambinh.mmo

# 📱 VideoHub Pro - Smart YouTube Manager

**VideoHub Pro** là ứng dụng quản lý video YouTube thông minh với giao diện hiện đại và tính năng mạnh mẽ.

## ✨ **Tính năng chính**

### 🎯 **Quản lý Video**
- **3 tabs chính**: Trực tiếp, Kênh, Yêu thích
- **Tìm kiếm thông minh** với bộ lọc theo mức độ ưu tiên
- **Favorites system** lưu trữ video và kênh yêu thích
- **Dark mode** với theme switching

### 🎨 **Giao diện hiện đại**
- **Material Design 3** với animations mượt mà
- **Skeleton loading** cho trải nghiệm tốt hơn
- **Responsive design** tối ưu cho mọi kích thước màn hình
- **Haptic feedback** cho tương tác tự nhiên

### 🔧 **Tính năng kỹ thuật**
- **Firebase integration** cho dữ liệu real-time
- **Cached images** với shimmer loading
- **YouTube API integration** cho metadata
- **Shared preferences** cho cài đặt local

## 🚀 **Cài đặt và Build**

### **Yêu cầu hệ thống**
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK >= 21
- iOS >= 12.0

### **Build APK**
```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

### **Cài đặt lên MuMu Emulator**
```bash
# Kiểm tra devices
adb devices

# Cài đặt APK
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## 📱 **Cấu trúc Project**

```
lib/
├── main.dart                 # Entry point
├── config.dart              # App configuration
├── firebase_options.dart    # Firebase setup
├── models/                  # Data models
├── screens/                 # App screens
├── widgets/                 # Reusable widgets
├── providers/               # State management
└── theme/                   # App theming
```

## 🔥 **Firebase Setup**

1. **Tạo Firebase project** tại [console.firebase.google.com](https://console.firebase.google.com)
2. **Thêm Android app** với package name: `com.quanlylink20m.app`
3. **Download** `google-services.json` và đặt vào `android/app/`
4. **Enable Firestore** và tạo collections cần thiết

## 🎯 **Tính năng nổi bật**

### **Onboarding Experience**
- 3-step onboarding với animations
- Hướng dẫn sử dụng app
- Theme selection

### **Smart Search & Filter**
- Tìm kiếm theo tên video/kênh
- Lọc theo mức độ ưu tiên (1-5)
- Real-time search results

### **Favorites Management**
- Lưu video yêu thích
- Lưu kênh yêu thích
- Sync với Firebase

## 🛠 **Development**

### **Chạy trên emulator**
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### **Hot reload**
```bash
# Trong khi app đang chạy
r  # Hot reload
R  # Hot restart
```

## 📊 **Performance**

- **App size**: ~97MB (debug APK)
- **Startup time**: <3 giây
- **Memory usage**: Optimized với cached images
- **Battery**: Efficient với lazy loading

## 🔧 **Troubleshooting**

### **Build errors**
- Kiểm tra Kotlin version trong `android/build.gradle`
- Clean project với `flutter clean`
- Update dependencies với `flutter pub upgrade`

### **Firebase errors**
- Kiểm tra `google-services.json`
- Verify Firebase project settings
- Check internet connection

## 📞 **Support**

- **GitHub Issues**: Tạo issue cho bug reports
- **Documentation**: Xem các file `.md` trong project
- **Firebase Console**: Quản lý dữ liệu và settings

---

**Happy Coding! 🎉**

# 📁 Cấu trúc dự án YouTube Link Manager

## 🏗️ Tổng quan
Dự án được chia thành 2 phần chính:
- **Admin Web**: Giao diện quản trị bằng Flutter Web
- **Mobile App**: Ứng dụng di động bằng Flutter

## 📂 Cấu trúc thư mục

```
quanLyLink/
├── 📁 admin_web/                    # Admin Web Application
│   ├── 📁 lib/
│   │   ├── 📁 models/
│   │   │   └── 📄 youtube_link.dart     # Model cho YouTube link
│   │   ├── 📁 screens/
│   │   │   ├── 📄 login_screen.dart     # Màn hình đăng nhập
│   │   │   └── 📄 admin_dashboard.dart  # Dashboard chính
│   │   ├── 📁 widgets/
│   │   │   ├── 📄 link_form_dialog.dart # Dialog thêm/sửa link
│   │   │   └── 📄 confirm_dialog.dart   # Dialog xác nhận
│   │   ├── 📄 main.dart                 # Entry point
│   │   └── 📄 firebase_options.dart     # Cấu hình Firebase
│   ├── 📁 web/
│   │   ├── 📄 index.html                # HTML template
│   │   └── 📄 manifest.json             # Web app manifest
│   └── 📄 pubspec.yaml                 # Dependencies
│
├── 📁 mobile_app/                    # Mobile Application
│   ├── 📁 lib/
│   │   ├── 📁 models/
│   │   │   └── 📄 youtube_link.dart     # Model cho YouTube link
│   │   ├── 📁 screens/
│   │   │   └── 📄 home_screen.dart      # Màn hình chính
│   │   ├── 📁 widgets/
│   │   │   └── 📄 link_card.dart        # Card hiển thị link
│   │   ├── 📄 main.dart                 # Entry point
│   │   └── 📄 firebase_options.dart     # Cấu hình Firebase
│   ├── 📁 android/
│   │   ├── 📁 app/
│   │   │   ├── 📄 build.gradle          # App-level build config
│   │   │   └── 📁 src/main/
│   │   │       └── 📄 AndroidManifest.xml
│   │   └── 📄 build.gradle              # Project-level build config
│   ├── 📁 ios/
│   │   └── 📄 Podfile                   # iOS dependencies
│   └── 📄 pubspec.yaml                 # Dependencies
│
├── 📁 firebase_config/                # Cấu hình Firebase
│   └── 📄 README.md                    # Hướng dẫn cấu hình
│
├── 📄 README.md                        # Tổng quan dự án
├── 📄 SETUP.md                         # Hướng dẫn cài đặt
├── 📄 PROJECT_STRUCTURE.md             # File này
└── 📄 .gitignore                       # Git ignore rules
```

## 🔧 Cấu hình Firebase

### Admin Web
- **Authentication**: Email/Password
- **Database**: Firestore (collection: `youtube_links`)
- **Security**: Chỉ admin đã đăng nhập mới được CRUD

### Mobile App
- **Database**: Firestore (chỉ đọc)
- **Features**: Hiển thị danh sách, mở YouTube links
- **Security**: Không cần đăng nhập, chỉ đọc dữ liệu

## 📱 Tính năng chính

### Admin Web
- ✅ Đăng nhập Firebase Authentication
- ✅ CRUD quản lý link YouTube
- ✅ Bảng hiển thị dữ liệu
- ✅ Form validation
- ✅ Real-time updates từ Firestore
- ✅ Responsive design

### Mobile App
- ✅ Hiển thị danh sách link YouTube
- ✅ Thumbnail từ YouTube API
- ✅ Mở YouTube app/trình duyệt
- ✅ Pull-to-refresh
- ✅ Error handling
- ✅ Beautiful UI với Material Design

## 🚀 Cách chạy

### 1. Cài đặt dependencies
```bash
# Admin Web
cd admin_web
flutter pub get

# Mobile App
cd mobile_app
flutter pub get
cd ios && pod install && cd ..
```

### 2. Cấu hình Firebase
- Tạo dự án Firebase
- Cập nhật `firebase_options.dart`
- Bật Authentication và Firestore

### 3. Chạy ứng dụng
```bash
# Admin Web
cd admin_web
flutter run -d chrome

# Mobile App
cd mobile_app
flutter run
```

## 🔒 Bảo mật

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /youtube_links/{document} {
      allow read: if true;           // Mobile app
      allow write: if request.auth != null;  // Admin web
    }
  }
}
```

### Authentication
- Admin đăng nhập bằng email/password
- Tài khoản được tạo trong Firebase Console

## 📊 Database Schema

### Collection: `youtube_links`
```json
{
  "id": "auto-generated",
  "title": "String - Tiêu đề video",
  "url": "String - Link YouTube",
  "created_at": "Timestamp - Thời gian tạo"
}
```

## 🎨 UI/UX Features

### Admin Web
- Material Design 3
- Gradient background
- Responsive table
- Form dialogs
- Loading states
- Error handling

### Mobile App
- Card-based design
- YouTube thumbnails
- Smooth animations
- Pull-to-refresh
- Error states
- Loading indicators

## 🔄 Real-time Features

- **Stream**: Firestore real-time updates
- **Auto-refresh**: Dữ liệu tự động cập nhật
- **Offline support**: Firestore offline persistence
- **Sync**: Tự động đồng bộ khi online

## 📈 Performance

- **Lazy loading**: Chỉ load dữ liệu cần thiết
- **Image caching**: Cached network images
- **Efficient queries**: Firestore indexing
- **Minimal rebuilds**: Optimized widget rebuilds

## 🚧 Development Notes

### Dependencies
- Flutter 3.x+
- Firebase Core, Auth, Firestore
- URL Launcher (mobile)
- Cached Network Image (mobile)

### Platform Support
- **Web**: Chrome, Firefox, Safari, Edge
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+

### Testing
- Unit tests cho models
- Widget tests cho UI components
- Integration tests cho Firebase operations

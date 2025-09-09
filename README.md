# 🎥 YouTube Link Manager

Ứng dụng quản lý và chia sẻ link YouTube với hệ thống mức độ ưu tiên thông minh.

## ✨ Tính năng mới: Mức độ ưu tiên

### 🎯 Priority System
- **5 mức độ ưu tiên**: Từ rất cao (1) đến rất thấp (5)
- **Sắp xếp thông minh**: Video hiển thị theo priority trước, sau đó theo ngày tạo
- **Bộ lọc linh hoạt**: Mobile app có thể lọc theo từng mức độ ưu tiên
- **Visual tags**: Hiển thị màu sắc và số priority trên mỗi video

### 🔧 Admin Features
- Đặt mức độ ưu tiên khi thêm/sửa link
- Giao diện trực quan với 5 nút priority
- Sắp xếp và quản lý theo priority
- Hiển thị priority trong bảng admin

### 📱 Mobile Features
- Bộ lọc priority ở đầu màn hình
- Tag priority màu sắc trên mỗi video
- Sắp xếp tự động theo mức độ ưu tiên
- Giao diện thân thiện với người dùng

## 🏗️ Kiến trúc hệ thống

```
📱 Mobile App (Flutter)
    ↓
🌐 Admin Web (Flutter Web)
    ↓
🔥 Firebase (Firestore + Auth)
```

## 📁 Cấu trúc dự án

```
quanLyLink/
├── 📱 mobile_app/          # Ứng dụng mobile Flutter
├── 🌐 admin_web/           # Web admin Flutter
├── 🔥 firebase_config/     # Cấu hình Firebase
├── 📚 docs/               # Tài liệu
└── 📋 README files        # Hướng dẫn
```

## 🚀 Cài đặt nhanh

### 1. Cài đặt Firebase
```bash
# Xem firebase_config/README.md để cài đặt Firebase
```

### 2. Tạo Composite Index (Bắt buộc)
```bash
# Vào Firebase Console > Firestore > Indexes
# Tạo index: priority (Ascending) + created_at (Descending)
```

### 3. Chạy ứng dụng
```bash
# Admin Web
cd admin_web && flutter run -d chrome

# Mobile App  
cd mobile_app && flutter run
```

## 📊 Mức độ ưu tiên

| Level | Tên | Màu sắc | Mô tả |
|-------|-----|---------|-------|
| 🟢 1 | Rất cao | Đỏ | Video quan trọng nhất |
| 🟠 2 | Cao | Cam | Video quan trọng |
| 🔵 3 | Trung bình | Xanh | Video bình thường |
| ⚫ 4 | Thấp | Xám | Video ít quan trọng |
| ⚪ 5 | Rất thấp | Xám nhạt | Video ít quan trọng nhất |

## 🔧 Tính năng kỹ thuật

- **Flutter 3.0+** với null safety
- **Firebase Firestore** cho database
- **Firebase Auth** cho authentication
- **Responsive design** cho web và mobile
- **Real-time updates** với Firestore streams
- **Priority-based sorting** với composite indexes

## 📱 Screenshots

### Admin Web
- Dashboard với bảng quản lý priority
- Form thêm/sửa với selector priority
- Sắp xếp theo priority và ngày tạo

### Mobile App
- Home screen với bộ lọc priority
- Link cards hiển thị priority tags
- Giao diện thân thiện người dùng

## 🆘 Hỗ trợ

- 📖 **Hướng dẫn chi tiết**: Xem `SETUP.md`
- 🔥 **Firebase config**: Xem `firebase_config/README.md`
- 🐛 **Xử lý lỗi**: Xem phần Troubleshooting trong `SETUP.md`

## 🤝 Đóng góp

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Dự án này được phân phối dưới MIT License. Xem file `LICENSE` để biết thêm chi tiết.

## 🙏 Cảm ơn

- Flutter team cho framework tuyệt vời
- Firebase team cho backend services
- Cộng đồng Flutter Việt Nam

---

**Lưu ý**: Đừng quên tạo composite index trong Firestore để tính năng priority hoạt động!

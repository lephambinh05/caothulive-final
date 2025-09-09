# Hướng dẫn cài đặt và cập nhật

## 🔥 Cài đặt Firebase

Xem file `firebase_config/README.md` để biết chi tiết cài đặt Firebase.

## 🆕 Cập nhật mới: Mức độ ưu tiên

### Tính năng mới:
- ✅ Admin có thể đặt mức độ ưu tiên cho video (1-5)
- ✅ Video hiển thị theo thứ tự ưu tiên
- ✅ Mobile app có bộ lọc theo mức độ ưu tiên
- ✅ Hiển thị tag priority trên mobile app

### Cài đặt cần thiết:

#### 1. Tạo Composite Index trong Firestore

**Bắt buộc:** Để hỗ trợ sắp xếp theo priority và created_at, bạn cần tạo composite index:

1. Vào Firebase Console > Firestore Database
2. Chọn tab "Indexes"
3. Click "Create Index"
4. Collection ID: `youtube_links`
5. Fields:
   - Field path: `priority`, Order: `Ascending`
   - Field path: `created_at`, Order: `Descending`
6. Click "Create"

**Lưu ý:** Index có thể mất vài phút để build. Không thể sử dụng app cho đến khi index hoàn thành.

#### 2. Cập nhật dữ liệu hiện có

Nếu bạn đã có dữ liệu cũ, cần cập nhật để thêm trường `priority`:

```javascript
// Trong Firebase Console > Firestore Database
// Chọn từng document và thêm field:
priority: 3
```

Hoặc sử dụng script batch update:

```javascript
// Trong Firebase Console > Functions (nếu có)
const batch = db.batch();
const linksRef = db.collection('youtube_links');
const snapshot = await linksRef.get();

snapshot.docs.forEach((doc) => {
  batch.update(doc.ref, { priority: 3 });
});

await batch.commit();
```

## 🚀 Chạy ứng dụng

### Admin Web:
```bash
cd admin_web
flutter pub get
flutter run -d chrome
```

### Mobile App:
```bash
cd mobile_app
flutter pub get
flutter run
```

## 📱 Sử dụng tính năng mới

### Admin:
1. Đăng nhập vào admin web
2. Thêm/sửa link với mức độ ưu tiên (1-5)
3. Video sẽ tự động sắp xếp theo priority

### Mobile App:
1. Sử dụng bộ lọc priority ở đầu màn hình
2. Chọn mức độ ưu tiên cụ thể hoặc "Tất cả"
3. Video hiển thị tag priority màu sắc

## 🔧 Xử lý lỗi

### Lỗi "The query requires an index"
- Đảm bảo đã tạo composite index như hướng dẫn trên
- Đợi index build hoàn thành (có thể mất vài phút)

### Lỗi "priority field not found"
- Cập nhật dữ liệu cũ để thêm trường `priority`
- Mặc định priority = 3 cho dữ liệu cũ

## 📊 Mức độ ưu tiên

| Level | Tên | Màu sắc | Mô tả |
|-------|-----|---------|-------|
| 1 | Rất cao | Đỏ | Video quan trọng nhất |
| 2 | Cao | Cam | Video quan trọng |
| 3 | Trung bình | Xanh | Video bình thường (mặc định) |
| 4 | Thấp | Xám | Video ít quan trọng |
| 5 | Rất thấp | Xám nhạt | Video ít quan trọng nhất |

## 🔄 Cập nhật tương lai

- [ ] Thêm thống kê priority
- [ ] Export/import với priority
- [ ] Bulk update priority
- [ ] Priority templates

# Firebase Configuration

## Cấu hình Firestore

### Composite Indexes

Để hỗ trợ sắp xếp theo priority và created_at, bạn cần tạo composite index sau:

**Collection:** `youtube_links`
**Fields:**
- `priority` (Ascending)
- `created_at` (Descending)

### Cách tạo index:

1. Vào Firebase Console > Firestore Database
2. Chọn tab "Indexes"
3. Click "Create Index"
4. Collection ID: `youtube_links`
5. Fields:
   - Field path: `priority`, Order: `Ascending`
   - Field path: `created_at`, Order: `Descending`
6. Click "Create"

### Cấu trúc dữ liệu

```json
{
  "title": "Tiêu đề video",
  "url": "https://www.youtube.com/watch?v=...",
  "created_at": "2024-01-01T00:00:00Z",
  "priority": 1
}
```

**Priority levels:**
- 1: Rất cao (màu đỏ)
- 2: Cao (màu cam)
- 3: Trung bình (màu xanh)
- 4: Thấp (màu xám)
- 5: Rất thấp (màu xám nhạt)

## Lưu ý

- Mặc định priority = 3 (trung bình)
- Video sẽ được sắp xếp theo priority trước, sau đó theo ngày tạo
- Admin có thể thay đổi priority khi thêm/sửa link
- Mobile app có bộ lọc theo priority

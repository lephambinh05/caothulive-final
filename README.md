# YouTube Link Manager - React + Node.js

Ứng dụng quản lý link YouTube được xây dựng với React và Node.js, giữ nguyên giao diện và tính năng từ phiên bản HTML gốc.

## 🚀 Tính năng

### Client (Trang chính)
- **Giao diện hiện đại**: Dark theme với gradient background
- **Lọc theo trạng thái**: Đang phát trực tiếp, Sắp phát, Đã kết thúc, Tạm dừng, Hủy bỏ
- **Hero section**: Hiển thị video nổi bật với thumbnail và thông tin
- **Responsive**: Tương thích mobile và desktop
- **Auto-fetch**: Tự động lấy thông tin video từ YouTube

### Admin Panel
- **Dashboard**: Thống kê tổng quan với charts và metrics
- **Thêm kênh YouTube**: Form thêm kênh với auto-fetch avatar và thông tin
- **Quản lý links**: CRUD operations cho YouTube links
- **Sidebar navigation**: Navigation responsive với Material Icons
- **Real-time updates**: Cập nhật dữ liệu real-time

## 🛠️ Công nghệ sử dụng

### Frontend (React)
- **React 18** với TypeScript
- **React Router** cho navigation
- **Material Icons** cho UI icons
- **CSS3** với custom properties
- **Axios** cho API calls

### Backend (Node.js)
- **Express.js** framework
- **Firebase Admin SDK** cho database
- **CORS** cho cross-origin requests
- **Helmet** cho security
- **Morgan** cho logging

### Database
- **Cloud Firestore** (Firebase)

## 📁 Cấu trúc project

```
youtube-link-manager/
├── client/                 # React frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── Client/     # Client components
│   │   │   └── Admin/      # Admin components
│   │   ├── services/       # API services
│   │   ├── types/          # TypeScript types
│   │   └── firebase.ts     # Firebase config
│   └── package.json
├── server/                 # Node.js backend
│   ├── routes/             # API routes
│   └── index.js           # Server entry point
├── package.json           # Root package.json
└── README.md
```

## 🚀 Cài đặt và chạy

### 1. Clone repository
```bash
git clone <repository-url>
cd youtube-link-manager
```

### 2. Cài đặt dependencies
```bash
# Cài đặt root dependencies
npm install

# Cài đặt client dependencies
cd client && npm install && cd ..

# Hoặc chạy tất cả cùng lúc
npm run install-all
```

### 3. Cấu hình Firebase
1. Copy `config.example.js` thành `config.js`
2. Cập nhật thông tin Firebase:
   - Project ID
   - Private Key
   - Client Email
3. Cập nhật `client/src/firebase.ts` với config từ Firebase Console

### 4. Chạy ứng dụng

#### Development mode (cả frontend và backend)
```bash
npm run dev
```

#### Chạy riêng lẻ
```bash
# Backend only
npm run server

# Frontend only
npm run client
```

### 5. Truy cập ứng dụng
- **Client**: http://localhost:3000
- **Admin**: http://localhost:3000/admin
- **API**: http://localhost:5000/api

## 📱 Cách sử dụng

### Client (Trang chính)
1. Truy cập http://localhost:3000
2. Sử dụng dropdown "Trạng thái" để lọc video
3. Click vào video để xem trên YouTube

### Admin Panel
1. Truy cập http://localhost:3000/admin
2. **Dashboard**: Xem thống kê tổng quan
3. **Thêm kênh YouTube**:
   - Nhập URL kênh YouTube
   - Click "Lấy thông tin kênh" để auto-fetch
   - Điền thông tin và lưu
4. **Quản lý links**: CRUD operations (sẽ implement)

## 🔧 API Endpoints

### YouTube Links
- `GET /api/youtube-links` - Lấy danh sách links
- `POST /api/youtube-links` - Tạo link mới
- `PUT /api/youtube-links/:id` - Cập nhật link
- `DELETE /api/youtube-links/:id` - Xóa link

### YouTube Channels
- `GET /api/youtube-channels` - Lấy danh sách kênh
- `POST /api/youtube-channels` - Tạo kênh mới
- `PUT /api/youtube-channels/:id` - Cập nhật kênh
- `DELETE /api/youtube-channels/:id` - Xóa kênh

### Admin
- `GET /api/admin/stats` - Thống kê dashboard
- `GET /api/admin/recent-activity` - Hoạt động gần đây

## 🎨 Giao diện

### Client
- **Dark theme** với gradient background
- **Hero section** hiển thị video nổi bật
- **Priority badges** với màu sắc phân biệt trạng thái
- **Responsive design** cho mobile

### Admin
- **Light theme** với sidebar navigation
- **Statistics cards** với icons và trends
- **Quick actions** cho thao tác nhanh
- **Form components** với validation

## 🔄 Migration từ HTML

Ứng dụng này được convert từ phiên bản HTML gốc với:
- ✅ Giữ nguyên giao diện và UX
- ✅ Convert sang React components
- ✅ Thêm TypeScript cho type safety
- ✅ Tách biệt frontend/backend
- ✅ API RESTful cho data management
- ✅ Responsive design
- ✅ Error handling và loading states

## 🚀 Production Deployment

### Build cho production
```bash
npm run build
```

### Deploy
1. **Frontend**: Deploy `client/build` lên hosting (Netlify, Vercel, etc.)
2. **Backend**: Deploy `server/` lên VPS hoặc cloud (Heroku, DigitalOcean, etc.)
3. **Database**: Sử dụng Firebase Firestore

## 📝 TODO

- [ ] Implement authentication
- [ ] Add real YouTube API integration
- [ ] Implement link management CRUD
- [ ] Add user management
- [ ] Add analytics dashboard
- [ ] Add push notifications
- [ ] Add dark/light theme toggle
- [ ] Add internationalization (i18n)

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

MIT License
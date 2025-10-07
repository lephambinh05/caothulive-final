# 📱 Hướng dẫn chạy Mobile App trên máy ảo

## 🎯 Tổng quan
Hướng dẫn chi tiết để chạy mobile app trên Android emulator.

## 🚀 Các bước thực hiện

### 1. **Kiểm tra máy ảo đang chạy**
```bash
flutter devices
```

**Kết quả mong đợi:**
```
Found 4 connected devices:
  ASUS AI2401 A (mobile) • emulator-5554 • android-x64    • Android 9 (API 28)
  Windows (desktop)      • windows       • windows-x64    • Microsoft Windows [Version 10.0.26100.6584]
  Chrome (web)           • chrome        • web-javascript • Google Chrome 140.0.7339.208
  Edge (web)             • edge          • web-javascript • Microsoft Edge 140.0.3485.94
```

### 2. **Chạy app trên máy ảo**

#### Cách 1: Chạy trực tiếp
```bash
cd mobile_app
flutter run -d emulator-5554
```

#### Cách 2: Sử dụng script (Windows)
```powershell
.\run_emulator.ps1
```

#### Cách 3: Sử dụng script (Linux/Mac)
```bash
chmod +x run_emulator.sh
./run_emulator.sh
```

### 3. **Hot Reload**
Khi app đang chạy, bạn có thể:
- **Hot Reload**: Nhấn `r` trong terminal
- **Hot Restart**: Nhấn `R` trong terminal
- **Quit**: Nhấn `q` trong terminal

## 📱 Tính năng app trên máy ảo

### **Tab 1: Videos**
- ✅ Danh sách video YouTube
- ✅ Filter theo priority (1-5)
- ✅ Tap để mở video trong YouTube app
- ✅ Pull-to-refresh

### **Tab 2: Channels**
- ✅ Danh sách kênh YouTube
- ✅ Hiển thị avatar, subscriber count
- ✅ Tap để mở kênh trong YouTube app

### **Tab 3: Support**
- ✅ Thông tin liên hệ
- ✅ Facebook, Email, SMS, Telegram, Zalo
- ✅ Tap để mở app tương ứng

## 🔧 Troubleshooting

### **Lỗi thường gặp:**

#### 1. **Không tìm thấy máy ảo**
```bash
# Kiểm tra emulator
flutter emulators

# Khởi động emulator
flutter emulators --launch <emulator_id>
```

#### 2. **App không chạy được**
```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter run -d emulator-5554
```

#### 3. **Firebase connection failed**
- Kiểm tra internet connection
- Kiểm tra file `android/app/google-services.json`

#### 4. **Build failed**
```bash
# Kiểm tra Flutter doctor
flutter doctor

# Update dependencies
flutter pub upgrade
```

## 🎨 Giao diện trên máy ảo

### **Bottom Navigation**
- **Videos**: Icon play_circle_outline
- **Channels**: Icon subscriptions  
- **Support**: Icon support_agent

### **Videos Tab**
- **Priority Filter**: Chips với màu sắc phân biệt
- **Video Cards**: Thumbnail, title, description, duration
- **Priority Tags**: Màu đỏ (1), cam (2), xanh (3), xám (4,5)

### **Channels Tab**
- **Channel Cards**: Avatar, name, subscriber count
- **Tap to Open**: Mở kênh trong YouTube app

### **Support Tab**
- **Contact Cards**: Icon, title, description
- **Tap to Contact**: Mở app tương ứng

## 📊 Performance

### **Tối ưu hóa:**
- **Image Caching**: Cached network images
- **Lazy Loading**: Load data khi cần
- **Error Handling**: Xử lý lỗi network
- **Loading States**: Hiển thị loading

### **Memory Usage:**
- **APK Size**: 21.8MB
- **RAM Usage**: ~50-100MB
- **Storage**: ~30MB

## 🚀 Next Steps

1. **Test trên nhiều devices**: Thử trên máy ảo khác
2. **Performance testing**: Kiểm tra hiệu suất
3. **User testing**: Test với người dùng thật
4. **Deploy**: Upload lên Google Play Store

## 📞 Support

Nếu có vấn đề:
- **Email**: caothulive@gmail.com
- **Facebook**: https://facebook.com/lephambinh.mmo
- **Check logs**: `flutter logs` trong terminal

---

**🎉 App đang chạy trên máy ảo! Hãy thử các tính năng và cho tôi biết nếu cần hỗ trợ gì thêm.**

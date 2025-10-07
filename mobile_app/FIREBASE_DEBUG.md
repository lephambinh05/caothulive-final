# 🔥 Firebase Debug - Mobile App

## 🔍 **Đang debug Firebase connection để kiểm tra data từ database!**

### 🎯 **Vấn đề phát hiện:**

#### **❌ Navbar hiển thị sai:**
- **Hình ảnh**: Navbar hiển thị "Trực tiếp", "Kênh", "Video", "Đăng ký"
- **Database**: Có data "88bet" với icon "language"
- **Kết luận**: App không lấy được data từ Firebase

#### **🔍 Debug logs đã thêm:**
```dart
// Debug logging
print('🔥 Firebase snapshot state: ${snapshot.connectionState}');
print('🔥 Firebase snapshot hasData: ${snapshot.hasData}');
print('🔥 Firebase snapshot hasError: ${snapshot.hasError}');
if (snapshot.hasError) {
  print('🔥 Firebase error: ${snapshot.error}');
}

if (snapshot.hasData) {
  final docs = snapshot.data!.docs;
  print('🔥 Firebase docs count: ${docs.length}');
  final links = docs.map((doc) => WebsiteLink.fromFirestore(doc)).toList();
  
  // Debug each link
  for (int i = 0; i < links.length; i++) {
    print('🔥 Link $i: ${links[i].title} - ${links[i].icon} - ${links[i].url}');
  }
}
```

### 🔧 **Các nguyên nhân có thể:**

#### **1. Firebase Connection Issues:**
- **Firebase config** không đúng
- **Firestore rules** chặn read access
- **Network connection** không ổn định
- **Firebase project** không match

#### **2. Collection Name Issues:**
- **Collection name** sai: `website_link` vs `website_links`
- **Document structure** không đúng
- **Field names** không match

#### **3. Data Structure Issues:**
- **Timestamp format** không đúng
- **Field types** không match
- **Required fields** missing

### 📊 **Database Data (từ user):**
```json
{
  "id": "1MtldT171VpQZyrsBhcD",
  "created_at": "October 2, 2025 at 7:19:44 PM UTC+7",
  "description": "",
  "icon": "language",
  "title": "88bet",
  "updated_at": "October 3, 2025 at 4:12:59 PM UTC+7",
  "url": "https://88bet9.net/"
}
```

### 🎯 **Expected Behavior:**
- **Navbar should show**: "88bet" với icon "language"
- **Tap should open**: "https://88bet9.net/" trong external browser
- **Current behavior**: Hiển thị default names

### 🔍 **Debug Steps:**

#### **1. Check Firebase Connection:**
- **Console logs** sẽ hiển thị connection state
- **Error messages** nếu có lỗi kết nối
- **Data count** nếu kết nối thành công

#### **2. Check Collection Name:**
- **Current**: `website_link`
- **Verify**: Collection name trong Firebase console
- **Update**: Nếu tên khác

#### **3. Check Data Structure:**
- **Field names**: `title`, `icon`, `url`, `created_at`
- **Data types**: String, Timestamp
- **Required fields**: All present

### 🚀 **Next Steps:**

#### **1. Run App và Check Logs:**
- **Chrome DevTools** → Console
- **Look for** 🔥 debug messages
- **Check** Firebase connection status

#### **2. Fix Issues:**
- **Update collection name** nếu cần
- **Fix Firebase config** nếu có lỗi
- **Update data structure** nếu cần

#### **3. Test Again:**
- **Reload app** sau khi fix
- **Check navbar** hiển thị đúng
- **Test tap** mở external link

### 🎉 **Expected Result:**
- **Navbar shows**: "88bet" với icon "language"
- **Tap opens**: "https://88bet9.net/" trong Chrome
- **Debug logs**: Show successful data fetch

**🔍 Đang debug Firebase connection để tìm nguyên nhân không lấy được data!** 🚀

## 📁 **Files Updated:**
- `lib/screens/website_home_screen.dart` - Added debug logging
- `FIREBASE_DEBUG.md` - This documentation

**🎯 Chạy app và check console logs để debug!** 📱

# 🔄 Migration Guide: app_drawer.dart → app_drawer_enhanced.dart

## 📌 Quick Fix (1 phút)

### Thay đổi import trong `home_screen.dart`:

```dart
// ❌ CŨ
import '../components/app_drawer.dart';

// ✅ MỚI  
import '../components/app_drawer_enhanced.dart';
```

**Lưu ý:** Không cần đổi tên class trong code, vẫn dùng `AppDrawer()`

---

## 🎯 Hoặc: Cleanup hoàn toàn (5 phút)

### Bước 1: Xóa file cũ
```bash
rm lib/components/app_drawer.dart
```

### Bước 2: Đổi tên file enhanced
```bash
mv lib/components/app_drawer_enhanced.dart lib/components/app_drawer.dart
```

### Bước 3: Update imports trong file enhanced → app_drawer.dart
Không cần làm gì, class name vẫn là `AppDrawer`

### Bước 4: Revert home_screen.dart về tên cũ
```dart
import '../components/app_drawer.dart'; // Giờ đã là file enhanced
```

### Bước 5: Clean và rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Verification Checklist

- [ ] Import statement đã update
- [ ] Hot restart app (không chỉ hot reload)
- [ ] Drawer hiển thị "🎧 Khám phá Podcast"
- [ ] Nếu là Creator → Hiển thị "📊 Quản lý Podcast"
- [ ] Tap các mục → Navigate đúng screen
- [ ] No compile errors

---

## 🚀 Quick Test

```bash
# Restart app
r (trong terminal đang chạy flutter)

# Hoặc kill và chạy lại
flutter run
```

Mở drawer → Thấy podcast menu items ✅

---

**Status:** ✅ FIXED  
**Time:** < 1 minute  
**Impact:** High (enable all podcast features)

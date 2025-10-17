# 📱 Hướng dẫn truy cập Podcast Feature

## 🎯 Các cách truy cập tính năng Podcast

### 1. **Từ Navigation Drawer** (Dành cho TẤT CẢ người dùng)

```
📱 App Screen
├── [☰] Menu Icon (góc trên trái)
    └── Drawer mở ra
        ├── 🏠 Trang chủ
        ├── 👤 Thông tin cá nhân
        ├── 💳 Gói cước của tôi
        ├── 🎧 Khám phá Podcast  ← CLICK VÀO ĐÂY
        │   └── "Nghe podcast về sức khỏe tinh thần"
        ├── ─────────────────
        ├── 📊 Quản lý Podcast (Chỉ hiện nếu là Content Creator)
        │   └── "Quản lý nội dung của bạn"
        └── ...
```

**Bước thực hiện:**
1. Mở app Healink
2. Tap vào icon **☰** (menu) ở góc trên bên trái
3. Trong drawer, tìm mục **"🎧 Khám phá Podcast"**
4. Tap vào → Chuyển đến màn hình danh sách podcast

---

### 2. **Từ Home Screen** (Dành cho Content Creator)

```
🏠 Home Screen
├── Hero Section (Ảnh nền + Text)
    └── [✅ Bạn đã là Content Creator]
        └── [📊 Quản lý Podcast của tôi]  ← CLICK VÀO ĐÂY
            └── Chuyển đến Creator Dashboard
```

**Điều kiện hiển thị:**
- ✅ User đã đăng ký làm Content Creator
- ✅ Đơn đăng ký đã được **Approved** (Duyệt)

**Bước thực hiện:**
1. Mở app Healink → Home Screen
2. Scroll xuống Hero Section (phần có quote và ảnh nền)
3. Nếu bạn là Content Creator, sẽ thấy:
   - Badge trắng: "✅ Bạn đã là Content Creator"
   - Button vàng: **"📊 Quản lý Podcast của tôi"**
4. Tap button → Chuyển đến Creator Dashboard

---

## 🎨 Visual Layout

### Navigation Drawer Layout
```
┌─────────────────────────────────┐
│  👤 User Name                    │
│  Content Creator ⭐              │ ← Hiện nếu là Creator
├─────────────────────────────────┤
│ 🏠 Trang chủ                     │
│ 👤 Thông tin cá nhân             │
│ 💳 Gói cước của tôi              │
│ 🎧 Khám phá Podcast             │ ← User thường tap vào đây
│    └ Nghe podcast sức khỏe...   │
├─────────────────────────────────┤
│ 📊 Quản lý Podcast              │ ← Chỉ Creator thấy
│    └ Quản lý nội dung của bạn   │
├─────────────────────────────────┤
│ 🛒 Đăng ký gói cước              │ ← Hiện nếu chưa subscribe
│ 📝 Đăng ký làm Creator           │ ← Hiện nếu chưa là Creator
├─────────────────────────────────┤
│ 🚪 Đăng xuất                     │
└─────────────────────────────────┘
```

### Home Screen Hero Section (Content Creator)
```
┌─────────────────────────────────┐
│                                  │
│      [Ảnh nền background]       │
│                                  │
│  "Nuôi dưỡng tâm hồn bằng..."   │
│                                  │
│  ┌─────────────────────────┐   │
│  │ ✅ Bạn đã là Content     │   │ ← Badge trắng
│  │    Creator 🎉             │   │
│  └─────────────────────────┘   │
│                                  │
│  ┌─────────────────────────┐   │
│  │ 📊 Quản lý Podcast       │   │ ← Button vàng
│  │    của tôi                │   │
│  └─────────────────────────┘   │
│                                  │
└─────────────────────────────────┘
```

### Home Screen Hero Section (User thường)
```
┌─────────────────────────────────┐
│                                  │
│      [Ảnh nền background]       │
│                                  │
│  "Nuôi dưỡng tâm hồn bằng..."   │
│                                  │
│  ┌─────────────────────────┐   │
│  │ Trở thành content        │   │ ← Button vàng
│  │ creator                   │   │
│  └─────────────────────────┘   │
│                                  │
└─────────────────────────────────┘
```

---

## 🎭 User Roles & Visibility

### **User thường (Non-Creator)**
```
Navigation Drawer:
  ✅ 🎧 Khám phá Podcast (Visible)
  ❌ 📊 Quản lý Podcast (Hidden)

Home Screen:
  ✅ Button "Trở thành content creator" (Visible)
  ❌ Badge + Button "Quản lý Podcast" (Hidden)
```

### **Content Creator (Approved)**
```
Navigation Drawer:
  ✅ 🎧 Khám phá Podcast (Visible)
  ✅ 📊 Quản lý Podcast (Visible) ← NEW!

Home Screen:
  ❌ Button "Trở thành content creator" (Hidden)
  ✅ Badge "Bạn đã là Content Creator" (Visible)
  ✅ Button "Quản lý Podcast của tôi" (Visible)
```

---

## 🔄 User Flow

### Flow 1: User thường → Nghe Podcast
```
1. Mở app
2. Tap [☰] Menu
3. Tap "🎧 Khám phá Podcast"
4. → PodcastListScreen
   ├── Browse trending/latest
   ├── Search podcast
   ├── Apply filters
   └── Tap podcast → Detail + Audio Player
```

### Flow 2: Content Creator → Quản lý Podcast (Từ Drawer)
```
1. Mở app (đã là Content Creator)
2. Tap [☰] Menu
3. Tap "📊 Quản lý Podcast"
4. → CreatorDashboardScreen
   ├── View my podcasts
   ├── Create new podcast
   ├── Edit podcast
   └── View analytics
```

### Flow 3: Content Creator → Quản lý Podcast (Từ Home)
```
1. Mở app (đã là Content Creator)
2. Scroll xuống Hero Section
3. See badge "✅ Bạn đã là Content Creator"
4. Tap button "📊 Quản lý Podcast của tôi"
5. → CreatorDashboardScreen
   └── Same as Flow 2
```

---

## 📊 Feature Matrix

| Tính năng | User thường | Content Creator |
|-----------|-------------|-----------------|
| **Khám phá Podcast** (Drawer) | ✅ | ✅ |
| **Quản lý Podcast** (Drawer) | ❌ | ✅ |
| **Button "Quản lý Podcast"** (Home) | ❌ | ✅ |
| **Button "Trở thành Creator"** (Home) | ✅ | ❌ |
| Nghe podcast | ✅ | ✅ |
| Like podcast | ✅ | ✅ |
| Tạo podcast mới | ❌ | ✅ |
| Sửa/Xóa podcast | ❌ | ✅ (chỉ podcast của mình) |
| View analytics | ❌ | ✅ |

---

## 🎨 Design Details

### Colors (Healink Theme)
- **Primary Brown**: `#8B6B3E` (Icon màu nâu cho Quản lý Podcast)
- **Accent Yellow**: `#FFD700` (Button "Quản lý Podcast của tôi")
- **White Badge**: `Colors.white.withOpacity(0.95)` (Badge Creator)
- **Green Check**: `Colors.green` (Icon verified ✅)

### Icons
- 🎧 `Icons.headphones` - Khám phá Podcast
- 📊 `Icons.dashboard` - Quản lý Podcast
- ✅ `Icons.verified` - Badge Content Creator
- 🎉 Emoji trong text

### Typography
- **Badge text**: fontSize 15, fontWeight bold
- **Button text**: Default button text
- **Subtitle**: Gray text dưới title

---

## 🧪 Testing Checklist

### Test Case 1: User thường
- [ ] Mở drawer → Thấy "🎧 Khám phá Podcast"
- [ ] Mở drawer → KHÔNG thấy "📊 Quản lý Podcast"
- [ ] Home Screen → Thấy button "Trở thành content creator"
- [ ] Home Screen → KHÔNG thấy badge Creator + button Quản lý
- [ ] Tap "Khám phá Podcast" → Chuyển đến PodcastListScreen
- [ ] Tap "Trở thành content creator" → Chuyển đến Application Screen

### Test Case 2: Content Creator
- [ ] Mở drawer → Thấy "🎧 Khám phá Podcast"
- [ ] Mở drawer → Thấy "📊 Quản lý Podcast"
- [ ] Home Screen → Thấy badge "✅ Bạn đã là Content Creator"
- [ ] Home Screen → Thấy button "📊 Quản lý Podcast của tôi"
- [ ] Home Screen → KHÔNG thấy "Trở thành content creator"
- [ ] Tap "Khám phá Podcast" (Drawer) → PodcastListScreen
- [ ] Tap "Quản lý Podcast" (Drawer) → CreatorDashboardScreen
- [ ] Tap "Quản lý Podcast của tôi" (Home) → CreatorDashboardScreen

### Test Case 3: Navigation
- [ ] Từ Drawer tap Quản lý Podcast → Drawer tự động đóng
- [ ] Từ Home tap button Quản lý → Navigate thành công
- [ ] Back button từ CreatorDashboard → Về Home
- [ ] Mở nhiều Creator Dashboard → Không bị duplicate screen

---

## 📝 Implementation Summary

### Files Updated
1. ✅ `lib/components/app_drawer_enhanced.dart`
   - Added: Mục "📊 Quản lý Podcast" (conditional render for ContentCreator)
   - Icon: `Icons.dashboard` màu brown
   - Subtitle: "Quản lý nội dung của bạn"
   - Action: Navigate to CreatorDashboardScreen

2. ✅ `lib/components/hero_section.dart`
   - Already has: Badge + Button "Quản lý Podcast của tôi"
   - Conditional render: Only show if `_creatorStatus.status == 'approved'`
   - Icon: `Icons.dashboard`
   - Color: Yellow accent (`kAccentColor`)

### Code Changes
```dart
// app_drawer_enhanced.dart - Added
if (_isContentCreator)
  ListTile(
    leading: const Icon(Icons.dashboard, color: Color(0xFF8B6B3E)),
    title: const Text('Quản lý Podcast', 
      style: TextStyle(fontWeight: FontWeight.w600)),
    subtitle: const Text('Quản lý nội dung của bạn'),
    onTap: () {
      Navigator.pop(context);
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => const CreatorDashboardScreen()));
    },
  ),
```

---

## 🎉 Kết luận

Bây giờ có **3 cách** để Content Creator truy cập quản lý podcast:

1. ✅ **Navigation Drawer** → "📊 Quản lý Podcast" (NEW!)
2. ✅ **Home Screen** → Button "Quản lý Podcast của tôi"
3. ✅ **Navigation Drawer** → "🎧 Khám phá Podcast" (cho tất cả users)

**Deployment Status**: ✅ Ready for testing

---

**Version**: 1.1.0  
**Date**: October 16, 2025  
**Author**: Healink Dev Team

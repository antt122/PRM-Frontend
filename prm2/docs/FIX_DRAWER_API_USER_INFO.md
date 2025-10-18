# 🔧 Fix: Navigation Drawer hiển thị thông tin user thật từ API

## ❌ Vấn đề trước khi fix

Navigation Drawer hiển thị thông tin không chính xác:
- ❌ Hiển thị "User" thay vì tên thật
- ❌ Không kiểm tra subscription status từ API
- ❌ Không kiểm tra creator status từ API (chỉ dựa vào SharedPreferences)
- ❌ Không hiển thị email
- ❌ Hiển thị role sai

## ✅ Giải pháp

Thay đổi `app_drawer_enhanced.dart` để:
1. **Gọi API getUserProfile()** để lấy tên và email thật
2. **Gọi API getMyCreatorApplicationStatus()** để check xem user có phải Content Creator không
3. **Gọi API getMySubscription()** để check subscription status

## 🔄 Changes Made

### File: `lib/components/app_drawer_enhanced.dart`

#### 1. Added API imports
```dart
import '../services/api_service.dart';
```

#### 2. Added email field
```dart
class _AppDrawerState extends State<AppDrawer> {
  bool _isContentCreator = false;
  bool _hasSubscription = false;
  bool _isLoading = true;
  String _userName = 'User';
  String _userEmail = '';  // ← NEW
  ...
}
```

#### 3. Rewrote _loadUserInfo() to call APIs

**Before (Old - Using SharedPreferences):**
```dart
Future<void> _loadUserInfo() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    final rolesString = prefs.getString('userRoles') ?? '';
    final roles = rolesString.split(',');
    
    final name = prefs.getString('userName') ?? 'User';
    final hasSubscription = prefs.getBool('hasActiveSubscription') ?? false;
    
    setState(() {
      _isContentCreator = roles.contains('ContentCreator');
      _hasSubscription = hasSubscription;
      _userName = name;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}
```

**After (New - Using API calls):**
```dart
Future<void> _loadUserInfo() async {
  try {
    // 1. Load user profile từ API
    final profileResult = await ApiService.getUserProfile();
    if (profileResult.isSuccess && profileResult.data != null) {
      final profile = profileResult.data!;
      setState(() {
        _userName = profile.fullName;
        _userEmail = profile.email;
      });
    }

    // 2. Check creator status từ API
    final creatorResult = await ApiService.getMyCreatorApplicationStatus();
    if (creatorResult.isSuccess && creatorResult.data != null) {
      final status = creatorResult.data!.status.toLowerCase();
      setState(() {
        _isContentCreator = (status == 'approved');
      });
    }

    // 3. Check subscription status từ API
    final subscriptionResult = await ApiService.getMySubscription();
    if (subscriptionResult.isSuccess && subscriptionResult.data != null) {
      final subscription = subscriptionResult.data!;
      setState(() {
        _hasSubscription = subscription.subscriptionStatusName.toLowerCase() == 'active';
      });
    }

    setState(() {
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}
```

#### 4. Updated UserAccountsDrawerHeader to show email

**Before:**
```dart
UserAccountsDrawerHeader(
  accountName: Text(_userName),
  accountEmail: Text(
    _isContentCreator ? 'Content Creator ⭐' : 'User',
  ),
  ...
)
```

**After:**
```dart
UserAccountsDrawerHeader(
  accountName: Text(_userName),
  accountEmail: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_userEmail.isNotEmpty)
        Text(_userEmail, style: TextStyle(fontSize: 12)),
      if (_isContentCreator)
        Text(
          'Content Creator ⭐',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
    ],
  ),
  ...
)
```

## 📊 API Endpoints Called

### 1. GET User Profile
```
GET /user/profile
Authorization: Bearer {token}

Response:
{
  "fullName": "Nguyễn Văn A",
  "email": "nguyenvana@gmail.com",
  ...
}
```

### 2. GET Creator Status
```
GET /CreatorApplications/my-status
Authorization: Bearer {token}

Response:
{
  "status": "Approved", // or "Pending", "Rejected", "None"
  ...
}
```

### 3. GET Subscription Status
```
GET /user/subscriptions/me
Authorization: Bearer {token}

Response:
{
  "subscriptionStatusName": "Active", // or "Expired", "Cancelled"
  "planDisplayName": "Premium",
  ...
}
```

## 🎯 Result

### Before Fix:
```
┌─────────────────────────┐
│ U                       │
│ User                    │ ← Generic "User"
│ User                    │ ← Wrong role
└─────────────────────────┘
```

### After Fix - Regular User:
```
┌─────────────────────────┐
│ N                       │
│ Nguyễn Văn A            │ ← Real name from API
│ nguyenvana@gmail.com    │ ← Real email
└─────────────────────────┘
```

### After Fix - Content Creator:
```
┌─────────────────────────┐
│ N                       │
│ Nguyễn Văn B            │ ← Real name from API
│ nguyenvanb@gmail.com    │ ← Real email
│ Content Creator ⭐      │ ← Checked from API (Approved status)
└─────────────────────────┘
```

### After Fix - Premium User:
```
┌─────────────────────────┐
│ N                       │
│ Nguyễn Văn C            │
│ nguyenvanc@gmail.com    │
├─────────────────────────┤
│ 🏠 Trang chủ            │
│ 👤 Thông tin cá nhân    │
│ 💳 Gói cước của tôi     │
│ 🎧 Khám phá Podcast     │
├─────────────────────────┤
│ (NO "Đăng ký gói cước") │ ← Hidden because hasSubscription = true
└─────────────────────────┘
```

## 🔍 Logic Flow

```
initState()
  └─> _loadUserInfo()
      ├─> API: getUserProfile()
      │   └─> Set: _userName, _userEmail
      │
      ├─> API: getMyCreatorApplicationStatus()
      │   └─> Set: _isContentCreator = (status == "Approved")
      │
      └─> API: getMySubscription()
          └─> Set: _hasSubscription = (status == "Active")
```

## ⚡ Performance

### Loading Sequence:
1. **Drawer opens** → Show CircularProgressIndicator
2. **Call 3 APIs in parallel** (Future.wait có thể optimize)
3. **Update UI** với setState()
4. **Show content** với thông tin thật

### Optimization Suggestions (Future):
```dart
// Có thể optimize bằng Future.wait
Future<void> _loadUserInfo() async {
  final results = await Future.wait([
    ApiService.getUserProfile(),
    ApiService.getMyCreatorApplicationStatus(),
    ApiService.getMySubscription(),
  ]);
  
  // Process results...
}
```

## 🧪 Testing

### Test Case 1: Regular User (không phải Creator, không có subscription)
- [ ] Open drawer
- [ ] Verify: Shows real name (not "User")
- [ ] Verify: Shows email
- [ ] Verify: NO "Content Creator ⭐" badge
- [ ] Verify: Shows "Đăng ký gói cước"
- [ ] Verify: Shows "Đăng ký làm Creator"
- [ ] Verify: NO "Quản lý Podcast"

### Test Case 2: Content Creator (Approved)
- [ ] Open drawer
- [ ] Verify: Shows real name
- [ ] Verify: Shows email
- [ ] Verify: Shows "Content Creator ⭐" in GOLD color
- [ ] Verify: Shows "Quản lý Podcast"
- [ ] Verify: NO "Đăng ký làm Creator"

### Test Case 3: Premium User (có subscription active)
- [ ] Open drawer
- [ ] Verify: Shows real name
- [ ] Verify: Shows email
- [ ] Verify: NO "Đăng ký gói cước" (hidden)

### Test Case 4: API Errors
- [ ] Kill backend server
- [ ] Open drawer
- [ ] Verify: Still shows drawer (with default values)
- [ ] Verify: No crash

## 🚨 Error Handling

```dart
try {
  // API calls...
} catch (e) {
  // Vẫn hiển thị drawer với giá trị mặc định
  setState(() {
    _isLoading = false;
  });
}
```

**Behavior when API fails:**
- Drawer vẫn mở được
- Hiển thị "User" thay vì crash
- Menu items vẫn hoạt động bình thường

## 📝 Notes

### Why not use SharedPreferences?
- ❌ Data có thể bị outdated
- ❌ Không sync với database
- ❌ User có thể clear cache
- ✅ API luôn return fresh data

### When SharedPreferences is still used?
- ✅ Store access token
- ✅ Remember login state
- ✅ Temporary cache (with TTL)

## 🎉 Summary

**Changed:**
- ✅ Load user name from API (not SharedPreferences)
- ✅ Load email from API
- ✅ Check creator status from API (status == "Approved")
- ✅ Check subscription status from API (status == "Active")
- ✅ Display email in header
- ✅ Display "Content Creator ⭐" badge in gold color

**Impact:**
- ✅ Drawer shows accurate user information
- ✅ Role-based menus work correctly
- ✅ Better UX with real-time data
- ✅ Consistent with backend database

---

**Fixed Date:** October 17, 2025  
**File:** `lib/components/app_drawer_enhanced.dart`  
**Lines Changed:** ~40 lines

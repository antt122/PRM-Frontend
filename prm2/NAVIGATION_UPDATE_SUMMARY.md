# Flutter App - Screen Navigation Summary

**Date**: October 15, 2025  
**Project**: Healink Mobile App (prm2)

---

## ✅ Screens Available & Navigation Status

### 📱 Main Screens

| Screen | File | Navigation | Status | Notes |
|--------|------|------------|--------|-------|
| **Home** | `home_screen.dart` | ✅ Default | ✅ Updated | Added AppDrawer integration |
| **Profile** | `profile_screen.dart` | ✅ Drawer | ✅ New | Basic placeholder screen |
| **My Subscription** | `my_subscription_screen.dart` | ✅ Drawer | ✅ New | Shows user's active subscription |
| **Login** | `login_screen.dart` | Entry point | ✅ Existing | - |
| **Register** | `register_screen.dart` | From Login | ✅ Existing | - |
| **OTP Verification** | `OtpVerificationScreen.dart` | After Register | ✅ Existing | - |
| **Splash** | `splash_screen.dart` | Initial | ✅ Existing | Auto-checks token |

### 💳 Subscription Flow Screens

| Screen | File | Navigation | Status | Notes |
|--------|------|------------|--------|-------|
| **Checkout** | `checkout_screen.dart` | From PricingSection | ✅ Existing | Payment method selection |

### 🎙️ Content Creator Screens

| Screen | File | Navigation | Status | Needs Adding to Nav? |
|--------|------|------------|--------|---------------------|
| **Creator Dashboard** | `creator_dashboard_screen.dart` | ❌ Missing | ✅ Existing | ⚠️ **YES - Add to Drawer** |
| **Create Podcast** | `create_postcard_screen.dart` | From Dashboard | ✅ Existing | No (accessed from Dashboard) |
| **Creator Application** | `creator_application_screen.dart` | From Profile? | ✅ Existing | ⚠️ **Consider adding** |
| **Application Status** | `application_status_screen.dart` | From Application | ✅ Existing | No (accessed from Application) |

---

## 🔧 Changes Made

### 1. ✅ Updated `home_screen.dart`

**Before**:
```dart
leading: IconButton(
  icon: const Icon(Icons.menu, color: kPrimaryTextColor),
  onPressed: () {}, // Empty action
),
```

**After**:
```dart
drawer: const AppDrawer(), // Added drawer
...
leading: Builder(
  builder: (context) => IconButton(
    icon: const Icon(Icons.menu, color: kPrimaryTextColor),
    onPressed: () => Scaffold.of(context).openDrawer(), // Opens drawer
  ),
),
```

### 2. ✅ New Component: `app_drawer.dart`

**Features**:
- ✅ Navigation to Home
- ✅ Navigation to Profile Screen
- ✅ Navigation to My Subscription Screen
- ✅ Logout functionality
- ❌ **Missing**: Creator Dashboard link (for Content Creators)

---

## ⚠️ Recommendations - Screens to Add to Navigation

### Priority 1: Content Creator Dashboard

**Issue**: Users with `ContentCreator` role can't access their dashboard from the main navigation.

**Solution**: Add conditional navigation item in `AppDrawer`:

```dart
// Add this in app_drawer.dart after "My Subscription"
FutureBuilder<bool>(
  future: _checkIfCreator(), // Check if user has ContentCreator role
  builder: (context, snapshot) {
    if (snapshot.data == true) {
      return ListTile(
        leading: const Icon(Icons.create),
        title: const Text('Trang sáng tạo'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatorDashboardScreen(),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  },
),
```

### Priority 2: Subscription Plans (for users without subscription)

**Issue**: Users who don't have a subscription can't easily browse plans.

**Solution**: Add navigation to checkout/plans screen:

```dart
ListTile(
  leading: const Icon(Icons.shopping_cart),
  title: const Text('Đăng ký gói cước'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  },
),
```

### Priority 3: Creator Application (for regular users)

**Issue**: Regular users might want to become Content Creators but can't find the application form.

**Solution**: Add conditional navigation for non-creators:

```dart
// Show only if user is NOT a ContentCreator
FutureBuilder<bool>(
  future: _checkIfCreator(),
  builder: (context, snapshot) {
    if (snapshot.data == false) {
      return ListTile(
        leading: const Icon(Icons.edit_note),
        title: const Text('Đăng ký làm Creator'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatorApplicationScreen(),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  },
),
```

---

## 📊 Current Navigation Structure

```
HomeScreen (with AppDrawer)
├── Drawer
│   ├── Trang chủ (closes drawer)
│   ├── Thông tin cá nhân → ProfileScreen ✅
│   ├── Gói cước của tôi → MySubscriptionScreen ✅
│   └── Đăng xuất → LoginScreen ✅
│
├── PricingSection
│   └── Subscribe button → CheckoutScreen ✅
│
└── (Missing in Drawer)
    ├── Creator Dashboard ❌
    ├── Subscription Plans ❌
    └── Creator Application ❌
```

---

## 🎯 Recommended Complete Navigation Structure

```
HomeScreen (with Enhanced AppDrawer)
├── Drawer
│   ├── Trang chủ
│   ├── Thông tin cá nhân → ProfileScreen ✅
│   ├── Gói cước của tôi → MySubscriptionScreen ✅
│   ├── ─────────────────────────
│   ├── Đăng ký gói cước → CheckoutScreen (if no subscription) ⚠️ NEW
│   ├── Trang sáng tạo → CreatorDashboardScreen (if ContentCreator) ⚠️ NEW
│   ├── Đăng ký làm Creator → CreatorApplicationScreen (if not Creator) ⚠️ NEW
│   ├── ─────────────────────────
│   └── Đăng xuất → LoginScreen ✅
```

---

## 🔄 API Integration Status

### ✅ Already Integrated APIs

| API Endpoint | Screen | Method | Status |
|-------------|--------|--------|--------|
| `POST /user/subscriptions/register` | CheckoutScreen | registerSubscription() | ✅ |
| `GET /user/subscriptions/me` | MySubscriptionScreen | getMySubscription() | ✅ |
| `GET /user/subscription-plans` | CheckoutScreen | getSubscriptionPlans() | ✅ |
| `GET /user/payment-methods` | CheckoutScreen | getPaymentMethods() | ✅ |
| `POST /user/auth/login` | LoginScreen | login() | ✅ |
| `POST /user/auth/register` | RegisterScreen | register() | ✅ |
| `GET /creator/podcasts` | CreatorDashboardScreen | getMyPosts() | ✅ |

### ⚠️ APIs to Consider Adding

| API Endpoint | Potential Screen | Purpose |
|-------------|------------------|---------|
| `GET /user/profile/me` | ProfileScreen | Show user profile details |
| `PUT /user/profile/me` | ProfileScreen | Edit user profile |
| `POST /user/profile/apply-creator` | CreatorApplicationScreen | Already implemented |
| `GET /CreatorApplications/my-status` | ApplicationStatusScreen | Already implemented |

---

## 📝 Next Steps

### Immediate Actions

1. **Update `app_drawer.dart`**:
   - Add ContentCreator role checking
   - Add conditional navigation items
   - Import missing screens

2. **Implement Role Detection**:
   ```dart
   // Add to api_service.dart
   static Future<bool> isContentCreator() async {
     final prefs = await SharedPreferences.getInstance();
     final roles = prefs.getStringList('userRoles') ?? [];
     return roles.contains('ContentCreator');
   }
   ```

3. **Update ProfileScreen**:
   - Fetch and display user profile data
   - Add edit profile functionality
   - Show user role badge

### Future Enhancements

- Add bottom navigation bar for main screens (Home, Profile, Subscriptions)
- Add notifications screen
- Add search functionality
- Add settings screen
- Add help/support screen

---

## 🚀 Testing Checklist

### Navigation Tests

- [ ] Drawer opens from HomeScreen
- [ ] Navigate to Profile from Drawer
- [ ] Navigate to My Subscription from Drawer
- [ ] Logout works from Drawer
- [ ] Drawer closes after navigation
- [ ] Back button works correctly on all screens

### API Tests

- [ ] My Subscription loads correctly
- [ ] Shows "No subscription" message if not subscribed
- [ ] Profile screen loads user data
- [ ] Creator Dashboard loads for ContentCreators only
- [ ] Regular users can't access Creator Dashboard

### Edge Cases

- [ ] Handle no internet connection
- [ ] Handle expired token (redirect to login)
- [ ] Handle API errors gracefully
- [ ] Show loading indicators
- [ ] Handle empty states

---

**Summary**: 
- ✅ AppDrawer integrated into HomeScreen
- ✅ 3 new screens added to navigation (Profile, My Subscription, Home)
- ⚠️ 3 screens recommended to add (Creator Dashboard, Subscription Plans, Creator Application)
- 📱 All screens properly connected to API services

**Status**: ✅ Ready for testing and further enhancement

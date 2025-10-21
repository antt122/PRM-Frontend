import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../screens/my_subscription_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/creator_dashboard_screen.dart';
import '../screens/creator_application_screen.dart';
import '../services/api_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isContentCreator = false;
  bool _hasSubscription = false;
  bool _isLoading = true;
  String _userName = 'User';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Load user info from API
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
        // Check if subscription is active
        setState(() {
          _hasSubscription =
              subscription.subscriptionStatusName.toLowerCase() == 'active';
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Nếu có lỗi, vẫn hiển thị drawer với giá trị mặc định
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm xử lý đăng xuất
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    if (!context.mounted) return;

    // Điều hướng về màn hình Login và xóa tất cả các màn hình cũ
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(8, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    // Header của Drawer với liquid glass theme
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B6B3E).withOpacity(0.6),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B6B3E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_userEmail.isNotEmpty)
                            Text(
                              _userEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          if (_isContentCreator)
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text(
                                    'Content Creator',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Mục "Trang chủ"
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.white70),
                      title: const Text(
                        'Trang chủ',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Đóng Drawer
                      },
                    ),

                    // Mục "Thông tin cá nhân"
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white70),
                      title: const Text(
                        'Thông tin cá nhân',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                        ); // Đóng Drawer trước khi điều hướng
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),

                    // Mục "Gói cước của tôi"
                    ListTile(
                      leading: const Icon(
                        Icons.subscriptions,
                        color: Colors.white70,
                      ),
                      title: const Text(
                        'Gói cước của tôi',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MySubscriptionScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(color: Colors.white12),

                    // ⚠️ NEW: "Quản lý Podcast" - Show only for ContentCreators
                    if (_isContentCreator)
                      ListTile(
                        leading: const Icon(
                          Icons.dashboard,
                          color: Colors.white70,
                        ),
                        title: const Text(
                          'Quản lý Podcast',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: const Text(
                          'Quản lý nội dung của bạn',
                          style: TextStyle(color: Colors.white54),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreatorDashboardScreen(),
                            ),
                          );
                        },
                      ),

                    const Divider(color: Colors.white12),

                    // ⚠️ NEW: "Đăng ký gói cước" - Show if user doesn't have subscription
                    if (!_hasSubscription)
                      ListTile(
                        leading: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white70,
                        ),
                        title: const Text(
                          'Đăng ký gói cước',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Truy cập nội dung premium',
                          style: TextStyle(color: Colors.white54),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to a plans list screen or checkout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vui lòng chọn gói từ phần Pricing trên trang chủ',
                              ),
                            ),
                          );
                        },
                      ),

                    // ⚠️ NEW: "Đăng ký làm Creator" - Show only for non-ContentCreators
                    if (!_isContentCreator)
                      ListTile(
                        leading: const Icon(
                          Icons.edit_note,
                          color: Colors.white70,
                        ),
                        title: const Text(
                          'Đăng ký làm Creator',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Trở thành nhà sáng tạo nội dung',
                          style: TextStyle(color: Colors.white54),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreatorApplicationScreen(),
                            ),
                          );
                        },
                      ),

                    const Divider(color: Colors.white12),

                    // Mục "Đăng xuất"
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () => _logout(context), // Gọi hàm đăng xuất
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

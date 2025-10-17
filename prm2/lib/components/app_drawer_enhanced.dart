
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../screens/my_subscription_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/creator_dashboard_screen.dart';
import '../screens/creator_application_screen.dart';
import '../screens/podcast_list_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Load user info from SharedPreferences
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check user roles (assuming roles are stored as JSON array or comma-separated string)
      final rolesString = prefs.getString('userRoles') ?? '';
      final roles = rolesString.split(',').map((r) => r.trim()).toList();
      
      // Get user name
      final name = prefs.getString('userName') ?? 'User';
      
      // Check subscription status (you can call API here if needed)
      final hasSubscription = prefs.getBool('hasActiveSubscription') ?? false;
      
      setState(() {
        _isContentCreator = roles.contains('ContentCreator');
        _hasSubscription = hasSubscription;
        _userName = name;
        _isLoading = false;
      });
    } catch (e) {
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
    return Drawer(
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Header của Drawer
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF8B6B3E), // Màu nâu giống theme
                ),
                accountName: Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  _isContentCreator ? 'Content Creator ⭐' : 'User',
                  style: const TextStyle(fontSize: 14),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B6B3E),
                    ),
                  ),
                ),
              ),
              
              // Mục "Trang chủ"
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Trang chủ'),
                onTap: () {
                  Navigator.pop(context); // Đóng Drawer
                },
              ),
              
              // Mục "Thông tin cá nhân"
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Thông tin cá nhân'),
                onTap: () {
                  Navigator.pop(context); // Đóng Drawer trước khi điều hướng
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              
              // Mục "Gói cước của tôi"
              ListTile(
                leading: const Icon(Icons.subscriptions),
                title: const Text('Gói cước của tôi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MySubscriptionScreen()),
                  );
                },
              ),
              
              // ⚠️ NEW: "Khám phá Podcast"
              ListTile(
                leading: const Icon(Icons.headphones),
                title: const Text('Khám phá Podcast'),
                subtitle: const Text('Nghe podcast về sức khỏe tinh thần'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PodcastListScreen()),
                  );
                },
              ),
              
              const Divider(),
              
              // ⚠️ NEW: "Quản lý Podcast" - Show only for ContentCreators
              if (_isContentCreator)
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Color(0xFF8B6B3E)),
                  title: const Text(
                    'Quản lý Podcast',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Quản lý nội dung của bạn'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatorDashboardScreen(),
                      ),
                    );
                  },
                ),
              
              const Divider(),
              
              // ⚠️ NEW: "Đăng ký gói cước" - Show if user doesn't have subscription
              if (!_hasSubscription)
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: const Text('Đăng ký gói cước'),
                  subtitle: const Text('Truy cập nội dung premium'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to a plans list screen or checkout
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng chọn gói từ phần Pricing trên trang chủ'),
                      ),
                    );
                  },
                ),
              
              // ⚠️ NEW: "Đăng ký làm Creator" - Show only for non-ContentCreators
              if (!_isContentCreator)
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('Đăng ký làm Creator'),
                  subtitle: const Text('Trở thành nhà sáng tạo nội dung'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatorApplicationScreen(),
                      ),
                    );
                  },
                ),
              
              const Divider(),
              
              // Mục "Cài đặt" (Optional - can be added later)
              // ListTile(
              //   leading: const Icon(Icons.settings),
              //   title: const Text('Cài đặt'),
              //   onTap: () {
              //     // Navigate to settings
              //   },
              // ),
              
              // Mục "Đăng xuất"
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                onTap: () => _logout(context), // Gọi hàm đăng xuất
              ),
            ],
          ),
    );
  }
}

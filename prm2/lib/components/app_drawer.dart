
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../screens/my_subscription_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Hàm xử lý đăng xuất
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken'); // Xóa token

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
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header của Drawer
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF8B6B3E), // Màu nâu giống theme
            ),
            child: Text(
              'Healink',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          // Mục "Gói cước của tôi"
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Gói cước của tôi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MySubscriptionScreen()));
            },
          ),
          const Divider(),
          // Mục "Đăng xuất"
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () => _logout(context), // Gọi hàm đăng xuất
          ),
        ],
      ),
    );
  }
}

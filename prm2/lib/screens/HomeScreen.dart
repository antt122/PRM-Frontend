import 'package:flutter/material.dart';
import 'package:prm2/screens/SubscriptionDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/DashboardCard.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'LoginScreen.dart';
import 'ProfileScreen.dart';
import 'UserManagementScreen.dart';
import 'SubscriptionPlanManagementScreen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kAdminCardColor,
          title: const Text('Xác nhận đăng xuất', style: TextStyle(color: kAdminPrimaryTextColor)),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?', style: TextStyle(color: kAdminSecondaryTextColor)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: kAdminSecondaryTextColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Đăng xuất', style: TextStyle(color: kAdminErrorColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && context.mounted) {
      final apiService = ApiService();
      apiService.logout();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAdminBackgroundColor,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
              color: kAdminPrimaryTextColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          // --- THÊM NÚT XEM PROFILE Ở ĐÂY ---
          IconButton(
            icon: const Icon(Icons.person_outline, color: kAdminSecondaryTextColor),
            tooltip: 'Hồ sơ của tôi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: kAdminSecondaryTextColor),
            tooltip: 'Đăng xuất',
            onPressed: () => _handleLogout(context),
          ),
          const SizedBox(width: 8), // Thêm một chút khoảng cách
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
        children: [
          DashboardCard(
            icon: Icons.group_outlined,
            title: 'Quản lý người dùng',
            subtitle: 'Xem, tạo, sửa, xóa',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
            },
          ),
          DashboardCard(
            icon: Icons.group_outlined,
            title: 'Quản lý gói đăng ký',
            subtitle: 'Xem, tạo, sửa, xóa',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionPlanManagementScreen()),
              );
            },
          ),
          DashboardCard(
            icon: Icons.article_outlined,
            title: 'Quản lý Nội dung',
            subtitle: 'Duyệt podcast, bài viết',
            onTap: () {},
          ),
          DashboardCard(
            icon: Icons.bar_chart_outlined,
            title: 'Thống kê',
            subtitle: 'Xem báo cáo, doanh thu',
            onTap: () {},
          ),
          DashboardCard(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            subtitle: 'Cấu hình hệ thống',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}


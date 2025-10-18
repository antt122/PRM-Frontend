import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/DashboardCard.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'CommunityStoriesScreen.dart';
import 'CreatorApplicationListScreen.dart';
import 'LoginScreen.dart';
import 'PaymentMethodListScreen.dart';
import 'PodcastListScreen.dart';
import 'PodcastStatisticsDashboard.dart';
import 'UserManagementScreen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kAdminCardColor,
          title: const Text('Xác nhận đăng xuất',
              style: TextStyle(color: kAdminPrimaryTextColor)),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?',
              style: TextStyle(color: kAdminSecondaryTextColor)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy',
                  style: TextStyle(color: kAdminSecondaryTextColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child:
              const Text('Đăng xuất', style: TextStyle(color: kAdminErrorColor)),
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
    // Danh sách các chức năng trên dashboard
    final List<Widget> dashboardItems = [
      DashboardCard(
        icon: Icons.group_outlined,
        title: 'Quản lý Người dùng',
        subtitle: 'Xem, tạo, sửa, xóa người dùng',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserManagementScreen()),
          );
        },
      ),
      // --- THÊM CHỨC NĂNG MỚI Ở ĐÂY ---
      DashboardCard(
        icon: Icons.forum_outlined,
        title: 'Community Stories',
        subtitle: 'Duyệt và quản lý bài viết',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CommunityStoriesScreen()),
          );
        },
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
      DashboardCard(
        icon: Icons.podcasts_outlined, title: 'Quản lý Podcasts',
        subtitle: 'Duyệt và quản lý podcasts',
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (c) => const PodcastListScreen())),
      ),
      DashboardCard(
        icon: Icons.bar_chart_outlined,
        title: 'Thống kê',
        subtitle: 'Xem báo cáo tổng quan',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const PodcastStatisticsDashboard()));
        },
      ),
      DashboardCard(
        icon: Icons.how_to_reg_outlined,
        title: 'Duyệt đơn Creator',
        subtitle: 'Xem các đơn đăng ký đang chờ',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const CreatorApplicationListScreen()),
          );
        },
      ),

      DashboardCard(
        icon: Icons.payment_outlined,
        title: 'Quản lý Thanh toán',
        subtitle: 'Cấu hình phương thức',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const PaymentMethodListScreen()),
          );
        },
      ),
    ];

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
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: kAdminSecondaryTextColor),
            onPressed: () => _handleLogout(context),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dashboardItems.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 150, // Chiều cao cố định cho mỗi thẻ
            child: dashboardItems[index],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}


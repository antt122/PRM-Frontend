import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

// Import các file constants và các component đã được chia nhỏ
import '../utils/app_colors.dart';
import '../components/hero_section.dart';
import '../components/mindfulness_highlights.dart';
import '../components/community_section.dart';
import '../components/pricing_section.dart';
import '../components/app_drawer_enhanced.dart'; // Import AppDrawer Enhanced với đầy đủ tính năng

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Logic logout không thay đổi
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      drawer: const AppDrawer(), // Thêm Drawer vào đây
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kBackgroundColor,
            elevation: 0,
            pinned: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: kPrimaryTextColor),
                onPressed: () => Scaffold.of(context).openDrawer(), // Mở drawer
              ),
            ),
            title: const Text(
              'HEALINK',
              style: TextStyle(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: kPrimaryTextColor),
                tooltip: 'Đăng xuất',
                onPressed: () => _logout(context),
              ),
            ],
          ),
          // Sử dụng các Widget đã được tách ra từ các file riêng biệt
          SliverToBoxAdapter(
            child: Column(
              children: const [
                HeroSection(),
                MindfulnessHighlights(),
                CommunitySection(),
                PricingSection(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_bar/liquid_glass_bottom_bar.dart';

class LiquidGlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LiquidGlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBottomBar(
      items: const [
        LiquidGlassBottomBarItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Trang chủ',
        ),
        LiquidGlassBottomBarItem(
          icon: Icons.trending_up_outlined,
          activeIcon: Icons.trending_up,
          label: 'Thịnh hành',
        ),
        LiquidGlassBottomBarItem(
          icon: Icons.schedule_outlined,
          activeIcon: Icons.schedule,
          label: 'Mới nhất',
        ),
        LiquidGlassBottomBarItem(
          icon: Icons.psychology_outlined,
          activeIcon: Icons.psychology,
          label: 'AI đề xuất',
        ),
        LiquidGlassBottomBarItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: 'Tìm kiếm',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      // Tùy chỉnh để giống Apple Music iOS 16
      activeColor: const Color(0xFF007AFF), // Màu xanh iOS
      barBlurSigma: 20, // Độ mờ của thanh
      activeBlurSigma: 30, // Độ mờ khi active
    );
  }
}

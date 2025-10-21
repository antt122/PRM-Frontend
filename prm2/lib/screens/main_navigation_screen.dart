import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';
import '../components/liquid_glass_bottom_nav.dart';
import 'home_screen.dart';
import 'trending_podcasts_screen.dart';
import 'latest_podcasts_screen.dart';
import 'ai_recommendations_screen.dart';
import 'search_podcasts_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrendingPodcastsScreen(),
    const LatestPodcastsScreen(),
    const AIRecommendationsScreen(),
    const SearchPodcastsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Cần thiết để hiệu ứng liquid glass hoạt động
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player at bottom (shows when audio is playing)
          const MiniPlayer(),

          // Liquid Glass Bottom Navigation
          LiquidGlassBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

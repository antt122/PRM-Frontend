import 'package:flutter/material.dart';
import 'dart:ui';

// Import các file constants và các component đã được chia nhỏ
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';
import '../components/hero_section.dart';
import '../components/mindfulness_highlights.dart';
import '../components/community_section.dart';
import '../components/pricing_section.dart';
import '../components/app_drawer_enhanced.dart'; // Import AppDrawer Enhanced với đầy đủ tính năng

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true, // For liquid glass effect
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kGlassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGlassBorder, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: kPrimaryTextColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: const Text(
            'HEALINK',
            style: TextStyle(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontFamily: AppFonts.sfProDisplay,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          // Removed logout button - logout is now handled through AppDrawer
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundColor, kSurfaceColor],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            // HomeScreen không gọi API podcast; giữ chỗ để tương lai cập nhật section nếu cần
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          color: kPrimaryTextColor,
          backgroundColor: Colors.black54,
          child: CustomScrollView(
            slivers: [
              // Add top padding for status bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              // Hero section with liquid glass
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kGlassBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kGlassBorder, width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: kGlassShadow,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const HeroSection(),
                      ),
                    ),
                  ),
                ),
              ),
              // Other sections with liquid glass
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kGlassBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kGlassBorder, width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: kGlassShadow,
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            MindfulnessHighlights(),
                            CommunitySection(),
                            PricingSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

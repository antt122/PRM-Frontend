import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/AnalyticsCard.dart';
import '../providers/PodcastFilter.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';


class PodcastStatisticsDashboard extends ConsumerWidget {
  const PodcastStatisticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tạm thời vô hiệu hóa việc gọi data
    // final statsAsync = ref.watch(podcastStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê tổng quan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // Vô hiệu hóa nút refresh
            onPressed: null,
            // onPressed: () => ref.refresh(podcastStatisticsProvider),
          ),
        ],
      ),
      // --- THAY THẾ BODY BẰNG WIDGET "COMING SOON" ---
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.bar_chart_outlined, // Icon thống kê
              size: 80,
              color: kAdminSecondaryTextColor,
            ),
            SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kAdminPrimaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tính năng này đang được phát triển.',
              style: TextStyle(
                fontSize: 16,
                color: kAdminSecondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
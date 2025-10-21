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
    final statsAsync = ref.watch(podcastStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê tổng quan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(podcastStatisticsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err')),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.'));
          }
          final stats = apiResult.data!;
          final numberFormat = NumberFormat.compact();

          final List<Widget> statCards = [
            AnalyticsCard(icon: Icons.podcasts_outlined, title: 'Tổng số Podcasts', value: numberFormat.format(stats.totalPodcasts)),
            AnalyticsCard(icon: Icons.check_circle_outline, title: 'Đã xuất bản', value: numberFormat.format(stats.publishedPodcasts), iconColor: Colors.green),
            AnalyticsCard(icon: Icons.hourglass_empty_outlined, title: 'Chờ duyệt', value: numberFormat.format(stats.pendingPodcasts), iconColor: Colors.orange),
            AnalyticsCard(icon: Icons.cancel_outlined, title: 'Đã từ chối', value: numberFormat.format(stats.rejectedPodcasts), iconColor: kAdminErrorColor),
            AnalyticsCard(icon: Icons.visibility_outlined, title: 'Tổng lượt xem', value: numberFormat.format(stats.totalViews), iconColor: Colors.cyan),
            AnalyticsCard(icon: Icons.favorite_outline, title: 'Tổng lượt thích', value: numberFormat.format(stats.totalLikes), iconColor: Colors.pink),
          ];

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 200).floor().clamp(1, 3);
              return RefreshIndicator(
                onRefresh: () => ref.refresh(podcastStatisticsProvider.future),
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: statCards,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

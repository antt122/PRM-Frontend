import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/AnalyticsCard.dart';
import 'package:intl/intl.dart';
import '../providers/PodcastFilter.dart';
import '../utils/app_colors.dart';


class PodcastAnalyticsScreen extends ConsumerWidget {
  final String podcastId;
  const PodcastAnalyticsScreen({super.key, required this.podcastId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(podcastAnalyticsProvider(podcastId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích Podcast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(podcastAnalyticsProvider(podcastId)),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err')),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.'));
          }
          final analytics = apiResult.data!;
          final numberFormat = NumberFormat.compact();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Thông tin cơ bản
              ListTile(
                title: Text(analytics.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                subtitle: Text('Tạo bởi: ${analytics.createdBy.substring(0, 8)}...'),
                trailing: Chip(label: Text(analytics.status)),
              ),
              const Divider(height: 32),

              // Grid thống kê
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = (constraints.maxWidth / 250).floor().clamp(1, 2);
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      AnalyticsCard(icon: Icons.visibility, title: 'Lượt xem', value: numberFormat.format(analytics.viewCount)),
                      AnalyticsCard(icon: Icons.favorite, title: 'Lượt thích', value: numberFormat.format(analytics.likeCount), iconColor: Colors.pink),
                      AnalyticsCard(icon: Icons.calendar_today_outlined, title: 'Ngày tạo', value: analytics.formattedCreatedAt),
                      AnalyticsCard(icon: Icons.publish_outlined, title: 'Ngày xuất bản', value: analytics.formattedPublishedAt),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Thông điệp
              if (analytics.message.isNotEmpty)
                Center(child: Text(analytics.message, style: const TextStyle(color: kAdminSecondaryTextColor, fontStyle: FontStyle.italic))),
            ],
          );
        },
      ),
    );
  }
}

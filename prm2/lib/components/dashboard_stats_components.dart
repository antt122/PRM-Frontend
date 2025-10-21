import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/creator_dashboard_stats.dart';
import '../models/podcast.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class DashboardStatsCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: kGlassShadow,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: AppFonts.caption1.copyWith(
                        color: kSecondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: Text(
                    value.toString(),
                    style: AppFonts.title2.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopPodcastsChart extends StatelessWidget {
  final List<TopPodcast> topPodcasts;

  const TopPodcastsChart({super.key, required this.topPodcasts});

  @override
  Widget build(BuildContext context) {
    if (topPodcasts.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kGlassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGlassBorder, width: 0.5),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 48, color: kSecondaryTextColor),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có dữ liệu',
                    style: AppFonts.headline.copyWith(color: kPrimaryTextColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final maxViews = topPodcasts
        .map((p) => p.viewCount)
        .reduce((a, b) => a > b ? a : b);
    final maxLikes = topPodcasts
        .map((p) => p.likeCount)
        .reduce((a, b) => a > b ? a : b);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: kGlassShadow,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: kAccentColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Top Podcast theo lượt nghe',
                    style: AppFonts.title3.copyWith(
                      color: kPrimaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...topPodcasts
                  .take(5)
                  .map(
                    (podcast) => _buildPodcastBar(podcast, maxViews, maxLikes),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastBar(TopPodcast podcast, int maxViews, int maxLikes) {
    final viewPercentage = maxViews > 0 ? (podcast.viewCount / maxViews) : 0.0;
    final likePercentage = maxLikes > 0 ? (podcast.likeCount / maxLikes) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  podcast.title,
                  style: AppFonts.caption1.copyWith(
                    color: kPrimaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '👁️ ${podcast.viewCount} • ❤️ ${podcast.likeCount}',
                style: AppFonts.caption2.copyWith(color: kSecondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Views bar
              Expanded(
                flex: 3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: kSurfaceColor,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: viewPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Likes bar
              Expanded(
                flex: 2,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: kSurfaceColor,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: likePercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MonthlyTrendChart extends StatelessWidget {
  final List<Podcast> podcasts;

  const MonthlyTrendChart({super.key, required this.podcasts});

  @override
  Widget build(BuildContext context) {
    // Generate all months from January to current month of current year
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // Create list of all months from Jan to current month
    final allMonths = <String>[];
    for (int month = 1; month <= currentMonth; month++) {
      allMonths.add('$currentYear-${month.toString().padLeft(2, '0')}');
    }

    // Group podcasts by month and calculate stats
    final Map<String, Map<String, int>> monthlyData = {};

    // Initialize all months with zero values
    for (final monthKey in allMonths) {
      monthlyData[monthKey] = {'views': 0, 'likes': 0};
    }

    // Add actual podcast data
    for (final podcast in podcasts) {
      final date = podcast.publishedAt ?? podcast.createdAt;
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      // Only include data for current year
      if (date.year == currentYear && monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey]!['views'] =
            (monthlyData[monthKey]!['views'] ?? 0) + podcast.viewCount;
        monthlyData[monthKey]!['likes'] =
            (monthlyData[monthKey]!['likes'] ?? 0) + podcast.likeCount;
      }
    }

    // Calculate max values for scaling
    final maxViews = monthlyData.values
        .map((data) => data['views'] ?? 0)
        .reduce((a, b) => a > b ? a : b);
    final maxLikes = monthlyData.values
        .map((data) => data['likes'] ?? 0)
        .reduce((a, b) => a > b ? a : b);

    // Debug logs
    print('📊 DEBUG: Monthly data: $monthlyData');
    print('📊 DEBUG: Max views: $maxViews, Max likes: $maxLikes');
    print('📊 DEBUG: kAccentColor: $kAccentColor');
    print('📊 DEBUG: Red color: ${Colors.red.shade400}');

    // Create combined scale for better visualization
    // Use the higher of the two max values as the scale for both lines
    final combinedMax = maxViews > maxLikes ? maxViews : maxLikes;
    final effectiveMax = combinedMax > 0 ? combinedMax : 1;

    print('📊 DEBUG: Combined max: $effectiveMax');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: kGlassShadow,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline, color: kAccentColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Xu hướng theo tháng ($currentYear)',
                      style: AppFonts.title3.copyWith(
                        color: kPrimaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chart area - Line Chart
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: LineChartPainter(
                    monthlyData: monthlyData,
                    allMonths: allMonths,
                    maxViews: effectiveMax,
                    maxLikes: effectiveMax,
                  ),
                  child: Container(),
                ),
              ),
              const SizedBox(height: 16),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(
                    'Lượt nghe',
                    kAccentColor,
                  ), // Đồng bộ với Top Podcast chart
                  const SizedBox(width: 24),
                  _buildLegendItem('Lượt thích', Colors.red.shade400), // Màu đỏ
                ],
              ),

              // Summary stats
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kSurfaceColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: _buildSummaryItem('Tổng lượt nghe', maxViews),
                    ),
                    Flexible(
                      child: _buildSummaryItem('Tổng lượt thích', maxLikes),
                    ),
                    Flexible(
                      child: _buildSummaryItem('Podcast', podcasts.length),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppFonts.caption2.copyWith(color: kSecondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: AppFonts.headline.copyWith(
            color: kAccentColor,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: AppFonts.caption2.copyWith(color: kSecondaryTextColor),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final Map<String, Map<String, int>> monthlyData;
  final List<String> allMonths;
  final int maxViews;
  final int maxLikes;

  LineChartPainter({
    required this.monthlyData,
    required this.allMonths,
    required this.maxViews,
    required this.maxLikes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (allMonths.isEmpty) return;

    // Debug logs
    print(
      '🎨 DEBUG: Painting chart with maxViews: $maxViews, maxLikes: $maxLikes',
    );
    print('🎨 DEBUG: Monthly data: $monthlyData');

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Calculate chart dimensions with proper margins to avoid overflow
    final chartHeight = size.height - 50; // Increased space for labels
    final chartWidth = size.width - 50; // Increased space for labels
    final stepX = chartWidth / (allMonths.length - 1);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = 25 + (chartHeight / 4) * i;
      canvas.drawLine(Offset(25, y), Offset(size.width - 25, y), gridPaint);
    }

    // Draw Views line (brown/nâu) - lượt nghe
    paint.color = kAccentColor; // Đồng bộ với Top Podcast chart
    final viewsPoints = <Offset>[];

    print('🎨 DEBUG: Drawing views line with color: ${paint.color}');

    for (int i = 0; i < allMonths.length; i++) {
      final month = allMonths[i];
      final views = monthlyData[month]!['views'] ?? 0;
      final y = 25 + chartHeight - (views / maxViews) * chartHeight;
      final x = 25 + stepX * i;
      viewsPoints.add(Offset(x, y));
      print(
        '🎨 DEBUG: Views point $month: views=$views, maxViews=$maxViews, x=$x, y=$y',
      );
    }

    // Draw line connecting points
    for (int i = 0; i < viewsPoints.length - 1; i++) {
      canvas.drawLine(viewsPoints[i], viewsPoints[i + 1], paint);
    }

    // Draw points
    pointPaint.color = kAccentColor; // Đồng bộ với Top Podcast chart
    for (final point in viewsPoints) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw Likes line (red) - lượt thích
    paint.color = Colors.red.shade400;
    final likesPoints = <Offset>[];

    print('🎨 DEBUG: Drawing likes line with color: ${paint.color}');

    for (int i = 0; i < allMonths.length; i++) {
      final month = allMonths[i];
      final likes = monthlyData[month]!['likes'] ?? 0;
      final y = 25 + chartHeight - (likes / maxLikes) * chartHeight;
      final x = 25 + stepX * i;
      likesPoints.add(Offset(x, y));
      print(
        '🎨 DEBUG: Likes point $month: likes=$likes, maxLikes=$maxLikes, x=$x, y=$y',
      );
    }

    // Draw line connecting points
    for (int i = 0; i < likesPoints.length - 1; i++) {
      canvas.drawLine(likesPoints[i], likesPoints[i + 1], paint);
    }

    // Draw points
    pointPaint.color = Colors.red.shade400;
    for (final point in likesPoints) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw month labels
    for (int i = 0; i < allMonths.length; i++) {
      final month = allMonths[i];
      final monthName = _getMonthName(month);
      final x = 25 + stepX * i;

      textPainter.text = TextSpan(
        text: monthName,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 20),
      );
    }

    // Draw Y-axis labels with proper positioning to avoid overflow
    for (int i = 0; i <= 4; i++) {
      final value = (maxViews / 4) * (4 - i);
      textPainter.text = TextSpan(
        text: value.toInt().toString(),
        style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
      );
      textPainter.layout();

      // Ensure labels don't overflow by positioning them properly
      final labelX = 2.0; // Move closer to left edge
      final labelY = 25 + (chartHeight / 4) * i - textPainter.height / 2;

      // Only paint if the label fits within bounds
      if (labelX >= 0 &&
          labelY >= 0 &&
          labelY + textPainter.height <= size.height) {
        textPainter.paint(canvas, Offset(labelX, labelY));
      }
    }
  }

  String _getMonthName(String monthKey) {
    final month = int.parse(monthKey.split('-')[1]);
    const monthNames = [
      '',
      'T1',
      'T2',
      'T3',
      'T4',
      'T5',
      'T6',
      'T7',
      'T8',
      'T9',
      'T10',
      'T11',
      'T12',
    ];
    return monthNames[month];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

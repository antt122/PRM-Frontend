import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/podcast.dart';
import '../models/podcast_category.dart';
import '../screens/podcast_detail_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;

  const PodcastCard({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PodcastDetailScreen(podcastId: podcast.id),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: kGlassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGlassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: kGlassShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: podcast.thumbnailUrl != null
                        ? Image.network(
                            podcast.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          podcast.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.caption1.copyWith(
                            color: kPrimaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 1),
                        // Host/Series
                        if (podcast.hostName != null)
                          Text(
                            podcast.hostName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.caption2.copyWith(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 2),
                        // Stats
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 8,
                              color: kSecondaryTextColor,
                            ),
                            const SizedBox(width: 1),
                            Expanded(
                              child: Text(
                                podcast.formattedViews,
                                style: AppFonts.caption2.copyWith(
                                  color: kPrimaryTextColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.access_time,
                              size: 8,
                              color: kSecondaryTextColor,
                            ),
                            const SizedBox(width: 1),
                            Expanded(
                              child: Text(
                                podcast.formattedDuration,
                                style: AppFonts.caption2.copyWith(
                                  color: kPrimaryTextColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        // Date
                        Text(
                          podcast.formattedDate,
                          style: AppFonts.caption2.copyWith(
                            color: kSecondaryTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 7,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Categories
                        if (podcast.emotionCategories.isNotEmpty ||
                            podcast.topicCategories.isNotEmpty)
                          _buildCategories(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: kGlassBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kGlassBorder, width: 0.5),
      ),
      child: const Center(
        child: Icon(Icons.headphones, size: 48, color: kPrimaryTextColor),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = <Widget>[];

    // Add emotion categories (limit to 2 to prevent overflow)
    final emotionCount = podcast.emotionCategories.length > 2
        ? 2
        : podcast.emotionCategories.length;
    for (int i = 0; i < emotionCount; i++) {
      final emotionId = podcast.emotionCategories[i];
      final emotion = EmotionCategory.fromValue(emotionId);
      if (emotion != EmotionCategory.none) {
        categories.add(
          Container(
            margin: const EdgeInsets.only(right: 1, bottom: 1),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              emotion.displayName,
              style: AppFonts.caption2.copyWith(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 6,
              ),
            ),
          ),
        );
      }
    }

    // Add topic categories (limit to 1 to prevent overflow)
    final topicCount = podcast.topicCategories.length > 1
        ? 1
        : podcast.topicCategories.length;
    for (int i = 0; i < topicCount; i++) {
      final topicId = podcast.topicCategories[i];
      final topic = TopicCategory.fromValue(topicId);
      if (topic != TopicCategory.none) {
        categories.add(
          Container(
            margin: const EdgeInsets.only(right: 1, bottom: 1),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              topic.displayName,
              style: AppFonts.caption2.copyWith(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 6,
              ),
            ),
          ),
        );
      }
    }

    if (categories.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 0, // Giảm spacing
      runSpacing: 0, // Giảm run spacing
      children: categories,
    );
  }
}

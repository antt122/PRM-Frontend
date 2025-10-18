import 'package:flutter/material.dart';
import '../models/podcast.dart';
import '../models/podcast_category.dart';
import '../screens/podcast_detail_screen.dart';

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
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      podcast.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 1),
                    // Host/Series
                    if (podcast.hostName != null)
                      Text(
                        podcast.hostName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Stats
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 1),
                        Expanded(
                          child: Text(
                            podcast.formattedViews,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 1),
                        Expanded(
                          child: Text(
                            podcast.formattedDuration,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
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
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.headphones, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = <Widget>[];

    // Add emotion categories
    for (final emotionId in podcast.emotionCategories) {
      final emotion = EmotionCategory.fromValue(emotionId);
      if (emotion != EmotionCategory.none) {
        categories.add(
          Container(
            margin: const EdgeInsets.only(right: 3, bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              emotion.displayName,
              style: TextStyle(
                fontSize: 7,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    }

    // Add topic categories
    for (final topicId in podcast.topicCategories) {
      final topic = TopicCategory.fromValue(topicId);
      if (topic != TopicCategory.none) {
        categories.add(
          Container(
            margin: const EdgeInsets.only(right: 3, bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              topic.displayName,
              style: TextStyle(
                fontSize: 7,
                color: Colors.green.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    }

    if (categories.isEmpty) return const SizedBox.shrink();

    return Wrap(children: categories);
  }
}

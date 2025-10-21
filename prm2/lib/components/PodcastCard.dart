import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/Podcast.dart';
import '../utils/app_colors.dart';


class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  const PodcastCard({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(podcast.publishedAt, locale: 'vi');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(podcast.thumbnailUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(podcast.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(podcast.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(podcast.seriesName,
                style: const TextStyle(fontSize: 12, color: kAdminSecondaryTextColor),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(Icons.visibility_outlined, podcast.viewCount),
                _buildStat(Icons.favorite_outline, podcast.likeCount),
                Text(timeAgo, style: const TextStyle(fontSize: 12, color: kAdminSecondaryTextColor)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: kAdminSecondaryTextColor),
        const SizedBox(width: 4),
        Text(count.toString(),
            style: const TextStyle(fontSize: 12, color: kAdminSecondaryTextColor)),
      ],
    );
  }
}

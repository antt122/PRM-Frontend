import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/Podcast.dart';
import '../utils/CategoryHelper.dart';
import '../utils/app_colors.dart';

class PendingPodcastCard extends StatelessWidget {
  final Podcast podcast;
  const PendingPodcastCard({super.key, required this.podcast});

  void _showActionDialog(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã ${action.toLowerCase()} podcast "${podcast.title}"'),
        backgroundColor: action == 'Duyệt' ? Colors.green : kAdminErrorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Thumbnail, Title, Series
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    podcast.thumbnailUrl.isNotEmpty ? podcast.thumbnailUrl : 'https://placehold.co/100x100/23262F/FFFFFF?text=Podcast',
                    width: 80, height: 80, fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(podcast.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(podcast.seriesName, style: const TextStyle(fontSize: 14, color: kAdminSecondaryTextColor)),
                      const SizedBox(height: 4),
                      const Chip(
                        label: Text('Pending'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: kAdminInputBorderColor),

            // Body: Host, Guest, Categories
            _buildInfoRow(Icons.mic_none_outlined, 'Host:', podcast.hostName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person_outline, 'Guest:', podcast.guestName),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6.0, runSpacing: 4.0,
              children: [
                ...podcast.emotionCategories.map((id) => Chip(label: Text(CategoryHelper.podcastEmotions[id] ?? ''))),
                ...podcast.topicCategories.map((id) => Chip(label: Text(CategoryHelper.podcastTopics[id] ?? ''))),
              ],
            ),
            const Divider(height: 24, color: kAdminInputBorderColor),

            // Footer: Stats và Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tạo ${timeago.format(podcast.publishedAt, locale: 'vi')}',
                  style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 12),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      tooltip: 'Duyệt',
                      onPressed: () => _showActionDialog(context, 'Duyệt'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.highlight_off, color: kAdminErrorColor),
                      tooltip: 'Từ chối',
                      onPressed: () => _showActionDialog(context, 'Từ chối'),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAdminSecondaryTextColor),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: kAdminSecondaryTextColor)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

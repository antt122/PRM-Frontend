import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/Story.dart';
import '../utils/CategoryHelper.dart';
import '../utils/app_colors.dart';


class StoryCard extends StatelessWidget {
  final Story story;
  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorName = story.isAnonymous ? 'Anonymous' : story.authorDisplayName;
    // Sử dụng định dạng ngắn gọn hơn, ví dụ: "5m", "2d"
    final timeAgo = timeago.format(story.publishedAt, locale: 'en_short');

    return Card( // Widget Card này sẽ tự động lấy style từ AppTheme
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Tên tác giả, Badge
            Row(
              children: [
                CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade800,
                    child: const Icon(Icons.person, size: 20, color: kAdminSecondaryTextColor)),
                const SizedBox(width: 8),
                Text(authorName,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: kAdminSecondaryTextColor)),
                const Spacer(),
                if (story.isModeratorPick)
                  Chip(
                    avatar: const Icon(Icons.star, size: 14, color: Colors.amber),
                    label: const Text('Moderator Pick'),
                    labelStyle: const TextStyle(fontSize: 10, color: Colors.amber),
                    backgroundColor: Colors.amber.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Tiêu đề
            Text(story.title,
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: kAdminPrimaryTextColor)),
            const SizedBox(height: 8),

            // Mô tả
            Text(
              story.description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: kAdminSecondaryTextColor),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Các Chip danh mục
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ...story.emotionCategories.map((id) =>
                    Chip(label: Text(CategoryHelper.emotionCategories[id] ?? ''))),
                ...story.topicCategories.map((id) =>
                    Chip(label: Text(CategoryHelper.topicCategories[id] ?? ''))),
              ],
            ),
            const Divider(height: 24, color: kAdminInputBorderColor),

            // Footer: Các chỉ số thống kê và thời gian
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStat(Icons.visibility_outlined, story.viewCount),
                    const SizedBox(width: 16),
                    _buildStat(Icons.favorite_outline, story.likeCount),
                    const SizedBox(width: 16),
                    _buildStat(Icons.chat_bubble_outline, story.commentCount),
                  ],
                ),
                Text(timeAgo,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: kAdminSecondaryTextColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAdminSecondaryTextColor),
        const SizedBox(width: 4),
        Text(count.toString(),
            style: const TextStyle(color: kAdminSecondaryTextColor)),
      ],
    );
  }
}


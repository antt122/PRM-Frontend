import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/podcast.dart';
import '../screens/podcast_detail_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class PodcastListItem extends StatelessWidget {
  final Podcast podcast;

  const PodcastListItem({super.key, required this.podcast});

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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 100,
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
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            podcast.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.title3.copyWith(
                              color: kPrimaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Host
                          if (podcast.hostName != null)
                            Text(
                              podcast.hostName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body.copyWith(
                                color: kSecondaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 8),
                          // Stats row
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 14,
                                color: kSecondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                podcast.formattedViews,
                                style: AppFonts.caption1.copyWith(
                                  color: kPrimaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: kSecondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  podcast.formattedDuration,
                                  style: AppFonts.caption1.copyWith(
                                    color: kPrimaryTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Date
                          Text(
                            podcast.formattedDate,
                            style: AppFonts.caption1.copyWith(
                              color: kSecondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
        child: Icon(Icons.headphones, size: 32, color: kPrimaryTextColor),
      ),
    );
  }
}

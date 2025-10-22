import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../screens/podcast_detail_screen.dart';
import 's3_cached_image.dart';

/// Persistent mini player that shows at bottom of screen when audio is playing
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        // Hide if no podcast is loaded
        if (!audioService.hasAudio) {
          return const SizedBox.shrink();
        }

        final podcast = audioService.currentPodcast!;

        return GestureDetector(
          onTap: () {
            // Navigate to full player (podcast detail screen)
            // Note: View tracking is handled in PodcastDetailScreen
            // We don't track view here to avoid duplicate tracking
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PodcastDetailScreen(
                  podcastId: podcast.id,
                  isCreatorView: false,
                  fromMiniPlayer: true,
                ),
              ),
            );
          },
          child: _LiquidGlassMiniPlayer(
            height: 70,
            child: Column(
              children: [
                // Progress bar
                StreamBuilder<Duration>(
                  stream: audioService.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = audioService.duration;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;

                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(
                          0xFF007AFF,
                        ), // iOS blue to match liquid glass theme
                      ),
                      minHeight: 2,
                    );
                  },
                ),

                // Player controls
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: S3CachedImage(
                            imageUrl:
                                podcast.thumbnailUrl ??
                                'https://via.placeholder.com/50',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Podcast info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                podcast.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                podcast.hostName ?? 'Unknown Host',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Play/Pause button
                        StreamBuilder<bool>(
                          stream: audioService.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => audioService.togglePlayPause(),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            );
                          },
                        ),

                        // Close button
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 18,
                          ),
                          onPressed: () => audioService.stop(),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom liquid glass container for mini player
class _LiquidGlassMiniPlayer extends StatelessWidget {
  final double height;
  final Widget child;

  const _LiquidGlassMiniPlayer({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          12,
        ), // Bo tròn nhỏ hơn như Apple Music
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25), // Blur mạnh hơn
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4), // Đậm hơn một chút
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5, // Border mỏng hơn
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

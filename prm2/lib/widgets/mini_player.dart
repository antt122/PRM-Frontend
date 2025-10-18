import 'package:flutter/material.dart';
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
            // Note: Creator restrictions (like/view) are handled in PodcastDetailScreen
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
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
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
                      backgroundColor: Colors.grey.shade800,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1DB954), // Spotify green
                      ),
                      minHeight: 2,
                    );
                  },
                ),

                // Player controls
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: S3CachedImage(
                            imageUrl: podcast.thumbnailUrl ?? 'https://via.placeholder.com/50',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.music_note, color: Colors.white54),
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
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Play/Pause button
                        StreamBuilder<bool>(
                          stream: audioService.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: () => audioService.togglePlayPause(),
                            );
                          },
                        ),

                        // Close button
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () => audioService.stop(),
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

// =====================================================
// TEMPLATE: Cập nhật podcast_detail_screen.dart
// Copy đoạn code này để replace các phần tương ứng
// =====================================================

// ========== 1. IMPORTS (Đầu file) ==========
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/podcast.dart';
import '../models/api_result.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';

// ========== 2. STATE CLASS (Xóa audio player local) ==========
class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  // ❌ XÓA: final AudioPlayer _audioPlayer = AudioPlayer();
  // ❌ XÓA: bool _isPlaying = false;
  // ❌ XÓA: Duration _duration = Duration.zero;
  // ❌ XÓA: Duration _position = Duration.zero;
  
  Podcast? _podcast;
  bool _isLoading = true;
  bool _viewTracked = false;
  bool _isLiked = false;
  bool _isLikeLoading = false;
  int _currentLikeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPodcast();
    // ❌ XÓA: _setupAudioPlayer();
  }

  // ❌ XÓA: @override void dispose() { _audioPlayer.dispose(); }
  // ❌ XÓA: void _setupAudioPlayer() { ... }
  // ❌ XÓA: Future<void> _togglePlayPause() { ... }
  // ❌ XÓA: Future<void> _seek(Duration position) { ... }

  // ========== 3. LOAD PODCAST (Thêm auto-play) ==========
  Future<void> _loadPodcast() async {
    final ApiResult<Podcast> result = widget.isCreatorView
        ? await ApiService.getCreatorPodcastById(widget.podcastId)
        : await ApiService.getPodcastById(widget.podcastId);
    
    if (mounted) {
      if (result.isSuccess && result.data != null) {
        bool isLiked = false;
        if (!widget.isCreatorView) {
          isLiked = await ApiService.checkPodcastLiked(widget.podcastId);
        }
        
        setState(() {
          _podcast = result.data;
          _isLiked = isLiked;
          _currentLikeCount = result.data!.likeCount;
          _isLoading = false;
        });
        
        // Track view
        if (!widget.isCreatorView && !_viewTracked) {
          _viewTracked = true;
          ApiService.incrementPodcastView(widget.podcastId);
        }
        
        // ✅ THÊM: Auto-play podcast
        final audioService = Provider.of<AudioPlayerService>(context, listen: false);
        if (result.data != null) {
          try {
            await audioService.playPodcast(result.data!);
          } catch (e) {
            print('Auto-play failed: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Không thể phát audio: $e')),
              );
            }
          }
        }
      } else {
        setState(() => _isLoading = false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? 'Không tìm thấy podcast')),
          );
        }
      }
    }
  }

  // ========== 4. BUILD METHOD (Wrap với Consumer) ==========
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(/* ... loading UI ... */);
    }

    if (_podcast == null) {
      return Scaffold(/* ... error UI ... */);
    }

    // ✅ THÊM: Consumer wrapper
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        final isThisPodcastPlaying = audioService.currentPodcast?.id == _podcast!.id;
        final isPlaying = isThisPodcastPlaying && audioService.isPlaying;

        return Scaffold(
          // ... existing Scaffold code ...
          body: Stack(
            children: [
              // ✅ Blurred background - Thay CustomNetworkImage → CachedNetworkImage
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(/* ... */),
                  child: _podcast!.thumbnailUrl != null
                      ? Stack(
                          children: [
                            ImageFiltered(
                              imageFilter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                              child: CachedNetworkImage(
                                imageUrl: _podcast!.thumbnailUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                httpHeaders: const {
                                  'ngrok-skip-browser-warning': 'true',
                                  'User-Agent': 'Flutter-Client',
                                },
                              ),
                            ),
                            Container(/* dark overlay */),
                          ],
                        )
                      : Container(),
                ),
              ),
              
              // Content
              CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                        child: Column(
                          children: [
                            // ✅ Album Art - Thay CustomNetworkImage → CachedNetworkImage
                            Container(
                              width: 300,
                              height: 300,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: _podcast!.thumbnailUrl ?? 'https://via.placeholder.com/300',
                                  fit: BoxFit.cover,
                                  httpHeaders: const {
                                    'ngrok-skip-browser-warning': 'true',
                                    'User-Agent': 'Flutter-Client',
                                  },
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade800,
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.white54),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey.shade800,
                                    child: const Icon(Icons.music_note, size: 100, color: Colors.white54),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Title, Host, etc.
                            Text(_podcast!.title, /* ... */),
                            if (_podcast!.hostName != null)
                              Text(_podcast!.hostName!, /* ... */),

                            const SizedBox(height: 32),

                            // ✅ Progress Bar - StreamBuilder từ audioService
                            if (isThisPodcastPlaying)
                              StreamBuilder<Duration>(
                                stream: audioService.positionStream,
                                builder: (context, snapshot) {
                                  final position = snapshot.data ?? Duration.zero;
                                  final duration = audioService.duration;

                                  return Column(
                                    children: [
                                      Slider(
                                        value: position.inSeconds.toDouble(),
                                        max: duration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          audioService.seek(Duration(seconds: value.toInt()));
                                        },
                                        activeColor: const Color(0xFF1DB954),
                                        inactiveColor: Colors.grey.shade700,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(_formatDuration(position), /* ... */),
                                            Text(_formatDuration(duration), /* ... */),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                            const SizedBox(height: 24),

                            // ✅ Play Controls - Sử dụng audioService
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Skip Backward 10s
                                IconButton(
                                  icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                                  onPressed: isThisPodcastPlaying 
                                      ? () => audioService.skipBackward() 
                                      : null,
                                ),

                                const SizedBox(width: 20),

                                // Play/Pause Button
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1DB954),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                    onPressed: () async {
                                      try {
                                        if (isThisPodcastPlaying) {
                                          await audioService.togglePlayPause();
                                        } else {
                                          await audioService.playPodcast(_podcast!);
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Lỗi: $e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(width: 20),

                                // Skip Forward 10s
                                IconButton(
                                  icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                                  onPressed: isThisPodcastPlaying 
                                      ? () => audioService.skipForward() 
                                      : null,
                                ),
                              ],
                            ),

                            // ... rest of the content (stats, description, tags) ...
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ========== 5. HELPER METHOD (Giữ nguyên) ==========
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// =====================================================
// CHECKLIST - Đảm bảo đã làm:
// =====================================================
// ✅ Import: provider, cached_network_image, audio_player_service
// ✅ Xóa: AudioPlayer local, _isPlaying, _duration, _position
// ✅ Xóa: _setupAudioPlayer(), dispose() với _audioPlayer.dispose()
// ✅ Thêm: Auto-play trong _loadPodcast()
// ✅ Wrap build với: Consumer<AudioPlayerService>
// ✅ Đổi tất cả CustomNetworkImage → CachedNetworkImage
// ✅ Đổi Progress Bar: StreamBuilder từ audioService.positionStream
// ✅ Đổi Play/Pause: audioService.togglePlayPause() / playPodcast()
// ✅ Thêm Skip buttons: audioService.skipForward() / skipBackward()
// =====================================================

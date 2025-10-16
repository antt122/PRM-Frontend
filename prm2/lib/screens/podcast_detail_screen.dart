import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/podcast.dart';
import '../models/api_result.dart';
import '../services/api_service.dart';

class PodcastDetailScreen extends StatefulWidget {
  final String podcastId;

  const PodcastDetailScreen({super.key, required this.podcastId});

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Podcast? _podcast;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _viewTracked = false;
  bool _isLiked = false;
  bool _isLikeLoading = false;
  int _currentLikeCount = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadPodcast();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadPodcast() async {
    final ApiResult<Podcast> result = await ApiService.getPodcastById(widget.podcastId);
    
    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Check if user liked this podcast
        final isLiked = await ApiService.checkPodcastLiked(widget.podcastId);
        
        setState(() {
          _podcast = result.data;
          _isLiked = isLiked;
          _currentLikeCount = result.data!.likeCount;
          _isLoading = false;
        });
        
        // Track view once
        if (!_viewTracked) {
          _viewTracked = true;
          ApiService.incrementPodcastView(widget.podcastId);
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

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _togglePlayPause() async {
    if (_podcast?.audioFileUrl == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (_position == Duration.zero) {
        await _audioPlayer.play(UrlSource(_podcast!.audioFileUrl!));
      } else {
        await _audioPlayer.resume();
      }
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;

    setState(() => _isLikeLoading = true);

    final result = await ApiService.toggleLikePodcast(widget.podcastId);

    if (mounted) {
      if (result.isSuccess) {
        setState(() {
          _isLiked = result.data ?? !_isLiked;
          _currentLikeCount += _isLiked ? 1 : -1;
          _isLikeLoading = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLiked ? '❤️ Đã thích podcast' : '💔 Đã bỏ thích'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        setState(() => _isLikeLoading = false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? 'Có lỗi xảy ra')),
          );
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF8B7355),
          title: const Text('Chi tiết Podcast', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_podcast == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF8B7355),
          title: const Text('Chi tiết Podcast', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text('Không tìm thấy podcast')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: CustomScrollView(
        slivers: [
          // App Bar with Thumbnail
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF8B7355),
            actions: [
              // Like Button
              IconButton(
                icon: _isLikeLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white,
                      ),
                onPressed: _isLikeLoading ? null : _toggleLike,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _podcast!.thumbnailUrl != null
                  ? Image.network(_podcast!.thumbnailUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade400,
                      child: const Icon(Icons.headphones, size: 100, color: Colors.white),
                    ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _podcast!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Host
                  if (_podcast!.hostName != null)
                    Text(
                      'Host: ${_podcast!.hostName}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Stats
                  Row(
                    children: [
                      Icon(Icons.play_circle_outline, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${_podcast!.formattedViews} lượt xem'),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite, size: 20, color: Colors.red.shade400),
                      const SizedBox(width: 4),
                      Text('$_currentLikeCount lượt thích'),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(_podcast!.formattedDuration),
                    ],
                  ),
                  const Divider(height: 32),
                  // Description
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _podcast!.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  if (_podcast!.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _podcast!.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.brown.shade100,
                      )).toList(),
                    ),
                  const SizedBox(height: 100), // Space for player
                ],
              ),
            ),
          ),
        ],
      ),
      // Audio Player
      bottomSheet: _buildAudioPlayer(),
    );
  }

  Widget _buildAudioPlayer() {
    if (_podcast?.audioFileUrl == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: const Center(child: Text('Không có file audio')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B7355),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text(_formatDuration(_position), style: const TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                  onChanged: (value) => _seek(Duration(seconds: value.toInt())),
                  activeColor: Colors.white,
                  inactiveColor: Colors.white38,
                ),
              ),
              Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                onPressed: () => _seek(_position - const Duration(seconds: 10)),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 64,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                onPressed: () => _seek(_position + const Duration(seconds: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

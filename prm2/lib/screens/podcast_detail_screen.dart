import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../models/api_result.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/s3_cached_image.dart';

class PodcastDetailScreen extends StatefulWidget {
  final String podcastId;
  final bool isCreatorView; // True if viewing from creator dashboard
  final bool fromMiniPlayer; // True if navigating from mini player

  const PodcastDetailScreen({
    super.key,
    required this.podcastId,
    this.isCreatorView = false,
    this.fromMiniPlayer = false,
  });

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  Podcast? _podcast;
  bool _isLoading = true;
  bool _viewTracked = false;
  bool _isLiked = false;
  bool _isLikeLoading = false;
  int _currentLikeCount = 0;
  String? _currentUserId; // Add to store current user ID

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load user profile first, then podcast data
  Future<void> _loadData() async {
    await _loadUserProfile();
    await _loadPodcast();
  }

  // Load current user profile to get userId
  Future<void> _loadUserProfile() async {
    try {
      final result = await ApiService.getUserProfile();
      if (result.isSuccess && result.data != null) {
        setState(() {
          _currentUserId = result.data!.userId; // Use userId instead of id
        });
        print(
          '🔍 DEBUG: Loaded user profile - ID: "${result.data!.id}", UserId: "${result.data!.userId}", FullName: "${result.data!.fullName}"',
        );
        print('🔍 DEBUG: User profile data: ${result.data.toString()}');
      } else {
        print('🔍 DEBUG: Failed to load user profile: ${result.message}');
        // Set a flag to prevent API calls if user profile fails
        _currentUserId = 'FAILED_TO_LOAD';
      }
    } catch (e) {
      print('🔍 DEBUG: Error loading user profile: $e');
      // Set a flag to prevent API calls if user profile fails
      _currentUserId = 'FAILED_TO_LOAD';
    }
  }

  @override
  void didUpdateWidget(PodcastDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if podcast ID changed
    if (oldWidget.podcastId != widget.podcastId) {
      setState(() {
        _podcast = null;
        _isLoading = true;
        _viewTracked = false;
      });
      _loadData(); // Use _loadData instead of just _loadPodcast
    }
  }

  Future<void> _loadPodcast() async {
    // Ensure user profile is loaded first
    if (_currentUserId == null) {
      print('🔍 DEBUG: User ID not loaded yet, loading user profile first...');
      await _loadUserProfile();
    }

    // Use creator API if viewing from creator dashboard, otherwise use user API
    final ApiResult<Podcast> result = widget.isCreatorView
        ? await ApiService.getCreatorPodcastById(widget.podcastId)
        : await ApiService.getPodcastById(widget.podcastId);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Only check likes and track views if NOT in creator view AND NOT own podcast
        // (Creator endpoints don't have these actions, and creators can't like their own podcasts)
        bool isLiked = false;
        final isOwnPodcast =
            _currentUserId != null &&
            _currentUserId != 'FAILED_TO_LOAD' &&
            _currentUserId == result.data!.createdBy;

        print(
          '🔍 DEBUG: Podcast loaded - User ID: "$_currentUserId", Created By: "${result.data!.createdBy}"',
        );
        print(
          '🔍 DEBUG: User ID type: ${_currentUserId.runtimeType}, Created By type: ${result.data!.createdBy.runtimeType}',
        );
        print(
          '🔍 DEBUG: IDs equal: ${_currentUserId == result.data!.createdBy}',
        );
        print(
          '🔍 DEBUG: isCreatorView: ${widget.isCreatorView}, isOwnPodcast: $isOwnPodcast',
        );

        if (!widget.isCreatorView &&
            !isOwnPodcast &&
            _currentUserId != null &&
            _currentUserId != 'FAILED_TO_LOAD') {
          print('🔍 DEBUG: Checking like status...');
          isLiked = await ApiService.checkPodcastLiked(widget.podcastId);
        } else {
          print(
            '🔍 DEBUG: Skipping like check - Creator view: ${widget.isCreatorView}, Own podcast: $isOwnPodcast, User ID loaded: ${_currentUserId != null}, User ID valid: ${_currentUserId != 'FAILED_TO_LOAD'}',
          );
        }

        setState(() {
          _podcast = result.data;
          _isLiked = isLiked;
          _currentLikeCount = result.data!.likeCount;
          _isLoading = false;
        });

        // Track view once (only for user view, not creator, not own podcast)
        // Track view regardless of fromMiniPlayer to ensure view is counted when user opens detail screen
        if (!widget.isCreatorView &&
            !isOwnPodcast &&
            !widget.fromMiniPlayer &&
            !_viewTracked &&
            _currentUserId != null &&
            _currentUserId != 'FAILED_TO_LOAD') {
          print('🔍 DEBUG: Tracking view for podcast ${widget.podcastId}');
          _viewTracked = true;
          ApiService.incrementPodcastView(widget.podcastId);
        } else {
          print(
            '🔍 DEBUG: Skipping view tracking - Creator view: ${widget.isCreatorView}, Own podcast: $isOwnPodcast, Already tracked: $_viewTracked, User ID loaded: ${_currentUserId != null}, User ID valid: ${_currentUserId != 'FAILED_TO_LOAD'}',
          );
        }

        // ✅ Auto-play podcast ONLY if not already playing this podcast
        final audioService = Provider.of<AudioPlayerService>(
          context,
          listen: false,
        );
        if (result.data != null) {
          // Check if this podcast is already playing
          final isAlreadyPlaying =
              audioService.currentPodcast?.id == result.data!.id;

          if (!isAlreadyPlaying) {
            // Different podcast - STOP old one first, then play new one
            try {
              // ✅ IMPORTANT: Stop current audio before playing new podcast
              if (audioService.hasAudio) {
                await audioService.pause();
                print('🛑 Stopped old podcast before playing new one');
              }

              await audioService.playPodcast(result.data!);
            } catch (e) {
              print('Auto-play failed: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể phát audio: $e')),
                );
              }
            }
          } else {
            print('✅ Podcast already playing, skipping auto-play');
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

  Future<void> _toggleLike() async {
    // Creator cannot like their own podcasts
    final isOwnPodcast =
        _currentUserId != null &&
        _currentUserId != 'FAILED_TO_LOAD' &&
        _podcast != null &&
        _currentUserId == _podcast!.createdBy;

    if (widget.isCreatorView || isOwnPodcast) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không thể thích podcast của chính mình'),
        ),
      );
      return;
    }

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
              content: Text(
                _isLiked ? '❤️ Đã thích podcast' : '💔 Đã bỏ thích',
              ),
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
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1a1a1a), Color(0xFF0a0a0a)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_podcast == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1a1a1a), Color(0xFF0a0a0a)],
            ),
          ),
          child: const Center(
            child: Text(
              'Không tìm thấy podcast',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // ✅ Wrap với Consumer để access AudioPlayerService
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        final isThisPodcastPlaying =
            audioService.currentPodcast?.id == _podcast!.id;
        final isPlaying = isThisPodcastPlaying && audioService.isPlaying;

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.black26,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Now Playing',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            centerTitle: true,
            actions: [
              // Like Button (hidden in creator view and for own podcasts)
              Builder(
                builder: (context) {
                  final isOwnPodcast =
                      _currentUserId != null &&
                      _currentUserId != 'FAILED_TO_LOAD' &&
                      _podcast != null &&
                      _currentUserId == _podcast!.createdBy;
                  if (widget.isCreatorView || isOwnPodcast) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: _isLikeLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : Colors.white,
                              size: 24,
                            ),
                      onPressed: _isLikeLoading ? null : _toggleLike,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Blurred Background with Dark Overlay (like Next.js)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1a1a1a).withOpacity(0.95),
                        const Color(0xFF0a0a0a),
                      ],
                    ),
                  ),
                  child: _podcast!.thumbnailUrl != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Blurred background image
                            ImageFiltered(
                              imageFilter: ui.ImageFilter.blur(
                                sigmaX: 15,
                                sigmaY: 15,
                              ),
                              child: Transform.scale(
                                scale: 1.2,
                                child: S3CachedImage(
                                  imageUrl: _podcast!.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Dark gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.88),
                                    Colors.black.withOpacity(0.85),
                                    Colors.black.withOpacity(0.92),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ),
              ),
              // Content
              CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Podcast Artwork (like Next.js)
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: _podcast!.thumbnailUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: S3CachedImage(
                                          imageUrl: _podcast!.thumbnailUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(32),
                                                  color: Colors.grey.shade800,
                                                ),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white54,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(32),
                                                  gradient:
                                                      const LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xFFFBE7BA),
                                                          Color(0xFFD0BF98),
                                                          Color(0xFFB99B5C),
                                                        ],
                                                      ),
                                                ),
                                                child: const Icon(
                                                  Icons.headphones,
                                                  size: 80,
                                                  color: Colors.white30,
                                                ),
                                              ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFFBE7BA),
                                              Color(0xFFD0BF98),
                                              Color(0xFFB99B5C),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.headphones,
                                          size: 80,
                                          color: Colors.white30,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 40),
                              // Title
                              Text(
                                _podcast!.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Host Info (like Next.js style)
                              if (_podcast!.hostName != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _podcast!.hostName!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_podcast!.guestName != null)
                                          Text(
                                            'Khách mời: ${_podcast!.guestName}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              // Stats
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Views
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_podcast!.viewCount} lượt xem',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  // Like Button (only show if not own podcast)
                                  Builder(
                                    builder: (context) {
                                      final isOwnPodcast =
                                          _currentUserId != null &&
                                          _currentUserId != 'FAILED_TO_LOAD' &&
                                          _podcast != null &&
                                          _currentUserId == _podcast!.createdBy;

                                      if (isOwnPodcast) {
                                        // Show like count without button for own podcasts
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.favorite,
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '$_currentLikeCount',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return GestureDetector(
                                        onTap: _toggleLike,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _isLiked
                                                ? Colors.red
                                                : Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                _isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: _isLiked
                                                    ? Colors.white
                                                    : Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '$_currentLikeCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Progress Bar with StreamBuilder
                              if (isThisPodcastPlaying)
                                StreamBuilder<Duration>(
                                  stream: audioService.positionStream,
                                  builder: (context, snapshot) {
                                    final position =
                                        snapshot.data ?? Duration.zero;
                                    final duration = audioService.duration;

                                    return Column(
                                      children: [
                                        Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              // Progress fill
                                              Container(
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFFFBE7BA),
                                                          Color(0xFFD0BF98),
                                                        ],
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                width: duration.inSeconds > 0
                                                    ? (position.inSeconds /
                                                              duration
                                                                  .inSeconds) *
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.8
                                                    : 0,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Time display
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDuration(position),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(duration),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              const SizedBox(height: 40),
                              // Player Controls (like Next.js)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Rewind 10s
                                  GestureDetector(
                                    onTap: () => audioService.skipBackward(),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      child: const Icon(
                                        Icons.replay_10,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Play/Pause (Main button)
                                  GestureDetector(
                                    onTap: () => audioService.togglePlayPause(),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFFBE7BA),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFFBE7BA,
                                            ).withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: const Color(0xFF604B3B),
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Forward 10s
                                  GestureDetector(
                                    onTap: () => audioService.skipForward(),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      child: const Icon(
                                        Icons.forward_10,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // Description
                              if (_podcast!.description.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Mô tả',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _podcast!.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }, // Consumer builder
    ); // Consumer
  }
}

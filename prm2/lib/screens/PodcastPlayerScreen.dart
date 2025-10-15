import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/api_result.dart';
import '../models/post_detail.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart'; // Import file màu sắc của bạn

class PodcastPlayerScreen extends StatefulWidget {
  final String postId;
  const PodcastPlayerScreen({super.key, required this.postId});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  final ApiService _apiService = ApiService();
  late Future<ApiResult<PostDetail>> _postDetailFuture;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late final List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    _postDetailFuture = _apiService.getPostDetails(widget.postId);

    _subscriptions = [
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
      }),
      _audioPlayer.onDurationChanged.listen((newDuration) {
        if (mounted) setState(() => _duration = newDuration);
      }),
      _audioPlayer.onPositionChanged.listen((newPosition) {
        if (mounted) setState(() => _position = newPosition);
      }),
    ];
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: kPrimaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: kPrimaryTextColor),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<ApiResult<PostDetail>>(
        future: _postDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAccentColor));
          }
          if (!snapshot.hasData || !snapshot.data!.isSuccess) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.data?.message ?? "Không rõ"}', style: const TextStyle(color: kSecondaryTextColor)));
          }
          final post = snapshot.data!.data!;

          if (_audioPlayer.source == null) {
            _audioPlayer.setSourceUrl(post.audioUrl);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      post.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: kCardBackgroundColor, child: const Icon(Icons.music_note, size: 80, color: kSecondaryTextColor)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title and HostName
                Text(post.title, style: const TextStyle(color: kPrimaryTextColor, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                if (post.hostName != null && post.hostName!.isNotEmpty)
                  Text(post.hostName!, style: const TextStyle(color: kSecondaryTextColor, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),

                const Spacer(),

                // Seek Bar
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    activeTrackColor: kPrimaryTextColor,
                    inactiveTrackColor: kSecondaryTextColor.withOpacity(0.5),
                    thumbColor: kPrimaryTextColor,
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position), style: const TextStyle(color: kSecondaryTextColor)),
                      Text(_formatDuration(_duration), style: const TextStyle(color: kSecondaryTextColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Player Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(Icons.shuffle, color: kSecondaryTextColor, size: 28), onPressed: (){}),
                    IconButton(icon: const Icon(Icons.skip_previous, color: kPrimaryTextColor, size: 40), onPressed: (){}),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: kAccentColor,
                        size: 70,
                      ),
                      onPressed: () async {
                        if (_isPlaying) {
                          await _audioPlayer.pause();
                        } else {
                          await _audioPlayer.resume();
                        }
                      },
                    ),
                    IconButton(icon: const Icon(Icons.skip_next, color: kPrimaryTextColor, size: 40), onPressed: (){}),
                    IconButton(icon: const Icon(Icons.repeat, color: kSecondaryTextColor, size: 28), onPressed: (){}),
                  ],
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}


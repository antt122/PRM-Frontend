import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/dialogs/ModerationDialogs.dart';
import '../models/PodcastDetail.dart';
import '../providers/PodcastFilter.dart';
import '../utils/CategoryHelper.dart';
import '../utils/app_colors.dart';
import 'PodcastAnalyticsScreen.dart';



class PodcastDetailAdminScreen extends ConsumerStatefulWidget {
  final String podcastId;
  const PodcastDetailAdminScreen({super.key, required this.podcastId});

  @override
  ConsumerState<PodcastDetailAdminScreen> createState() => _PodcastDetailAdminScreenState();
}

class _PodcastDetailAdminScreenState extends ConsumerState<PodcastDetailAdminScreen> {
  bool _isProcessing = false;

  // --- Logic xử lý các hành động (giữ nguyên) ---
  Future<void> _onApprove(PodcastDetail podcast) async {
    final notes = await showApproveRejectDialog(context, isApproving: true);
    if (notes == null) return;
    _performAction(() => ref.read(podcastServiceProvider).approvePodcast(podcast.id, notes: notes));
  }

  Future<void> _onReject(PodcastDetail podcast) async {
    final reason = await showApproveRejectDialog(context, isApproving: false);
    if (reason == null) return;
    _performAction(() => ref.read(podcastServiceProvider).rejectPodcast(podcast.id, reason: reason));
  }

  Future<void> _onDelete(PodcastDetail podcast) async {
    final confirm = await showDeleteConfirmDialog(context, podcast.title);
    if (confirm != true) return;
    _performAction(() => ref.read(podcastServiceProvider).deletePodcast(podcast.id));
  }

  Future<void> _performAction(Future<dynamic> Function() action) async {
    setState(() => _isProcessing = true);
    final result = await action();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message ?? (result.isSuccess ? 'Thao tác thành công!' : 'Lỗi')),
        backgroundColor: result.isSuccess ? Colors.green : kAdminErrorColor,
      ));
      if (result.isSuccess) Navigator.pop(context, true);
    }
    setState(() => _isProcessing = false);
  }

  // --- Giao diện chính ---
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(podcastDetailProvider(widget.podcastId));

    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err', style: const TextStyle(color: kAdminSecondaryTextColor))),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Không tìm thấy podcast.', style: const TextStyle(color: kAdminSecondaryTextColor)));
          }
          final podcast = apiResult.data!;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, podcast),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, podcast),
                          const Divider(height: 32, color: kAdminInputBorderColor),
                          _AudioPlayerWidget(audioUrl: podcast.audioUrl),
                          const Divider(height: 32, color: kAdminInputBorderColor),
                          _buildSectionTitle('Mô tả'),
                          Text(podcast.description, style: const TextStyle(height: 1.5, color: kAdminSecondaryTextColor)),
                          const Divider(height: 32, color: kAdminInputBorderColor),
                          _buildSectionTitle('Cảm xúc & Chủ đề'),
                          _buildChipWrap([...podcast.emotionCategories.map((id) => CategoryHelper.podcastEmotions[id] ?? ''),
                            ...podcast.topicCategories.map((id) => CategoryHelper.podcastTopics[id] ?? '')]),
                          // Tăng khoảng trống để không bị che khuất ngay cả khi action bar không hiển thị
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (podcast.contentStatus == 0 || podcast.contentStatus == 3)
                Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: _buildActionBar(podcast)
                )
            ],
          );
        },
      ),
    );
  }

  // --- CÁC WIDGET GIAO DIỆN (ĐÃ CẬP NHẬT ĐẦY ĐỦ) ---

  SliverAppBar _buildSliverAppBar(BuildContext context, PodcastDetail podcast) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: kAdminBackgroundColor,
      iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
        title: Text(podcast.title, style: const TextStyle(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
                podcast.thumbnailUrl.isNotEmpty ? podcast.thumbnailUrl : 'https://placehold.co/600x600/23262F/FFFFFF?text=Podcast',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: kAdminCardColor)
            ),
            Container(decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, kAdminBackgroundColor.withOpacity(0.9)],
              stops: const [0.5, 1.0],
            ))),
          ],
        ),
      ),
      actions: [
        if (podcast.contentStatus == 0 || podcast.contentStatus == 3)
          Center(child: Chip(label: const Text('Pending Review'), backgroundColor: Colors.orange.withOpacity(0.2), labelStyle: const TextStyle(color: Colors.orange))),

        // --- THÊM NÚT XEM PHÂN TÍCH Ở ĐÂY ---
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          tooltip: 'Xem phân tích',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PodcastAnalyticsScreen(podcastId: podcast.id),
              ),
            );
          },
        ),

        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _onDelete(podcast);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: kAdminErrorColor),
                title: Text('Xóa vĩnh viễn', style: TextStyle(color: kAdminErrorColor)),
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert, color: kAdminSecondaryTextColor),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionBar(PodcastDetail podcast){
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
          color: kAdminCardColor,
          border: Border(top: BorderSide(color: kAdminInputBorderColor.withOpacity(0.5))),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: -5)
          ]
      ),
      child: _isProcessing
          ? const Center(heightFactor: 1.5, child: CircularProgressIndicator(color: kAdminAccentColor))
          : Row(
        children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => _onApprove(podcast), icon: const Icon(Icons.check), label: const Text('Duyệt'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(onPressed: () => _onReject(podcast), icon: const Icon(Icons.close), label: const Text('Từ chối'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)))),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PodcastDetail podcast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(podcast.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: kAdminPrimaryTextColor)),
        const SizedBox(height: 8),
        Text('${podcast.seriesName} • Tập ${podcast.episodeNumber}', style: const TextStyle(fontSize: 18, color: kAdminSecondaryTextColor)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoChip(Icons.mic_none_outlined, podcast.hostName),
            const SizedBox(width: 16),
            _buildInfoChip(Icons.person_outline, podcast.guestName),
            const Spacer(),
            _buildInfoChip(Icons.timer_outlined, podcast.duration),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(Icons.visibility_outlined, NumberFormat.compact().format(podcast.viewCount)),
            const SizedBox(width: 16),
            _buildInfoChip(Icons.favorite_outline, NumberFormat.compact().format(podcast.likeCount)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAdminPrimaryTextColor)),
    );
  }

  Widget _buildChipWrap(List<String> items) {
    if (items.isEmpty) return const Text('Không có.', style: TextStyle(color: kAdminSecondaryTextColor));
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: items.map((item) => Chip(label: Text(item))).toList(),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 18, color: kAdminSecondaryTextColor),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 14)),
    ]);
  }
}

class _AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const _AudioPlayerWidget({required this.audioUrl});
  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late final List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    if (widget.audioUrl.isNotEmpty) {
      _audioPlayer.setSourceUrl(widget.audioUrl);
    }
    _subscriptions = [
      _audioPlayer.onPlayerStateChanged.listen((s) => setState(() => _isPlaying = s == PlayerState.playing)),
      _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d)),
      _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p)),
    ];
  }

  @override
  void dispose() {
    for (final s in _subscriptions) { s.cancel(); }
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final parts = d.toString().split('.').first.split(':');
    return '${parts[1]}:${parts[2]}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl.isEmpty) {
      return const Center(child: Text('Không có file audio 🎧', style: TextStyle(color: kAdminSecondaryTextColor)));
    }
    return Column(
      children: [
        Slider(
          min: 0, max: _duration.inSeconds.toDouble(),
          value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
          onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
          activeColor: kAdminAccentColor,
          inactiveColor: kAdminInputBorderColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position), style: const TextStyle(color: kAdminSecondaryTextColor)),
              Text(_formatDuration(_duration), style: const TextStyle(color: kAdminSecondaryTextColor))
            ],
          ),
        ),
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 64, color: kAdminAccentColor),
          onPressed: () => _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume(),
        ),
      ],
    );
  }
}


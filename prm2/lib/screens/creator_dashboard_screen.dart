import 'package:flutter/material.dart';
import 'package:prm2/screens/create_postcard_screen.dart';
import '../models/podcast.dart';
import '../models/pagination_result.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/layout_with_mini_player.dart';
import '../widgets/s3_cached_image.dart';
import 'podcast_detail_screen.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  late Future<PaginationResult<Podcast>> _podcastsFuture;
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadPodcasts();
  }

  void _loadPodcasts() {
    setState(() {
      _podcastsFuture = ApiService.getMyPodcasts(
        page: _currentPage,
        pageSize: _pageSize,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWithMiniPlayer(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Quản lý Podcast của tôi',
          style: TextStyle(color: kPrimaryTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to create podcast screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PodcastUploadScreen(),
            ),
          );

          // Refresh podcasts list if creation was successful
          if (result == true) {
            _loadPodcasts();
          }
        },
        backgroundColor: kAccentColor,
        child: const Icon(Icons.add, color: kPrimaryTextColor),
      ),
      child: FutureBuilder<PaginationResult<Podcast>>(
        future: _podcastsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryTextColor),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Không thể tải dữ liệu'),
            );
          }

          final result = snapshot.data!;

          if (!result.isSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải podcast',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      result.message ?? 'Vui lòng thử lại sau',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  if (result.errorCode == '404') ...[
                    const SizedBox(height: 16),
                    const Text(
                      '⚠️ Backend endpoint not found',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                    const Text(
                      'Check: /api/creator/podcasts/my-podcasts',
                      style: TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadPodcasts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final podcasts = result.items;

          if (podcasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_none, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có podcast nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy tạo podcast đầu tiên của bạn!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh sách podcasts
          return Column(
            children: [
              // Header with total count
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black12,
                child: Row(
                  children: [
                    const Icon(Icons.podcasts, color: kAccentColor),
                    const SizedBox(width: 8),
                    Text(
                      'Tổng số: ${result.totalItems} podcast',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Podcast list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) {
                    return _buildPodcastCard(podcasts[index]);
                  },
                ),
              ),

              // Pagination controls
              if (result.totalPages > 1)
                _buildPaginationControls(result),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodcastCard(Podcast podcast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodcastDetailScreen(
                podcastId: podcast.id,
                isCreatorView: true,  // ✅ This is creator viewing their own podcast
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: S3CachedImage(
                imageUrl: podcast.thumbnailUrl ?? 'https://via.placeholder.com/120',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white54,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.podcasts, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      podcast.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Series name
                    if (podcast.seriesName?.isNotEmpty ?? false)
                      Text(
                        '📻 ${podcast.seriesName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Stats
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${podcast.viewCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.favorite, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${podcast.likeCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Duration and Status
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: kAccentColor),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(podcast.duration),
                          style: const TextStyle(
                            fontSize: 12,
                            color: kAccentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(podcast.contentStatus),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            podcast.contentStatusDisplay,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Categories if available
                    if (podcast.emotionCategoryNames.isNotEmpty || podcast.topicCategoryNames.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            ...podcast.emotionCategoryNames.take(2).map(
                              (name) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  name,
                                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                                ),
                              ),
                            ),
                            ...podcast.topicCategoryNames.take(2).map(
                              (name) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  name,
                                  style: const TextStyle(fontSize: 10, color: Colors.green),
                                ),
                              ),
                            ),
                          ],
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
  }

  Widget _buildPaginationControls(PaginationResult<Podcast> result) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: result.hasPrevious
                ? () {
                    setState(() {
                      _currentPage--;
                      _loadPodcasts();
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Trang $_currentPage / ${result.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: result.hasNext
                ? () {
                    setState(() {
                      _currentPage++;
                      _loadPodcasts();
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return Colors.grey;
      case 'PendingReview':
      case 'PendingModeration':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Published':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Archived':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}

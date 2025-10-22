import 'package:flutter/material.dart';
import 'dart:ui';
import 'create_postcard_screen.dart';
import '../models/podcast.dart';
import '../models/pagination_result.dart';
import '../models/creator_dashboard_stats.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';
import '../widgets/s3_cached_image.dart';
import '../widgets/mini_player.dart';
import '../components/dashboard_stats_components.dart';
import '../components/dashboard_filters.dart';
import '../models/api_result.dart';
import '../models/podcast_category.dart';
import 'podcast_detail_screen.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

enum DashboardTab { myPodcasts, upload, statistics }

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen>
    with TickerProviderStateMixin {
  late Future<PaginationResult<Podcast>> _podcastsFuture;
  late Future<ApiResult<CreatorDashboardStats>> _statsFuture;
  late TabController _tabController;

  int _currentPage = 1;
  final int _pageSize = 20;

  // Filter states
  String _searchTerm = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _seriesFilter = '';
  PodcastCategoryFilter? _selectedEmotionFilter;
  PodcastCategoryFilter? _selectedTopicFilter;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
    _loadPodcasts();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPodcasts() {
    setState(() {
      _podcastsFuture = ApiService.getMyPodcasts(
        page: _currentPage,
        pageSize: _pageSize,
      );
    });
  }

  void _loadStats() {
    setState(() {
      _statsFuture = ApiService.getCreatorDashboardStats();
    });
  }

  Future<void> _onRefresh() async {
    // Refresh based on current tab
    switch (_tabController.index) {
      case 0: // My Podcasts
        _currentPage = 1;
        _loadPodcasts();
        await _podcastsFuture;
        break;
      case 1: // Upload
        _loadStats();
        await _statsFuture;
        break;
      case 2: // Statistics
        _loadStats();
        await _statsFuture;
        break;
      default:
        break;
    }
  }

  List<Podcast> _getFilteredPodcasts(List<Podcast> podcasts) {
    return podcasts.where((podcast) {
      // Search filter
      if (_searchTerm.isNotEmpty &&
          !podcast.title.toLowerCase().contains(_searchTerm.toLowerCase())) {
        return false;
      }

      // Series filter
      if (_seriesFilter.isNotEmpty &&
          !(podcast.seriesName ?? '').toLowerCase().contains(
            _seriesFilter.toLowerCase(),
          )) {
        return false;
      }

      // Emotion filter
      if (_selectedEmotionFilter != null) {
        final hasEmotion = podcast.emotionCategories.contains(
          _selectedEmotionFilter!.value,
        );
        if (!hasEmotion) return false;
      }

      // Topic filter
      if (_selectedTopicFilter != null) {
        final hasTopic = podcast.topicCategories.contains(
          _selectedTopicFilter!.value,
        );
        if (!hasTopic) return false;
      }

      // Date filters
      final podcastDate = podcast.publishedAt ?? podcast.createdAt;
      if (_startDate != null && podcastDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null &&
          podcastDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: Text(
            'Quản lý nội dung',
            style: AppFonts.title2.copyWith(color: kPrimaryTextColor),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: kGlassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGlassBorder, width: 0.5),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color:
                    (_selectedEmotionFilter != null ||
                        _selectedTopicFilter != null ||
                        _searchTerm.isNotEmpty ||
                        _startDate != null ||
                        _endDate != null ||
                        _seriesFilter.isNotEmpty)
                    ? kAccentColor
                    : kPrimaryTextColor,
              ),
              onPressed: () {
                setState(() => _showFilters = !_showFilters);
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: kGlassBackground,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: kGlassBorder, width: 0.5),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: kAccentColor,
                    labelColor: kPrimaryTextColor,
                    unselectedLabelColor: kSecondaryTextColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: const [
                      Tab(icon: Icon(Icons.podcasts), text: 'Podcast của tôi'),
                      Tab(icon: Icon(Icons.upload), text: 'Tải lên'),
                      Tab(icon: Icon(Icons.analytics), text: 'Thống kê'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton:
          () {
            print(
              '🔍 DEBUG: Tab index: ${_tabController.index}, Upload tab index: 1',
            );
            return _tabController.index == 1; // Upload tab is at index 1
          }()
          ? Container(
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kAccentColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kGlassBorder, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
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
                          _loadStats();
                        }
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: const Icon(Icons.add, color: kPrimaryTextColor),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                top: 150,
              ), // Space for AppBar + TabBar
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyPodcastsTab(),
                  _buildUploadTab(),
                  _buildStatisticsTab(),
                ],
              ),
            ),
          ),
          // Mini player at bottom (shows when audio is playing)
          const MiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildMyPodcastsTab() {
    return FutureBuilder<PaginationResult<Podcast>>(
      future: _podcastsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryTextColor),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Không thể tải dữ liệu'));
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
        final filteredPodcasts = _getFilteredPodcasts(podcasts);

        if (podcasts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_none, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Bạn chưa có podcast nào',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

        return Column(
          children: [
            // Filters - chỉ hiển thị khi _showFilters = true
            if (_showFilters)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: DashboardFilters(
                  searchTerm: _searchTerm,
                  startDate: _startDate,
                  endDate: _endDate,
                  seriesFilter: _seriesFilter,
                  onSearchChanged: (value) =>
                      setState(() => _searchTerm = value),
                  onStartDateChanged: (value) =>
                      setState(() => _startDate = value),
                  onEndDateChanged: (value) => setState(() => _endDate = value),
                  onSeriesFilterChanged: (value) =>
                      setState(() => _seriesFilter = value),
                  onEmotionFilterChanged: (value) =>
                      setState(() => _selectedEmotionFilter = value),
                  onTopicFilterChanged: (value) =>
                      setState(() => _selectedTopicFilter = value),
                ),
              ),

            // Header with total count
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kGlassBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kGlassBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.podcasts, color: kAccentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Tổng số: ${result.totalItems} podcast (${filteredPodcasts.length} sau lọc)',
                          style: AppFonts.headline.copyWith(
                            color: kPrimaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Podcast list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: kPrimaryTextColor,
                backgroundColor: Colors.black54,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPodcasts.length,
                  itemBuilder: (context, index) {
                    return _buildPodcastCard(filteredPodcasts[index]);
                  },
                ),
              ),
            ),

            // Pagination controls
            if (result.totalPages > 1) _buildPaginationControls(result),
          ],
        );
      },
    );
  }

  Widget _buildUploadTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kBackgroundColor, kSurfaceColor],
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: kGlassBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGlassBorder, width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload, size: 80, color: kAccentColor),
                  const SizedBox(height: 16),
                  Text(
                    'Tải lên podcast mới',
                    style: AppFonts.title2.copyWith(
                      color: kPrimaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sử dụng nút + ở góc dưới để tạo podcast',
                    style: AppFonts.body.copyWith(color: kSecondaryTextColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return FutureBuilder<ApiResult<CreatorDashboardStats>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryTextColor),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.isSuccess) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải thống kê',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.data?.message ?? 'Vui lòng thử lại sau',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadStats,
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

        final stats = snapshot.data!.data!;

        return FutureBuilder<PaginationResult<Podcast>>(
          future: _podcastsFuture,
          builder: (context, podcastsSnapshot) {
            // Wait for both futures to complete
            if (podcastsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryTextColor),
              );
            }

            final podcasts =
                podcastsSnapshot.hasData && podcastsSnapshot.data!.isSuccess
                ? podcastsSnapshot.data!.items
                : <Podcast>[];

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: kPrimaryTextColor,
              backgroundColor: Colors.black54,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        DashboardStatsCard(
                          title: 'Tổng podcast',
                          value: stats.totalPodcasts,
                          icon: Icons.podcasts,
                          color: kAccentColor,
                        ),
                        DashboardStatsCard(
                          title: 'Đã xuất bản',
                          value: stats.publishedPodcasts,
                          icon: Icons.published_with_changes,
                          color: Colors.green,
                        ),
                        DashboardStatsCard(
                          title: 'Chờ duyệt',
                          value: stats.pendingPodcasts,
                          icon: Icons.schedule,
                          color: Colors.orange,
                        ),
                        DashboardStatsCard(
                          title: 'Tổng lượt nghe',
                          value: stats.totalViews,
                          icon: Icons.visibility,
                          color: Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Charts
                    TopPodcastsChart(topPodcasts: stats.topPodcasts),

                    const SizedBox(height: 16),

                    MonthlyTrendChart(podcasts: podcasts),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPodcastCard(Podcast podcast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PodcastDetailScreen(
                      podcastId: podcast.id,
                      isCreatorView: true,
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
                      imageUrl:
                          podcast.thumbnailUrl ??
                          'https://via.placeholder.com/120',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: kSurfaceColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryTextColor,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: kSurfaceColor,
                          child: const Icon(
                            Icons.podcasts,
                            size: 40,
                            color: kSecondaryTextColor,
                          ),
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
                            style: AppFonts.headline.copyWith(
                              color: kPrimaryTextColor,
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
                              style: AppFonts.caption1.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Stats
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 14,
                                color: kSecondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${podcast.viewCount}',
                                style: AppFonts.caption1.copyWith(
                                  color: kPrimaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.favorite,
                                size: 14,
                                color: kSecondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${podcast.likeCount}',
                                style: AppFonts.caption1.copyWith(
                                  color: kPrimaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Duration and Status
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: kAccentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(podcast.duration),
                                style: AppFonts.caption1.copyWith(
                                  color: kAccentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(podcast.contentStatus),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  podcast.contentStatusDisplay,
                                  style: AppFonts.caption2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Categories if available
                          if (podcast.emotionCategoryNames.isNotEmpty ||
                              podcast.topicCategoryNames.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  ...podcast.emotionCategoryNames
                                      .take(2)
                                      .map(
                                        (name) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kPrimaryColor.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Text(
                                            name,
                                            style: AppFonts.caption2.copyWith(
                                              color: kPrimaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ...podcast.topicCategoryNames
                                      .take(2)
                                      .map(
                                        (name) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kSecondaryColor.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Text(
                                            name,
                                            style: AppFonts.caption2.copyWith(
                                              color: kPrimaryTextColor,
                                            ),
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
          ),
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

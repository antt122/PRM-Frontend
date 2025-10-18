import 'dart:async';
import 'package:flutter/material.dart';
import '../models/podcast.dart';
import '../models/podcast_category.dart';
import '../models/pagination_result.dart';
import '../services/api_service.dart';
import '../components/podcast_card.dart';
import '../components/podcast_list_item.dart';
import '../widgets/layout_with_mini_player.dart';

class PodcastListScreen extends StatefulWidget {
  const PodcastListScreen({super.key});

  @override
  State<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends State<PodcastListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  PaginationResult<Podcast>? _trendingPodcasts;
  PaginationResult<Podcast>? _latestPodcasts;
  PaginationResult<Podcast>? _searchResults;
  List<Podcast> _aiRecommendations = [];

  List<PodcastCategoryFilter> _emotionFilters = [];
  List<PodcastCategoryFilter> _topicFilters = [];
  PodcastCategoryFilter? _selectedEmotionFilter;
  PodcastCategoryFilter? _selectedTopicFilter;
  bool _showFilters = false;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _trendingPage = 1;
  int _latestPage = 1;
  int _searchPage = 1;
  String _searchKeyword = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _emotionFilters = PodcastCategoryFilter.getEmotionFilters();
    _topicFilters = PodcastCategoryFilter.getTopicFilters();

    // Add tab change listener
    _tabController.addListener(_onTabChanged);

    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Tab is changing, load data for new tab
      _loadDataForCurrentTab();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    print('🔍 DEBUG: Loading initial data for tab ${_tabController.index}...');

    // Only load data for the current tab
    await _loadDataForCurrentTab();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDataForCurrentTab() async {
    final currentTab = _tabController.index;

    switch (currentTab) {
      case 0: // Trending
        if (_trendingPodcasts == null) {
          print('🔍 DEBUG: Loading trending podcasts...');
          final trending = await ApiService.getTrendingPodcasts(
            page: 1,
            pageSize: 10,
          );
          print(
            '🔍 DEBUG: Trending result - Success: ${trending.isSuccess}, Items: ${trending.items.length}',
          );
          if (trending.items.isNotEmpty) {
            print(
              '🔍 DEBUG: First trending podcast: "${trending.items.first.title}"',
            );
          }
          if (mounted) {
            setState(() => _trendingPodcasts = trending);
          }
        }
        break;

      case 1: // Latest
        if (_latestPodcasts == null) {
          print('🔍 DEBUG: Loading latest podcasts...');
          final latest = await ApiService.getLatestPodcasts(
            page: 1,
            pageSize: 10,
          );
          print(
            '🔍 DEBUG: Latest result - Success: ${latest.isSuccess}, Items: ${latest.items.length}',
          );
          if (latest.items.isNotEmpty) {
            print(
              '🔍 DEBUG: First latest podcast: "${latest.items.first.title}"',
            );
          }
          if (mounted) {
            setState(() => _latestPodcasts = latest);
          }
        }
        break;

      case 2: // AI Recommendations
        if (_aiRecommendations.isEmpty) {
          print('🔍 DEBUG: Loading AI recommendations...');
          final aiRecommendations = await _loadAIRecommendations();
          print(
            '🔍 DEBUG: AI Recommendations - Items: ${aiRecommendations.length}',
          );
          if (aiRecommendations.isNotEmpty) {
            print(
              '🔍 DEBUG: First AI recommendation: "${aiRecommendations.first.title}"',
            );
          }
          if (mounted) {
            setState(() => _aiRecommendations = aiRecommendations);
          }
        }
        break;

      case 3: // Search
        // Search tab - always load data (all podcasts if no keyword)
        if (_searchResults == null) {
          await _loadSearchData();
        }
        break;
    }
  }

  Future<List<Podcast>> _loadAIRecommendations() async {
    try {
      print('🤖 DEBUG: Loading AI recommendations...');
      final result = await ApiService.getMyRecommendations(limit: 9);

      if (!result.isSuccess || result.data == null) {
        print('🤖 DEBUG: AI recommendations not available: ${result.message}');

        // Fallback: Use trending podcasts as "AI recommendations" for demo
        print(
          '🤖 DEBUG: Using trending podcasts as fallback AI recommendations',
        );
        final trendingResult = await ApiService.getTrendingPodcasts(
          page: 1,
          pageSize: 3,
        );
        if (trendingResult.isSuccess && trendingResult.items.isNotEmpty) {
          return trendingResult.items.take(3).toList();
        }
        return [];
      }

      print(
        '🤖 DEBUG: AI Recommendations response: ${result.data!.recommendations.length} items',
      );

      // Convert AI recommendations to Podcast objects
      final podcasts = <Podcast>[];
      for (final rec in result.data!.recommendations) {
        // Check if it's a valid GUID (real podcast) or training ID
        final guidRegex = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        );
        final isGuid = guidRegex.hasMatch(rec.podcastId);

        if (!isGuid) {
          // Training ID - create mock podcast
          podcasts.add(
            Podcast(
              id: rec.podcastId,
              title: rec.title,
              description: rec.recommendationReason,
              thumbnailUrl: null,
              audioFileUrl: rec.contentUrl,
              duration: rec.durationMinutes != null
                  ? rec.durationMinutes! * 60
                  : 0,
              hostName: 'Unknown Host',
              guestName: null,
              episodeNumber: 1,
              seriesName: rec.topic,
              tags: [],
              viewCount: 0,
              likeCount: 0,
              commentCount: 0,
              shareCount: 0,
              contentStatus: 'Published',
              emotionCategories: [],
              topicCategories: [],
              createdAt: DateTime.now(),
              publishedAt: DateTime.now(),
              createdBy: 'ai-system',
            ),
          );
        } else {
          // Real GUID - try to fetch full podcast details
          try {
            print(
              '🔍 DEBUG: Fetching full details for podcast: ${rec.podcastId}',
            );
            final podcastResult = await ApiService.getPodcastById(
              rec.podcastId,
            );
            if (podcastResult.isSuccess && podcastResult.data != null) {
              podcasts.add(podcastResult.data!);
              print(
                '✅ DEBUG: Successfully fetched podcast: ${podcastResult.data!.title}',
              );
            } else {
              print(
                '⚠️ DEBUG: Failed to fetch podcast ${rec.podcastId}, using AI data',
              );
              // Fallback to AI data
              podcasts.add(
                Podcast(
                  id: rec.podcastId,
                  title: rec.title,
                  description: rec.recommendationReason,
                  thumbnailUrl: null,
                  audioFileUrl: rec.contentUrl,
                  duration: rec.durationMinutes != null
                      ? rec.durationMinutes! * 60
                      : 0,
                  hostName: 'Unknown Host',
                  guestName: null,
                  episodeNumber: 1,
                  seriesName: rec.topic,
                  tags: [],
                  viewCount: 0,
                  likeCount: 0,
                  commentCount: 0,
                  shareCount: 0,
                  contentStatus: 'Published',
                  emotionCategories: [],
                  topicCategories: [],
                  createdAt: DateTime.now(),
                  publishedAt: DateTime.now(),
                  createdBy: 'ai-system',
                ),
              );
            }
          } catch (e) {
            print('⚠️ DEBUG: Error fetching podcast ${rec.podcastId}: $e');
            // Fallback to AI data
            podcasts.add(
              Podcast(
                id: rec.podcastId,
                title: rec.title,
                description: rec.recommendationReason,
                thumbnailUrl: null,
                audioFileUrl: rec.contentUrl,
                duration: rec.durationMinutes != null
                    ? rec.durationMinutes! * 60
                    : 0,
                hostName: 'Unknown Host',
                guestName: null,
                episodeNumber: 1,
                seriesName: rec.topic,
                tags: [],
                viewCount: 0,
                likeCount: 0,
                commentCount: 0,
                shareCount: 0,
                contentStatus: 'Published',
                emotionCategories: [],
                topicCategories: [],
                createdAt: DateTime.now(),
                publishedAt: DateTime.now(),
                createdBy: 'ai-system',
              ),
            );
          }
        }
      }

      print('✨ DEBUG: Loaded ${podcasts.length} AI recommendations');
      return podcasts;
    } catch (e) {
      print('❌ DEBUG: AI recommendations error: $e');

      // Fallback: Use trending podcasts as "AI recommendations" for demo
      print('🤖 DEBUG: Using trending podcasts as fallback AI recommendations');
      try {
        final trendingResult = await ApiService.getTrendingPodcasts(
          page: 1,
          pageSize: 3,
        );
        if (trendingResult.isSuccess && trendingResult.items.isNotEmpty) {
          return trendingResult.items.take(3).toList();
        }
      } catch (fallbackError) {
        print('❌ DEBUG: Fallback also failed: $fallbackError');
      }
      return [];
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    final emotionCategories = _selectedEmotionFilter != null
        ? <int>[_selectedEmotionFilter!.value]
        : null;
    final topicCategories = _selectedTopicFilter != null
        ? <int>[_selectedTopicFilter!.value]
        : null;

    final result = await ApiService.getPodcasts(
      page: 1,
      pageSize: 10,
      emotionCategories: emotionCategories,
      topicCategories: topicCategories,
    );

    if (mounted) {
      setState(() {
        _trendingPodcasts = result;
        _trendingPage = 1;
        _isLoading = false;
      });

      // Switch to trending tab to show filtered results
      _tabController.animateTo(0);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedEmotionFilter = null;
      _selectedTopicFilter = null;
    });
    _loadInitialData();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    final currentTab = _tabController.index;
    PaginationResult<Podcast>? currentData;
    int currentPage = 1;

    if (currentTab == 0) {
      currentData = _trendingPodcasts;
      currentPage = _trendingPage;
    } else if (currentTab == 1) {
      currentData = _latestPodcasts;
      currentPage = _latestPage;
    } else if (currentTab == 3) {
      currentData = _searchResults;
      currentPage = _searchPage;
    } else {
      // AI recommendations tab - no pagination needed
      return;
    }

    if (currentData == null || !currentData.hasNext) return;

    setState(() => _isLoadingMore = true);

    final nextPage = currentPage + 1;
    PaginationResult<Podcast> newData;

    if (currentTab == 0) {
      newData = await ApiService.getTrendingPodcasts(
        page: nextPage,
        pageSize: 10,
      );
    } else if (currentTab == 1) {
      newData = await ApiService.getLatestPodcasts(
        page: nextPage,
        pageSize: 10,
      );
    } else if (currentTab == 3) {
      // Search tab - use appropriate API based on keyword
      if (_searchKeyword.isEmpty) {
        newData = await ApiService.getPodcasts(page: nextPage, pageSize: 10);
      } else {
        newData = await ApiService.searchPodcasts(
          keyword: _searchKeyword,
          page: nextPage,
          pageSize: 10,
        );
      }
    } else {
      // AI recommendations tab - no pagination
      return;
    }

    if (mounted && newData.isSuccess) {
      setState(() {
        final combinedItems = [...currentData!.items, ...newData.items];
        final updatedResult = PaginationResult<Podcast>(
          currentPage: newData.currentPage,
          pageSize: newData.pageSize,
          totalItems: newData.totalItems,
          totalPages: newData.totalPages,
          hasPrevious: newData.hasPrevious,
          hasNext: newData.hasNext,
          items: combinedItems,
          isSuccess: true,
        );

        if (currentTab == 0) {
          _trendingPodcasts = updatedResult;
          _trendingPage = nextPage;
        } else if (currentTab == 1) {
          _latestPodcasts = updatedResult;
          _latestPage = nextPage;
        } else if (currentTab == 3) {
          _searchResults = updatedResult;
          _searchPage = nextPage;
        }

        _isLoadingMore = false;
      });
    } else {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _searchKeyword = _searchController.text.trim();
      _isLoading = true;
    });

    await _loadSearchData();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Switch to search tab
      _tabController.animateTo(3);
    }
  }

  Future<void> _loadSearchData() async {
    final keyword = _searchController.text.trim();

    print('🔍 DEBUG: Loading search data for keyword: "$keyword"');

    if (keyword.isEmpty) {
      // No keyword - load all podcasts
      print('🔍 DEBUG: No keyword, loading all podcasts...');
      final results = await ApiService.getPodcasts(page: 1, pageSize: 10);
      print(
        '🔍 DEBUG: All podcasts result - Success: ${results.isSuccess}, Items: ${results.items.length}',
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _searchPage = 1;
        });
      }
    } else {
      // Has keyword - perform search
      print('🔍 DEBUG: Has keyword, performing search...');
      final results = await ApiService.searchPodcasts(
        keyword: keyword,
        page: 1,
        pageSize: 10,
      );
      print(
        '🔍 DEBUG: Search result - Success: ${results.isSuccess}, Items: ${results.items.length}',
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _searchPage = 1;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Set new timer for debounced search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadSearchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWithMiniPlayer(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B7355),
        title: const Text('Podcast', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color:
                  (_selectedEmotionFilter != null ||
                      _selectedTopicFilter != null)
                  ? Colors.yellow
                  : Colors.white,
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm podcast...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchDebounceTimer?.cancel();
                        setState(() {
                          _searchResults = null;
                          _searchKeyword = '';
                        });
                        // Reload search data (all podcasts)
                        _loadSearchData();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Thịnh hành'),
                  Tab(text: 'Mới nhất'),
                  Tab(text: 'AI đề xuất'),
                  Tab(text: 'Tìm kiếm'),
                ],
              ),
            ],
          ),
        ),
      ),
      child: Column(
        children: [
          // Filter Section
          if (_showFilters) _buildFilterSection(),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPodcastList(_trendingPodcasts),
                      _buildPodcastList(_latestPodcasts),
                      _buildAIRecommendationsList(),
                      _buildPodcastList(_searchResults),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationsList() {
    if (_aiRecommendations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có đề xuất AI nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy nghe một vài podcast để AI có thể đề xuất cho bạn',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // AI Header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B7355), Color(0xFF604B3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🤖 Đề xuất từ AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Được chọn riêng cho bạn dựa trên sở thích và lịch sử nghe',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // AI Recommendations Grid/List
        Expanded(child: _isGridView ? _buildAIGridView() : _buildAIListView()),
      ],
    );
  }

  Widget _buildAIGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _aiRecommendations.length,
      itemBuilder: (context, index) =>
          PodcastCard(podcast: _aiRecommendations[index]),
    );
  }

  Widget _buildAIListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _aiRecommendations.length,
      itemBuilder: (context, index) =>
          PodcastListItem(podcast: _aiRecommendations[index]),
    );
  }

  Widget _buildPodcastList(PaginationResult<Podcast>? data) {
    if (data == null || data.isEmpty) {
      return const Center(child: Text('Không có podcast nào'));
    }

    return Column(
      children: [
        Expanded(
          child: _isGridView ? _buildGridView(data) : _buildListView(data),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildGridView(PaginationResult<Podcast> data) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: data.items.length,
      itemBuilder: (context, index) => PodcastCard(podcast: data.items[index]),
    );
  }

  Widget _buildListView(PaginationResult<Podcast> data) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: data.items.length,
      itemBuilder: (context, index) =>
          PodcastListItem(podcast: data.items[index]),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_selectedEmotionFilter != null ||
                  _selectedTopicFilter != null)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Xóa bộ lọc'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Emotion Filters
          const Text('Cảm xúc', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _emotionFilters.length,
              itemBuilder: (context, index) {
                final filter = _emotionFilters[index];
                final isSelected = _selectedEmotionFilter?.id == filter.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${filter.icon} ${filter.name}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedEmotionFilter = selected ? filter : null;
                      });
                      _applyFilters();
                    },
                    selectedColor: const Color(0xFFFFD700).withOpacity(0.3),
                    backgroundColor: Colors.grey.shade200,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Topic Filters
          const Text('Chủ đề', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topicFilters.length,
              itemBuilder: (context, index) {
                final filter = _topicFilters[index];
                final isSelected = _selectedTopicFilter?.id == filter.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${filter.icon} ${filter.name}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTopicFilter = selected ? filter : null;
                      });
                      _applyFilters();
                    },
                    selectedColor: const Color(0xFFFFD700).withOpacity(0.3),
                    backgroundColor: Colors.grey.shade200,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

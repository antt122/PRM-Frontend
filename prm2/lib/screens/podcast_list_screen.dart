import 'package:flutter/material.dart';
import '../models/podcast.dart';
import '../models/podcast_category.dart';
import '../models/pagination_result.dart';
import '../services/api_service.dart';
import '../components/podcast_card.dart';
import '../components/podcast_list_item.dart';

class PodcastListScreen extends StatefulWidget {
  const PodcastListScreen({super.key});

  @override
  State<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends State<PodcastListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  PaginationResult<Podcast>? _trendingPodcasts;
  PaginationResult<Podcast>? _latestPodcasts;
  PaginationResult<Podcast>? _searchResults;

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
    _tabController = TabController(length: 3, vsync: this);
    _emotionFilters = PodcastCategoryFilter.getEmotionFilters();
    _topicFilters = PodcastCategoryFilter.getTopicFilters();
    
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    final trending = await ApiService.getTrendingPodcasts(page: 1, pageSize: 10);
    final latest = await ApiService.getLatestPodcasts(page: 1, pageSize: 10);
    
    if (mounted) {
      setState(() {
        _trendingPodcasts = trending;
        _latestPodcasts = latest;
        _isLoading = false;
      });
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    final emotionCategories = _selectedEmotionFilter != null 
        ? [_selectedEmotionFilter!.value] 
        : null;
    final topicCategories = _selectedTopicFilter != null 
        ? [_selectedTopicFilter!.value] 
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
    } else {
      currentData = _searchResults;
      currentPage = _searchPage;
    }

    if (currentData == null || !currentData.hasNext) return;

    setState(() => _isLoadingMore = true);

    final nextPage = currentPage + 1;
    PaginationResult<Podcast> newData;

    if (currentTab == 0) {
      newData = await ApiService.getTrendingPodcasts(page: nextPage, pageSize: 10);
    } else if (currentTab == 1) {
      newData = await ApiService.getLatestPodcasts(page: nextPage, pageSize: 10);
    } else {
      newData = await ApiService.searchPodcasts(keyword: _searchKeyword, page: nextPage, pageSize: 10);
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
        } else {
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
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _searchKeyword = keyword;
      _searchPage = 1;
      _isLoading = true;
    });

    final results = await ApiService.searchPodcasts(keyword: keyword, page: 1, pageSize: 10);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      _tabController.animateTo(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B7355),
        title: const Text('Podcast', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, 
              color: (_selectedEmotionFilter != null || _selectedTopicFilter != null) 
                ? Colors.yellow 
                : Colors.white
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
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
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm podcast...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = null;
                          _searchKeyword = '';
                        });
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
                  Tab(text: 'Tìm kiếm'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
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
                      _buildPodcastList(_searchResults),
                    ],
                  ),
          ),
        ],
      ),
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
      itemBuilder: (context, index) => PodcastListItem(podcast: data.items[index]),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
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
              if (_selectedEmotionFilter != null || _selectedTopicFilter != null)
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

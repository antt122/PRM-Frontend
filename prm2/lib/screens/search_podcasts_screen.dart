import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/podcast.dart';
import '../models/pagination_result.dart';
import '../services/api_service.dart';
import '../components/podcast_card.dart';
import '../components/podcast_list_item.dart';
import '../components/access_denied_widget.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class SearchPodcastsScreen extends StatefulWidget {
  const SearchPodcastsScreen({super.key});

  @override
  State<SearchPodcastsScreen> createState() => _SearchPodcastsScreenState();
}

class _SearchPodcastsScreenState extends State<SearchPodcastsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;

  PaginationResult<Podcast>? _searchResults;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _isGridView = true;
  String _searchKeyword = '';
  bool _hasLoaded = false;
  bool _hasAccess = false;
  bool _isCheckingAccess = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Check access first
    _checkAccess();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load data when screen becomes visible for the first time AND has access
    if (!_hasLoaded && _hasAccess) {
      _hasLoaded = true;
      _loadAllPodcasts();
    }
  }

  Future<void> _checkAccess() async {
    setState(() => _isCheckingAccess = true);

    try {
      final hasAccess = await ApiService.canAccessPodcastContent();
      if (mounted) {
        setState(() {
          _hasAccess = hasAccess;
          _isCheckingAccess = false;
        });

        // If has access, load data immediately
        if (_hasAccess && !_hasLoaded) {
          _hasLoaded = true;
          _loadAllPodcasts();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasAccess = false;
          _isCheckingAccess = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadAllPodcasts() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getPodcasts(page: 1, pageSize: 10);

      if (mounted) {
        setState(() {
          _searchResults = result;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    // Refresh based on current keyword state
    await _loadSearchData();
  }

  Future<void> _performSearch() async {
    setState(() {
      _searchKeyword = _searchController.text.trim();
      _isLoading = true;
    });

    await _loadSearchData();

    if (mounted) {
      setState(() => _isLoading = false);
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
          _currentPage = 1;
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
          _currentPage = 1;
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

  Future<void> _loadMore() async {
    if (_isLoadingMore || _searchResults == null || !_searchResults!.hasNext) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      PaginationResult<Podcast> newData;

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

      if (mounted && newData.isSuccess) {
        setState(() {
          final combinedItems = [..._searchResults!.items, ...newData.items];
          _searchResults = PaginationResult<Podcast>(
            currentPage: newData.currentPage,
            pageSize: newData.pageSize,
            totalItems: newData.totalItems,
            totalPages: newData.totalPages,
            hasPrevious: newData.hasPrevious,
            hasNext: newData.hasNext,
            items: combinedItems,
            isSuccess: true,
          );
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
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
            'Tìm kiếm',
            style: AppFonts.title2.copyWith(color: kPrimaryTextColor),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kGlassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGlassBorder, width: 0.5),
            ),
            child: IconButton(
              icon: Icon(
                _isGridView ? Icons.list : Icons.grid_view,
                color: kPrimaryTextColor,
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundColor, kSurfaceColor],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(
                16,
                100,
                16,
                16,
              ), // Top margin for AppBar
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
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: (_) => _performSearch(),
                      style: AppFonts.body.copyWith(color: kPrimaryTextColor),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm podcast...',
                        hintStyle: AppFonts.body.copyWith(
                          color: kSecondaryTextColor,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: kPrimaryTextColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: kPrimaryTextColor),
                          onPressed: () {
                            _searchController.clear();
                            _searchDebounceTimer?.cancel();
                            setState(() {
                              _searchResults = null;
                              _searchKeyword = '';
                            });
                            _loadSearchData();
                          },
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: _isCheckingAccess
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: kGlassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kGlassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: kPrimaryTextColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Đang kiểm tra quyền truy cập...',
                                  style: AppFonts.body.copyWith(
                                    color: kPrimaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : !_hasAccess
                  ? const AccessDeniedWidget()
                  : _isLoading
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: kGlassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kGlassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: const CircularProgressIndicator(
                              color: kPrimaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    )
                  : _searchResults == null || _searchResults!.isEmpty
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: kGlassBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kGlassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              'Không tìm thấy podcast nào',
                              style: AppFonts.body.copyWith(
                                color: kPrimaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: kPrimaryTextColor,
                          backgroundColor: Colors.black54,
                          child: Container(
                            decoration: BoxDecoration(
                              color: kGlassBackground,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              border: Border.all(
                                color: kGlassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: _isGridView
                                ? _buildGridView()
                                : _buildListView(),
                          ),
                        ),
                      ),
                    ),
            ),
            // Loading More Indicator
            if (_isLoadingMore)
              Container(
                margin: const EdgeInsets.all(16),
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
                      child: const CircularProgressIndicator(
                        color: kPrimaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: _searchResults!.items.length,
      itemBuilder: (context, index) =>
          PodcastCard(podcast: _searchResults!.items[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchResults!.items.length,
      itemBuilder: (context, index) =>
          PodcastListItem(podcast: _searchResults!.items[index]),
    );
  }
}

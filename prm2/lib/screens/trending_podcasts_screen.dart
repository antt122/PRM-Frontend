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

class TrendingPodcastsScreen extends StatefulWidget {
  const TrendingPodcastsScreen({super.key});

  @override
  State<TrendingPodcastsScreen> createState() => _TrendingPodcastsScreenState();
}

class _TrendingPodcastsScreenState extends State<TrendingPodcastsScreen> {
  PaginationResult<Podcast>? _trendingPodcasts;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _isGridView = true;
  bool _hasLoaded = false;
  bool _hasAccess = false;
  bool _isCheckingAccess = true;
  final ScrollController _scrollController = ScrollController();

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
      _loadTrendingPodcasts();
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
          _loadTrendingPodcasts();
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
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadTrendingPodcasts() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getTrendingPodcasts(
        page: 1,
        pageSize: 10,
      );

      if (mounted) {
        setState(() {
          _trendingPodcasts = result;
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
    // Reset to first page and reload latest data
    _currentPage = 1;
    await _loadTrendingPodcasts();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore ||
        _trendingPodcasts == null ||
        !_trendingPodcasts!.hasNext) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await ApiService.getTrendingPodcasts(
        page: nextPage,
        pageSize: 10,
      );

      if (mounted && result.isSuccess) {
        setState(() {
          final combinedItems = [..._trendingPodcasts!.items, ...result.items];
          _trendingPodcasts = PaginationResult<Podcast>(
            currentPage: result.currentPage,
            pageSize: result.pageSize,
            totalItems: result.totalItems,
            totalPages: result.totalPages,
            hasPrevious: result.hasPrevious,
            hasNext: result.hasNext,
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
            'Thịnh hành',
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
                        border: Border.all(color: kGlassBorder, width: 0.5),
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
                        border: Border.all(color: kGlassBorder, width: 0.5),
                      ),
                      child: const CircularProgressIndicator(
                        color: kPrimaryTextColor,
                      ),
                    ),
                  ),
                ),
              )
            : _trendingPodcasts == null || _trendingPodcasts!.isEmpty
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
                        border: Border.all(color: kGlassBorder, width: 0.5),
                      ),
                      child: Text(
                        'Không có podcast thịnh hành nào',
                        style: AppFonts.body.copyWith(color: kPrimaryTextColor),
                      ),
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 100), // AppBar space
                  Expanded(
                    child: ClipRRect(
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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _trendingPodcasts!.items.length,
      itemBuilder: (context, index) =>
          PodcastCard(podcast: _trendingPodcasts!.items[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _trendingPodcasts!.items.length,
      itemBuilder: (context, index) =>
          PodcastListItem(podcast: _trendingPodcasts!.items[index]),
    );
  }
}

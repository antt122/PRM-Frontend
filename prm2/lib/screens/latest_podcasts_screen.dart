import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/podcast.dart';
import '../models/pagination_result.dart';
import '../services/api_service.dart';
import '../components/podcast_card.dart';
import '../components/podcast_list_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class LatestPodcastsScreen extends StatefulWidget {
  const LatestPodcastsScreen({super.key});

  @override
  State<LatestPodcastsScreen> createState() => _LatestPodcastsScreenState();
}

class _LatestPodcastsScreenState extends State<LatestPodcastsScreen> {
  PaginationResult<Podcast>? _latestPodcasts;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _isGridView = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Always load fresh data when screen is created
    _loadLatestPodcasts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always refresh data when screen becomes visible
    _loadLatestPodcasts();
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

  Future<void> _loadLatestPodcasts() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getLatestPodcasts(page: 1, pageSize: 10);

      if (mounted) {
        setState(() {
          _latestPodcasts = result;
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

  Future<void> _loadMore() async {
    if (_isLoadingMore ||
        _latestPodcasts == null ||
        !_latestPodcasts!.hasNext) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await ApiService.getLatestPodcasts(
        page: nextPage,
        pageSize: 10,
      );

      if (mounted && result.isSuccess) {
        setState(() {
          final combinedItems = [..._latestPodcasts!.items, ...result.items];
          _latestPodcasts = PaginationResult<Podcast>(
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
            'Mới nhất',
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
        child: _isLoading
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
            : _latestPodcasts == null || _latestPodcasts!.isEmpty
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
                        'Không có podcast mới nào',
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: kGlassBackground,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border.all(color: kGlassBorder, width: 0.5),
                          ),
                          child: _isGridView
                              ? _buildGridView()
                              : _buildListView(),
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
      itemCount: _latestPodcasts!.items.length,
      itemBuilder: (context, index) =>
          PodcastCard(podcast: _latestPodcasts!.items[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _latestPodcasts!.items.length,
      itemBuilder: (context, index) =>
          PodcastListItem(podcast: _latestPodcasts!.items[index]),
    );
  }
}

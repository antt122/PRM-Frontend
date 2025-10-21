import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/podcast.dart';
import '../services/api_service.dart';
import '../components/podcast_card.dart';
import '../components/podcast_list_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  List<Podcast> _aiRecommendations = [];
  bool _isLoading = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Always load fresh data when screen is created
    _loadAIRecommendations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always refresh data when screen becomes visible
    _loadAIRecommendations();
  }

  Future<List<Podcast>> _loadAIRecommendations() async {
    setState(() => _isLoading = true);

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
          final podcasts = trendingResult.items.take(3).toList();
          if (mounted) {
            setState(() {
              _aiRecommendations = podcasts;
              _isLoading = false;
            });
          }
          return podcasts;
        }
        if (mounted) {
          setState(() {
            _aiRecommendations = [];
            _isLoading = false;
          });
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
      if (mounted) {
        setState(() {
          _aiRecommendations = podcasts;
          _isLoading = false;
        });
      }
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
          final podcasts = trendingResult.items.take(3).toList();
          if (mounted) {
            setState(() {
              _aiRecommendations = podcasts;
              _isLoading = false;
            });
          }
          return podcasts;
        }
      } catch (fallbackError) {
        print('❌ DEBUG: Fallback also failed: $fallbackError');
      }
      if (mounted) {
        setState(() {
          _aiRecommendations = [];
          _isLoading = false;
        });
      }
      return [];
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
            'AI đề xuất',
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
            : _aiRecommendations.isEmpty
            ? Center(
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
                          Icon(
                            Icons.psychology,
                            size: 64,
                            color: kSecondaryTextColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có đề xuất AI nào',
                            style: AppFonts.headline.copyWith(
                              color: kPrimaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy nghe một vài podcast để AI có thể đề xuất cho bạn',
                            style: AppFonts.body.copyWith(
                              color: kSecondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 100), // AppBar space
                  // AI Header
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kPrimaryColor.withOpacity(0.8),
                                kAccentColor.withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kGlassBorder, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.psychology,
                                color: kPrimaryTextColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🤖 Đề xuất từ AI',
                                      style: AppFonts.title3.copyWith(
                                        color: kPrimaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Được chọn riêng cho bạn dựa trên sở thích và lịch sử nghe',
                                      style: AppFonts.caption1.copyWith(
                                        color: kPrimaryTextColor.withOpacity(
                                          0.8,
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
                    ),
                  ),
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
                ],
              ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: _aiRecommendations.length,
      itemBuilder: (context, index) =>
          PodcastCard(podcast: _aiRecommendations[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _aiRecommendations.length,
      itemBuilder: (context, index) =>
          PodcastListItem(podcast: _aiRecommendations[index]),
    );
  }
}

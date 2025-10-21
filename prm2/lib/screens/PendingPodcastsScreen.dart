import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/PendingPodcastCard.dart';
import '../providers/PendingPodcastFilter.dart';
import '../utils/app_colors.dart';


class PendingPodcastsScreen extends ConsumerStatefulWidget {
  const PendingPodcastsScreen({super.key});

  @override
  ConsumerState<PendingPodcastsScreen> createState() => _PendingPodcastsScreenState();
}

class _PendingPodcastsScreenState extends ConsumerState<PendingPodcastsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Thêm listener để xử lý infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final filter = ref.read(pendingPodcastFilterProvider);
      // Gọi trang tiếp theo
      ref.read(pendingPodcastFilterProvider.notifier).setPage(filter.page + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcastsAsync = ref.watch(pendingPodcastsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcasts chờ duyệt'),
        // TODO: Thêm nút mở filter sheet
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(pendingPodcastsProvider.future),
        color: kAdminAccentColor,
        child: podcastsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
          error: (err, st) => Center(child: Text('Tải dữ liệu thất bại 😢\n$err',
              textAlign: TextAlign.center, style: const TextStyle(color: kAdminSecondaryTextColor))),
          data: (apiResult) {
            if (!apiResult.isSuccess || apiResult.data == null) {
              return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.',
                  style: const TextStyle(color: kAdminSecondaryTextColor)));
            }
            final response = apiResult.data!;
            if (response.podcasts.isEmpty) {
              return const Center(child: Text('Không có podcast nào đang chờ duyệt 🎧',
                  style: TextStyle(color: kAdminSecondaryTextColor, fontSize: 16)));
            }
            // ListView thân thiện với mobile
            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: response.podcasts.length,
              itemBuilder: (context, index) => PendingPodcastCard(podcast: response.podcasts[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
            );
          },
        ),
      ),
    );
  }
}

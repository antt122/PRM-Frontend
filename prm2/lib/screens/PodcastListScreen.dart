import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/PendingPodcastCard.dart';
import '../components/PodcastCard.dart';
import '../components/PodcastFilterSheet.dart';
import '../providers/PendingPodcastFilter.dart';
import '../providers/PodcastFilter.dart';
import '../utils/app_colors.dart';
import 'PodcastDetailAdminScreen.dart';



class PodcastListScreen extends ConsumerStatefulWidget {
  const PodcastListScreen({super.key});

  @override
  ConsumerState<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends ConsumerState<PodcastListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Podcasts'),
        actions: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              return _tabController.index == 0
                  ? IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => showPodcastFilterSheet(context, ref),
              )
                  : const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: kAdminAccentColor,
          unselectedLabelColor: kAdminSecondaryTextColor,
          indicatorColor: kAdminAccentColor,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ duyệt'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AllPodcastsView(),
          _PendingPodcastsView(),
        ],
      ),
    );
  }
}

// --- WIDGET CHO TAB "TẤT CẢ" ---
class _AllPodcastsView extends ConsumerWidget {
  const _AllPodcastsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastsAsync = ref.watch(podcastsProvider);
    final filterNotifier = ref.read(podcastFilterProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(podcastsProvider.future),
      color: kAdminAccentColor,
      child: podcastsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Tải dữ liệu thất bại:\n$err', textAlign: TextAlign.center)),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.'));
          }
          final response = apiResult.data!;
          if (response.podcasts.isEmpty) {
            return const Center(child: Text('Không tìm thấy podcast nào.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 250).floor().clamp(1, 4);
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.65,
                      ),
                      itemCount: response.podcasts.length,
                      itemBuilder: (context, index) {
                        final podcast = response.podcasts[index];
                        // --- KẾT NỐI Ở ĐÂY ---
                        return InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PodcastDetailAdminScreen(podcastId: podcast.id),
                              ),
                            );
                            // Nếu có kết quả trả về (sau khi duyệt/xóa), làm mới danh sách
                            if (result == true) {
                              ref.refresh(podcastsProvider);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: PodcastCard(podcast: podcast),
                        );
                      },
                    ),
                  ),
                  _buildPaginationControls(
                    currentPage: response.page,
                    totalPages: (response.totalCount / response.pageSize).ceil(),
                    onPageChanged: (page) => filterNotifier.setPage(page),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// --- WIDGET CHO TAB "CHỜ DUYỆT" ---
class _PendingPodcastsView extends ConsumerWidget {
  const _PendingPodcastsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingPodcastsAsync = ref.watch(pendingPodcastsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(pendingPodcastsProvider.future),
      color: kAdminAccentColor,
      child: pendingPodcastsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Tải dữ liệu thất bại 😢\n$err', textAlign: TextAlign.center)),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.'));
          }
          final response = apiResult.data!;
          if (response.podcasts.isEmpty) {
            return const Center(child: Text('Không có podcast nào đang chờ duyệt 🎧'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: response.podcasts.length,
            itemBuilder: (context, index) {
              final podcast = response.podcasts[index];
              // --- KẾT NỐI Ở ĐÂY ---
              return InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PodcastDetailAdminScreen(podcastId: podcast.id),
                    ),
                  );
                  // Nếu có kết quả trả về, làm mới danh sách
                  if (result == true) {
                    ref.refresh(pendingPodcastsProvider);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: PendingPodcastCard(podcast: podcast),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        },
      ),
    );
  }
}

// --- WIDGET PHÂN TRANG (TÁI SỬ DỤNG) ---
Widget _buildPaginationControls({
  required int currentPage,
  required int totalPages,
  required ValueChanged<int> onPageChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    color: kAdminCardColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: kAdminSecondaryTextColor),
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text('Trang $currentPage / $totalPages', style: const TextStyle(color: kAdminSecondaryTextColor)),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: kAdminSecondaryTextColor),
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    ),
  );
}


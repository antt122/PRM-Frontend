import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/StoryCard.dart';
import '../components/StoryFilterSheet.dart';
import '../providers/StoryFilter.dart';
import '../utils/app_colors.dart';

class CommunityStoriesScreen extends ConsumerWidget {
  const CommunityStoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsyncValue = ref.watch(storiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showStoryFilterSheet(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(storiesProvider.future),
        color: kAdminAccentColor,
        child: storiesAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load stories:\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kAdminSecondaryTextColor),
              ),
            ),
          ),
          // --- SỬA LỖI LOGIC Ở ĐÂY ---
          data: (apiResult) {
            // Bước 1: Kiểm tra xem ApiResult có thành công không
            if (!apiResult.isSuccess || apiResult.data == null) {
              return Center(
                child: Text(
                  apiResult.message ?? 'An unknown error occurred.',
                  style: const TextStyle(color: kAdminSecondaryTextColor),
                ),
              );
            }

            // Bước 2: Nếu thành công, lấy dữ liệu từ bên trong
            final paginatedResponse = apiResult.data!;
            final stories = paginatedResponse.stories;

            if (stories.isEmpty) {
              return const Center(
                  child: Text(
                    'No stories found matching your criteria.',
                    style: TextStyle(color: kAdminSecondaryTextColor),
                  ));
            }

            // Bước 3: Hiển thị danh sách
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return StoryCard(story: story);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            );
          },
        ),
      ),
    );
  }
}


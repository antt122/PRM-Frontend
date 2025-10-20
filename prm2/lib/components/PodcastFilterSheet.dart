import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/PodcastFilter.dart';
import '../utils/CategoryHelper.dart';
import '../utils/app_colors.dart';


void showPodcastFilterSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kAdminBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => DraggableScrollableSheet(
      expand: false, initialChildSize: 0.9, maxChildSize: 0.9,
      builder: (context, scrollController) => _PodcastFilterContent(scrollController: scrollController),
    ),
  );
}

class _PodcastFilterContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const _PodcastFilterContent({required this.scrollController});
  @override
  ConsumerState<_PodcastFilterContent> createState() => _PodcastFilterContentState();
}

class _PodcastFilterContentState extends ConsumerState<_PodcastFilterContent> {
  late PodcastFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(podcastFilterProvider);
  }

  void _applyFilter() {
    ref.read(podcastFilterProvider.notifier).setFilter(_tempFilter);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã áp dụng bộ lọc!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Lọc Podcasts'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      body: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
              initialValue: _tempFilter.searchTerm,
              decoration: const InputDecoration(labelText: 'Tìm kiếm...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _tempFilter = _tempFilter.copyWith(searchTerm: v))),
          const SizedBox(height: 16),
          TextFormField(
              initialValue: _tempFilter.seriesName,
              decoration: const InputDecoration(labelText: 'Tên Series', prefixIcon: Icon(Icons.video_library_outlined)),
              onChanged: (v) => setState(() => _tempFilter = _tempFilter.copyWith(seriesName: v))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                  value: _tempFilter.status,
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  items: [const DropdownMenuItem(value: null, child: Text('Tất cả')),
                    ...CategoryHelper.contentStatus.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))],
                  onChanged: (v) => setState(() => _tempFilter = _tempFilter.copyWith(status: v))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                  value: _tempFilter.pageSize,
                  decoration: const InputDecoration(labelText: 'Hiển thị'),
                  items: [10, 20, 50].map((s) => DropdownMenuItem(value: s, child: Text('$s mục'))).toList(),
                  onChanged: (v) => setState(() => _tempFilter = _tempFilter.copyWith(pageSize: v))),
            ),
          ]),
          const Divider(height: 32, color: kAdminInputBorderColor),
          _buildChipSection('Cảm xúc', CategoryHelper.podcastEmotions, _tempFilter.emotionCategories,
                (id, selected) {
              final newSet = Set<int>.from(_tempFilter.emotionCategories);
              selected ? newSet.add(id) : newSet.remove(id);
              setState(() => _tempFilter = _tempFilter.copyWith(emotionCategories: newSet.toList()));
            },
          ),
          const Divider(height: 32, color: kAdminInputBorderColor),
          _buildChipSection('Chủ đề', CategoryHelper.podcastTopics, _tempFilter.topicCategories,
                (id, selected) {
              final newSet = Set<int>.from(_tempFilter.topicCategories);
              selected ? newSet.add(id) : newSet.remove(id);
              setState(() => _tempFilter = _tempFilter.copyWith(topicCategories: newSet.toList()));
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: _applyFilter, child: const Text('Áp dụng bộ lọc')),
      ),
    );
  }

  Widget _buildChipSection(String title, Map<int, String> options, List<int> selectedIds, Function(int, bool) onSelected) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8.0, children: options.entries.map((entry) => FilterChip(
          label: Text(entry.value),
          selected: selectedIds.contains(entry.key),
          onSelected: (s) => onSelected(entry.key, s))).toList(),
      ),
    ]);
  }
}

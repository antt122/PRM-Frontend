import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/StoryFilter.dart';
import '../utils/CategoryHelper.dart';
import '../utils/app_colors.dart';


void showStoryFilterSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kAdminBackgroundColor, // Nền cho bottom sheet
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.9,
      builder: (context, scrollController) =>
          _StoryFilterContent(scrollController: scrollController),
    ),
  );
}

class _StoryFilterContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const _StoryFilterContent({required this.scrollController});

  @override
  ConsumerState<_StoryFilterContent> createState() => _StoryFilterContentState();
}

class _StoryFilterContentState extends ConsumerState<_StoryFilterContent> {
  late StoryFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(storyFilterProvider);
  }

  void _applyFilter() {
    ref.read(storyFilterProvider.notifier).setFilter(_tempFilter);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters applied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Để màu nền của bottom sheet được thấy
      appBar: AppBar(
        title: const Text('Filter Stories'),
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
          // Các input sẽ tự động lấy style từ AppTheme
          TextFormField(
            initialValue: _tempFilter.searchTerm,
            decoration: const InputDecoration(
              labelText: 'Search...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() { _tempFilter = _tempFilter.copyWith(searchTerm: value); });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _tempFilter.status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...CategoryHelper.statusMap.entries.map((e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value))),
                  ],
                  onChanged: (value) {
                    setState(() { _tempFilter = _tempFilter.copyWith(status: value); });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _tempFilter.pageSize,
                  decoration: const InputDecoration(labelText: 'Page Size'),
                  items: [10, 20, 50].map((size) =>
                      DropdownMenuItem(value: size, child: Text(size.toString()))).toList(),
                  onChanged: (value) {
                    setState(() { _tempFilter = _tempFilter.copyWith(pageSize: value); });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('⭐ Moderator Pick Only'),
            value: _tempFilter.isModeratorPick ?? false,
            onChanged: (value) {
              setState(() { _tempFilter = _tempFilter.copyWith(isModeratorPick: value); });
            },
            tileColor: kAdminCardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          const Divider(color: kAdminInputBorderColor, height: 32),
          _buildChipSection('Emotions', CategoryHelper.emotionCategories, _tempFilter.emotionCategories,
                (id, selected) {
              final newSet = Set<int>.from(_tempFilter.emotionCategories);
              selected ? newSet.add(id) : newSet.remove(id);
              setState(() { _tempFilter = _tempFilter.copyWith(emotionCategories: newSet.toList()); });
            },
          ),
          const Divider(color: kAdminInputBorderColor, height: 32),
          _buildChipSection('Topics', CategoryHelper.topicCategories, _tempFilter.topicCategories,
                (id, selected) {
              final newSet = Set<int>.from(_tempFilter.topicCategories);
              selected ? newSet.add(id) : newSet.remove(id);
              setState(() { _tempFilter = _tempFilter.copyWith(topicCategories: newSet.toList()); });
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _applyFilter,
          child: const Text('Apply Filters'),
        ),
      ),
    );
  }

  Widget _buildChipSection(
      String title,
      Map<int, String> options,
      List<int> selectedIds,
      Function(int, bool) onSelected,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: options.entries.map((entry) {
            return FilterChip(
              label: Text(entry.value),
              selected: selectedIds.contains(entry.key),
              onSelected: (selected) => onSelected(entry.key, selected),
            );
          }).toList(),
        ),
      ],
    );
  }
}


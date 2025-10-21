import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';
import '../models/podcast_category.dart';

class DashboardFilters extends StatefulWidget {
  final String searchTerm;
  final DateTime? startDate;
  final DateTime? endDate;
  final String seriesFilter;
  final Function(String) onSearchChanged;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final Function(String) onSeriesFilterChanged;
  final Function(PodcastCategoryFilter?) onEmotionFilterChanged;
  final Function(PodcastCategoryFilter?) onTopicFilterChanged;

  const DashboardFilters({
    super.key,
    required this.searchTerm,
    required this.startDate,
    required this.endDate,
    required this.seriesFilter,
    required this.onSearchChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onSeriesFilterChanged,
    required this.onEmotionFilterChanged,
    required this.onTopicFilterChanged,
  });

  @override
  State<DashboardFilters> createState() => _DashboardFiltersState();
}

class _DashboardFiltersState extends State<DashboardFilters> {
  late TextEditingController _searchController;
  late TextEditingController _seriesController;

  List<PodcastCategoryFilter> _emotionFilters = [];
  List<PodcastCategoryFilter> _topicFilters = [];
  PodcastCategoryFilter? _selectedEmotionFilter;
  PodcastCategoryFilter? _selectedTopicFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchTerm);
    _seriesController = TextEditingController(text: widget.seriesFilter);
    _emotionFilters = PodcastCategoryFilter.getEmotionFilters();
    _topicFilters = PodcastCategoryFilter.getTopicFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _seriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: kGlassShadow,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với nút clear
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: kAccentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Bộ lọc',
                        style: AppFonts.headline.copyWith(
                          color: kPrimaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_hasActiveFilters())
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Xóa bộ lọc'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Search bar
              TextField(
                controller: _searchController,
                style: AppFonts.body.copyWith(color: kPrimaryTextColor),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm podcast...',
                  hintStyle: AppFonts.body.copyWith(color: kSecondaryTextColor),
                  prefixIcon: Icon(Icons.search, color: kSecondaryTextColor),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: kSecondaryTextColor),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                  ),
                  filled: true,
                  fillColor: kSurfaceColor.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: kGlassBorder, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: kGlassBorder, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: kAccentColor, width: 1),
                  ),
                ),
                onChanged: widget.onSearchChanged,
              ),
              const SizedBox(height: 12),

              // Emotion Filters
              Text(
                'Cảm xúc',
                style: AppFonts.caption1.copyWith(
                  color: kPrimaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _emotionFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _emotionFilters[index];
                    final isSelected = _selectedEmotionFilter?.id == filter.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          '${filter.icon} ${filter.name}',
                          style: AppFonts.caption2.copyWith(
                            color: isSelected
                                ? Colors.white
                                : kPrimaryTextColor,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedEmotionFilter = selected ? filter : null;
                          });
                          widget.onEmotionFilterChanged(_selectedEmotionFilter);
                        },
                        selectedColor: kAccentColor,
                        backgroundColor: kSurfaceColor.withOpacity(0.3),
                        labelStyle: AppFonts.caption2,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Topic Filters
              Text(
                'Chủ đề',
                style: AppFonts.caption1.copyWith(
                  color: kPrimaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _topicFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _topicFilters[index];
                    final isSelected = _selectedTopicFilter?.id == filter.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          '${filter.icon} ${filter.name}',
                          style: AppFonts.caption2.copyWith(
                            color: isSelected
                                ? Colors.white
                                : kPrimaryTextColor,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTopicFilter = selected ? filter : null;
                          });
                          widget.onTopicFilterChanged(_selectedTopicFilter);
                        },
                        selectedColor: kAccentColor,
                        backgroundColor: kSurfaceColor.withOpacity(0.3),
                        labelStyle: AppFonts.caption2,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Date filters - Compact design
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: kGlassBorder, width: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          color: kSurfaceColor.withOpacity(0.3),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: kSecondaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.startDate != null
                                    ? 'Từ: ${_formatDate(widget.startDate!)}'
                                    : 'Từ ngày',
                                style: AppFonts.caption2.copyWith(
                                  color: widget.startDate != null
                                      ? kPrimaryTextColor
                                      : kSecondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: kGlassBorder, width: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          color: kSurfaceColor.withOpacity(0.3),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: kSecondaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.endDate != null
                                    ? 'Đến: ${_formatDate(widget.endDate!)}'
                                    : 'Đến ngày',
                                style: AppFonts.caption2.copyWith(
                                  color: widget.endDate != null
                                      ? kPrimaryTextColor
                                      : kSecondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.searchTerm.isNotEmpty ||
        widget.startDate != null ||
        widget.endDate != null ||
        widget.seriesFilter.isNotEmpty ||
        _selectedEmotionFilter != null ||
        _selectedTopicFilter != null;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.startDate) {
      widget.onStartDateChanged(picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.endDate ?? DateTime.now(),
      firstDate: widget.startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.endDate) {
      widget.onEndDateChanged(picked);
    }
  }

  void _clearFilters() {
    _searchController.clear();
    _seriesController.clear();
    setState(() {
      _selectedEmotionFilter = null;
      _selectedTopicFilter = null;
    });
    widget.onSearchChanged('');
    widget.onSeriesFilterChanged('');
    widget.onStartDateChanged(null);
    widget.onEndDateChanged(null);
    widget.onEmotionFilterChanged(null);
    widget.onTopicFilterChanged(null);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

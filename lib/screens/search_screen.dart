import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../repositories/activity_repository.dart';
import '../repositories/category_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ActivityRepository _activityRepo = ActivityRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Activity> _searchResults = [];
  Map<int, Category> _categoryMap = {};
  bool _isLoading = false;

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCategoryId;
  String _sortBy = 'date_desc';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();
    setState(() {
      _categoryMap = {for (var cat in categories) cat.id!: cat};
    });
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);

    List<Activity> results = [];

    if (_startDate != null && _endDate != null) {
      results = await _searchByDateRange();
    } else {
      results = await _activityRepo.getAllActivities(1);
    }

    if (_searchController.text.isNotEmpty) {
      final keyword = _searchController.text.toLowerCase();
      results = results.where((activity) {
        return activity.title.toLowerCase().contains(keyword) ||
            (activity.description?.toLowerCase().contains(keyword) ?? false);
      }).toList();
    }

    if (_selectedCategoryId != null) {
      results = results
          .where((activity) => activity.categoryId == _selectedCategoryId)
          .toList();
    }

    _sortResults(results);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<List<Activity>> _searchByDateRange() async {
    List<Activity> allResults = [];
    DateTime currentDate = _startDate!;

    while (currentDate.isBefore(_endDate!) ||
        currentDate.isAtSameMomentAs(_endDate!)) {
      final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
      final activities = await _activityRepo.getActivitiesByDate(1, dateStr);
      allResults.addAll(activities);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return allResults;
  }

  void _sortResults(List<Activity> results) {
    switch (_sortBy) {
      case 'date_desc':
        results.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        results.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'title':
        results.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _search();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _selectedCategoryId = null;
      _searchResults = [];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '활동 제목이나 내용 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          _search();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: Text(_startDate != null && _endDate != null
                      ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
                      : '날짜 범위'),
                  avatar: const Icon(Icons.calendar_today, size: 18),
                  selected: _startDate != null,
                  onSelected: (_) => _selectDateRange(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('전체'),
                    ),
                    ..._categoryMap.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(entry.value.getIcon(), size: 18),
                            const SizedBox(width: 8),
                            Text(entry.value.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                    _search();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: '정렬',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'date_desc', child: Text('최신순')),
                    DropdownMenuItem(value: 'date_asc', child: Text('오래된순')),
                    DropdownMenuItem(value: 'title', child: Text('제목순')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                      _sortResults(_searchResults);
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('초기화'),
              ),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final activity = _searchResults[index];
        final category = _categoryMap[activity.categoryId];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category?.getColor() ?? Colors.grey,
              child: Icon(
                category?.getIcon() ?? Icons.circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              activity.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activity.description != null)
                  Text(
                    activity.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  '${activity.date} ${activity.time ?? ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: activity.value != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: category?.getColor().withValues(alpha: 0.1) ??
                          Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activity.value} ${activity.unit ?? ''}',
                      style: TextStyle(
                        color: category?.getColor() ?? Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
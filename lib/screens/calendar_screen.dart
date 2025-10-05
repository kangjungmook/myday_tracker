import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../repositories/activity_repository.dart';
import '../repositories/category_repository.dart';
import 'add_activity_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ActivityRepository _activityRepo = ActivityRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  Map<DateTime, List<Activity>> _events = {};
  List<Activity> _selectedDayActivities = [];
  Map<int, Category> _categoryMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 카테고리 로드
    final categories = await _categoryRepo.getAllCategories();
    _categoryMap = {for (var cat in categories) cat.id!: cat};

    // 현재 월의 모든 활동 로드
    await _loadMonthActivities(_focusedDay);

    setState(() => _isLoading = false);
  }

  Future<void> _loadMonthActivities(DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    _events.clear();

    for (int i = 0; i <= lastDay.day; i++) {
      final date = DateTime(month.year, month.month, i + 1);
      if (date.isAfter(lastDay)) break;

      final activities = await _activityRepo.getActivitiesByDate(
        1, // userId
        DateFormat('yyyy-MM-dd').format(date),
      );

      if (activities.isNotEmpty) {
        _events[DateTime(date.year, date.month, date.day)] = activities;
      }
    }

    _loadSelectedDayActivities(_selectedDay);
  }

  void _loadSelectedDayActivities(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    setState(() {
      _selectedDayActivities = _events[normalizedDay] ?? [];
    });
  }

  List<Activity> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('달력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              _loadMonthActivities(_focusedDay);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                const Divider(height: 1),
                Expanded(
                  child: _buildActivityList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddActivityScreen(
                userId: 1,
                currentDate: DateFormat('yyyy-MM-dd').format(_selectedDay),
              ),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'ko_KR',
        
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF6C5CE7),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFF6C5CE7),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerSize: 6,
        ),

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadSelectedDayActivities(selectedDay);
        },

        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadMonthActivities(focusedDay);
        },
      ),
    );
  }

  Widget _buildActivityList() {
    if (_selectedDayActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('MM월 dd일').format(_selectedDay),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '기록된 활동이 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${DateFormat('MM월 dd일 (E)', 'ko_KR').format(_selectedDay)} - ${_selectedDayActivities.length}개 활동',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedDayActivities.length,
            itemBuilder: (context, index) {
              final activity = _selectedDayActivities[index];
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      if (activity.time != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(activity.time!),
                      ],
                      if (activity.value != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
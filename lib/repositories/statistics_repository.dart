import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/statistics.dart';
import '../repositories/category_repository.dart';

class StatisticsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final CategoryRepository _categoryRepo = CategoryRepository();

  // 기간별 통계 조회
  Future<ActivityStatistics> getStatistics(int userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;
    
    // 기본값: 최근 30일
    startDate ??= DateTime.now().subtract(const Duration(days: 30));
    endDate ??= DateTime.now();

    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate);

    // 전체 활동 조회
    final activities = await db.query(
      'activities',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startStr, endStr],
    );

    // 카테고리 정보 로드
    final categories = await _categoryRepo.getAllCategories();
    final categoryMap = {for (var cat in categories) cat.id!: cat};

    // 카테고리별 개수 계산
    Map<String, int> categoryCount = {};
    Map<String, double> categoryTotalValue = {};
    Map<String, int> activityCount = {};

    for (var activity in activities) {
      final categoryId = activity['category_id'] as int;
      final categoryName = categoryMap[categoryId]?.name ?? '기타';
      final title = activity['title'] as String;
      final value = activity['value'] as double?;

      categoryCount[categoryName] = (categoryCount[categoryName] ?? 0) + 1;
      
      if (value != null) {
        categoryTotalValue[categoryName] = 
            (categoryTotalValue[categoryName] ?? 0) + value;
      }

      activityCount[title] = (activityCount[title] ?? 0) + 1;
    }

    // TOP 3 활동
    final topActivities = activityCount.entries
        .map((e) => TopActivity(
              title: e.key,
              count: e.value,
              categoryName: '활동',
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    // 연속 기록 일수 계산
    final streakDays = await _calculateStreak(userId);

    // 최근 7일 데이터
    final weeklyData = await _getWeeklyData(userId);

    return ActivityStatistics(
      categoryCount: categoryCount,
      categoryTotalValue: categoryTotalValue,
      totalActivities: activities.length,
      streakDays: streakDays,
      topActivities: topActivities.take(3).toList(),
      weeklyData: weeklyData,
    );
  }

  // 연속 기록 일수 계산
  Future<int> _calculateStreak(int userId) async {
    final db = await _dbHelper.database;
    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (true) {
      final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
      final result = await db.query(
        'activities',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, dateStr],
        limit: 1,
      );

      if (result.isEmpty) break;
      
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // 최근 7일 데이터
  Future<Map<String, int>> _getWeeklyData(int userId) async {
    final db = await _dbHelper.database;
    Map<String, int> weeklyData = {};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayLabel = DateFormat('E', 'ko_KR').format(date);

      final result = await db.query(
        'activities',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, dateStr],
      );

      weeklyData[dayLabel] = result.length;
    }

    return weeklyData;
  }
}
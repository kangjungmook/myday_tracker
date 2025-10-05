class ActivityStatistics {
  final Map<String, int> categoryCount;
  final Map<String, double> categoryTotalValue;
  final int totalActivities;
  final int streakDays;
  final List<TopActivity> topActivities;
  final Map<String, int> weeklyData;

  ActivityStatistics({
    required this.categoryCount,
    required this.categoryTotalValue,
    required this.totalActivities,
    required this.streakDays,
    required this.topActivities,
    required this.weeklyData,
  });
}

class TopActivity {
  final String title;
  final int count;
  final String categoryName;

  TopActivity({
    required this.title,
    required this.count,
    required this.categoryName,
  });
}
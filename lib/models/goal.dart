class Goal {
  final int? id;
  final int userId;
  final int categoryId;
  final String title;
  final GoalType type;
  final double targetValue;
  final String? unit;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? createdAt;

  Goal({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.type,
    required this.targetValue,
    this.unit,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'type': type.toString().split('.').last,
      'target_value': targetValue,
      'unit': unit,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      userId: map['user_id'],
      categoryId: map['category_id'],
      title: map['title'],
      type: GoalType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      targetValue: map['target_value'],
      unit: map['unit'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
    );
  }
}

enum GoalType {
  daily,
  weekly,
  monthly,
}
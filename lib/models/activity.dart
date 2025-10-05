class Activity {
  final int? id;
  final int userId;
  final int categoryId;
  final String title;
  final String? description;
  final double? value;
  final String? unit;
  final String date;
  final String? time;
  final bool isGoalAchieved;
  final String? createdAt;

  Activity({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    this.description,
    this.value,
    this.unit,
    required this.date,
    this.time,
    this.isGoalAchieved = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'value': value,
      'unit': unit,
      'date': date,
      'time': time,
      'is_goal_achieved': isGoalAchieved ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      userId: map['user_id'],
      categoryId: map['category_id'],
      title: map['title'],
      description: map['description'],
      value: map['value']?.toDouble(),
      unit: map['unit'],
      date: map['date'],
      time: map['time'],
      isGoalAchieved: map['is_goal_achieved'] == 1,
      createdAt: map['created_at'],
    );
  }
}
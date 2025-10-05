class Record {
  final int id;
  final String category;
  final String title;
  final String description;
  final double? value;
  final DateTime date;

  Record({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.value,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'value': value,
      'date': date.toIso8601String(),
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      description: map['description'],
      value: map['value'],
      date: DateTime.parse(map['date']),
    );
  }
}
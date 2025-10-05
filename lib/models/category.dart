import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;
  final int? userId;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = true,
    this.userId,
  });

  // DB에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'is_default': isDefault ? 1 : 0,
      'user_id': userId,
    };
  }

  // DB에서 읽을 때 사용
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      isDefault: map['is_default'] == 1,
      userId: map['user_id'],
    );
  }

  // 색상 가져오기
  Color getColor() {
    return Color(int.parse('0x$color'));
  }

  // 아이콘 가져오기
  IconData getIcon() {
    final iconMap = {
      'favorite': Icons.favorite,
      'fitness_center': Icons.fitness_center,
      'account_balance_wallet': Icons.account_balance_wallet,
      'school': Icons.school,
      'palette': Icons.palette,
      'bedtime': Icons.bedtime,
      'restaurant': Icons.restaurant,
      'work': Icons.work,
      'music_note': Icons.music_note,
      'sports_soccer': Icons.sports_soccer,
      'book': Icons.book,
      'camera_alt': Icons.camera_alt,
      'coffee': Icons.coffee,
      'shopping_cart': Icons.shopping_cart,
      'pets': Icons.pets,
      'flight': Icons.flight,
      'circle': Icons.circle,  // 기본값
    };
    return iconMap[icon] ?? Icons.circle;
  }
}
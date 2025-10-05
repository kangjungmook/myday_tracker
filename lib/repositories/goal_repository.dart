import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/goal.dart';

class GoalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertGoal(Goal goal) async {
    final db = await _dbHelper.database;
    return await db.insert('goals', goal.toMap());
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await _dbHelper.database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Goal>> getActiveGoals(int userId) async {
    final db = await _dbHelper.database;
    
    // 모든 활성 목표 가져오기 (날짜 필터 제거)
    final result = await db.query(
      'goals',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<List<Goal>> getAllGoals(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<double> calculateProgress(Goal goal) async {
    final db = await _dbHelper.database;
    
    final startDate = DateFormat('yyyy-MM-dd').format(goal.startDate);
    final endDate = DateFormat('yyyy-MM-dd').format(goal.endDate);

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count, SUM(value) as total
      FROM activities
      WHERE user_id = ? 
        AND category_id = ?
        AND date BETWEEN ? AND ?
    ''', [goal.userId, goal.categoryId, startDate, endDate]);

    if (result.isEmpty) return 0.0;

    final total = result.first['total'] as double? ?? 0.0;
    return (total / goal.targetValue * 100).clamp(0.0, 100.0);
  }
}
import '../database/database_helper.dart';
import '../models/activity.dart';

class ActivityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 활동 추가
  Future<int> insertActivity(Activity activity) async {
    final db = await _dbHelper.database;
    return await db.insert('activities', activity.toMap());
  }

  // 활동 수정
  Future<int> updateActivity(Activity activity) async {
    final db = await _dbHelper.database;
    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  // 특정 날짜의 활동 조회
  Future<List<Activity>> getActivitiesByDate(int userId, String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'time DESC',
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  // 활동 삭제
  Future<int> deleteActivity(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // 모든 활동 조회 (테스트용)
  Future<List<Activity>> getAllActivities(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, time DESC',
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }
}
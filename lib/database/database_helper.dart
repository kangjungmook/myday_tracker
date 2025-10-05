import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'myday_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Categories 테이블
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        is_default INTEGER DEFAULT 1,
        user_id INTEGER
      )
    ''');

    // Activities 테이블
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        value REAL,
        unit TEXT,
        date TEXT NOT NULL,
        time TEXT,
        is_goal_achieved INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 기본 카테고리 삽입
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    List<Map<String, dynamic>> defaultCategories = [
      {'name': '건강', 'icon': 'favorite', 'color': 'FFE57373', 'is_default': 1},
      {'name': '운동', 'icon': 'fitness_center', 'color': 'FF81C784', 'is_default': 1},
      {'name': '지출', 'icon': 'account_balance_wallet', 'color': 'FF64B5F6', 'is_default': 1},
      {'name': '학습', 'icon': 'school', 'color': 'FFFFB74D', 'is_default': 1},
      {'name': '취미', 'icon': 'palette', 'color': 'FFBA68C8', 'is_default': 1},
      {'name': '수면', 'icon': 'bedtime', 'color': 'FF4FC3F7', 'is_default': 1},
      {'name': '식사', 'icon': 'restaurant', 'color': 'FFAED581', 'is_default': 1},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }
}
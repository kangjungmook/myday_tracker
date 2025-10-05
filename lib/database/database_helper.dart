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
      version: 2, // ⭐ 버전을 2로 올림
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // ⭐ 추가
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

    // Goals 테이블 ⭐ 추가
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        target_value REAL NOT NULL,
        unit TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 기본 카테고리 삽입
    await _insertDefaultCategories(db);
  }

  // ⭐ 업그레이드 함수 추가
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // version 1 → 2: goals 테이블 추가
      await db.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          target_value REAL NOT NULL,
          unit TEXT,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          is_active INTEGER DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
        )
      ''');
    }
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
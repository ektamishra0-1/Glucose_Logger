import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/glucose_log.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();

    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, "glucose_logger.db");

    return openDatabase(
      path,
      version: 1,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE glucose_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            glucose REAL NOT NULL,
            insulin REAL,
            exercised INTEGER NOT NULL,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertLog(GlucoseLog log) async {
    final db = await database;

    return db.insert("glucose_logs", log.toMap());
  }

  Future<List<GlucoseLog>> getLogs() async {
    final db = await database;

    final result = await db.query("glucose_logs", orderBy: "timestamp DESC");

    return result.map((e) => GlucoseLog.fromMap(e)).toList();
  }

  Future<GlucoseLog?> getLatestLog() async {
    final db = await database;

    final result = await db.query(
      "glucose_logs",
      limit: 1,
      orderBy: "timestamp DESC",
    );

    if (result.isEmpty) return null;

    return GlucoseLog.fromMap(result.first);
  }

  Future<List<GlucoseLog>> getLogsBetween(DateTime start, DateTime end) async {
    final db = await database;

    final result = await db.query(
      "glucose_logs",
      where: "timestamp BETWEEN ? AND ?",
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: "timestamp DESC",
    );

    return result.map((e) => GlucoseLog.fromMap(e)).toList();
  }

  Future<List<GlucoseLog>> getLogsLastDays(int days) async {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: days));

    return getLogsBetween(start, now);
  }
}

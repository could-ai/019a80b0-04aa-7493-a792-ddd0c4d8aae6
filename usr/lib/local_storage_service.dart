import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageService {
  static Database? _database;
  static const String _dbName = 'translation_history.db';
  static const String _tableName = 'translations';

  static Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original TEXT NOT NULL,
        translated TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  static Future<void> saveTranslation(String original, String translated) async {
    if (_database == null) return;
    await _database!.insert(_tableName, {
      'original': original,
      'translated': translated,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getTranslationHistory() async {
    if (_database == null) return [];
    return await _database!.query(_tableName, orderBy: 'timestamp DESC');
  }

  static Future<void> clearHistory() async {
    if (_database == null) return;
    await _database!.delete(_tableName);
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:traveljournal/features/journal/models/journal.dart';
import 'package:traveljournal/features/profile/models/user_profile.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  static Database? _database;

  factory LocalDatabaseService() {
    return _instance;
  }

  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'travel_journal.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // User profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        username TEXT,
        avatar_url TEXT,
        updated_at TEXT
      )
    ''');

    // Travel preferences table
    await db.execute('''
      CREATE TABLE preferences (
        user_id TEXT PRIMARY KEY,
        preferred_destinations TEXT,
        travel_style TEXT,
        interests TEXT,
        FOREIGN KEY (user_id) REFERENCES profiles (id)
      )
    ''');

    // Journal entries table
    await db.execute('''
      CREATE TABLE journals (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        image_url TEXT,
        location_name TEXT,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES profiles (id)
      )
    ''');
  }

  // Profile methods
  Future<void> saveProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'profiles',
      profile.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getProfile(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return UserProfile.fromJson(maps.first);
  }

  // Journal methods
  Future<void> saveJournal(Journal journal) async {
    final db = await database;
    await db.insert(
      'journals',
      journal.toJson()..['is_synced'] = 1,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Journal>> getUnSyncedJournals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'journals',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return Journal.fromJson(maps[i]);
    });
  }

  Future<void> markJournalAsSynced(String journalId) async {
    final db = await database;
    await db.update(
      'journals',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [journalId],
    );
  }

  // Preferences methods
  Future<void> savePreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    final db = await database;
    await db.insert('preferences', {
      'user_id': userId,
      'preferred_destinations': preferences['preferred_destinations'],
      'travel_style': preferences['travel_style'],
      'interests': preferences['interests'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getPreferences(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }
}
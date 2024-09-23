import '../Model/playlist_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../Model/video_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'video_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE videos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      path TEXT UNIQUE
    )''');

    await db.execute('''CREATE TABLE playlists(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      videoPaths TEXT
    )''');
  }

  // Insert a new video into the database
  Future<void> insertVideo(Video_Model video) async {
    final db = await database;
    await db.insert(
      'videos',
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all videos from the database
  Future<List<Video_Model>> getVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('videos');
    return List.generate(maps.length, (i) {
      return Video_Model(
        id: maps[i]['id'],
        title: maps[i]['title'],
        path: maps[i]['path'],
      );
    });
  }

  // Clear all videos from the database
  Future<void> clearVideos() async {
    final db = await database;
    await db.delete('videos');
  }

  // Delete a video from the database by path
  Future<void> deleteVideo(String videoPath) async {
    final db = await database;
    await db.delete(
      'videos',
      where: 'path = ?',
      whereArgs: [videoPath],
    );
  }

  /// Fetch playlists from SQLite
  Future<List<Playlist_Model>> getPlaylists() async {
    // Replace with actual database querying code
    final db = await _getDatabase();
    final List<Map<String, dynamic>> playlistData = await db.query('playlists');
    return playlistData.map((data) => Playlist_Model.fromMap(data)).toList();
  }

  /// Create a playlist in SQLite
  Future<void> createPlaylist(String name) async {
    final db = await _getDatabase();
    await db.insert('playlists', {'name': name}); // Insert into 'playlists' table
  }

  /// Delete a playlist from SQLite
  Future<void> deletePlaylist(int playlistId) async {
    final db = await _getDatabase();
    await db.delete('playlists', where: 'id = ?', whereArgs: [playlistId]); // Delete by ID
  }

  /// Helper to get the database instance
  Future<Database> _getDatabase() async {
    // Open or initialize your SQLite database
    return openDatabase('playlists.db', version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
        });
  }

  // Insert a video path into the playlist
  Future<void> addVideoToPlaylist(int playlistId, String videoPath) async {
    final db = await database;

    // Fetch the current video paths for the playlist
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );

    if (maps.isNotEmpty) {
      String currentPaths = maps.first['videoPaths'] ?? '';
      List<String> pathList = currentPaths.isNotEmpty
          ? currentPaths.split(',') // Convert comma-separated paths to list
          : [];

      if (!pathList.contains(videoPath)) {
        pathList.add(videoPath); // Add the new video path

        // Update the playlist with the new video paths
        await db.update(
          'playlists',
          {'videoPaths': pathList.join(',')}, // Convert list back to comma-separated string
          where: 'id = ?',
          whereArgs: [playlistId],
        );
      }
    }
  }

  Future<void> removeVideoFromPlaylist(int playlistId, String videoPath) async {
    final db = await database;

    // Fetch the current video paths
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );

    if (maps.isNotEmpty) {
      String currentPaths = maps.first['videoPaths'] ?? '';
      List<String> pathList = currentPaths.split(',');

      if (pathList.contains(videoPath)) {
        pathList.remove(videoPath); // Remove the selected video path

        // Update the playlist with the modified paths
        await db.update(
          'playlists',
          {'videoPaths': pathList.join(',')}, // Save the updated paths
          where: 'id = ?',
          whereArgs: [playlistId],
        );
      }
    }
  }

// Fetch video paths for a specific playlist
  Future<List<String>> getVideoPathsForPlaylist(int playlistId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );

    if (maps.isNotEmpty) {
      String videoPaths = maps.first['videoPaths'] ?? '';
      return videoPaths.isNotEmpty ? videoPaths.split(',') : [];
    }

    return [];
  }


}

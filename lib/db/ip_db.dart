import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class IpDb {
  static final IpDb instance = IpDb._();
  IpDb._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'ip_manager.db'),
      version: 3, // bump: v2 added category, v3 keeps for future migration room
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ip_addresses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL,
        address TEXT NOT NULL,
        version TEXT NOT NULL,     -- 'IPv4' | 'IPv6'
        prefix INTEGER NOT NULL,   -- CIDR (0-32 / 0-128)
        gateway TEXT,
        notes TEXT,
        category TEXT NOT NULL DEFAULT 'Unknown',
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE ip_addresses ADD COLUMN category TEXT NOT NULL DEFAULT 'Unknown';",
      );
    }
    // v3 reserved for future columns (no-op)
  }
}

import 'package:sqflite/sqflite.dart';
import '../db/ip_db.dart';
import '../models/ip_address.dart';

class IpRepository {
  Future<Database> get _db async => IpDb.instance.database;

  Future<int> insert(IpAddress ip) async {
    final db = await _db;
    return db.insert(
      'ip_addresses',
      ip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<IpAddress>> getAll({
    String? query,
    String? version,
    bool favoriteOnly = false,
  }) async {
    final db = await _db;

    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(label LIKE ? OR address LIKE ? OR notes LIKE ?)');
      final like = '%${query.trim()}%';
      args.addAll([like, like, like]);
    }
    if (version != null && version.isNotEmpty) {
      where.add('version = ?');
      args.add(version);
    }
    if (favoriteOnly) {
      where.add('is_favorite = 1');
    }

    final rows = await db.query(
      'ip_addresses',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'updated_at DESC', // base order; UI ยัง sort ได้อีกชั้น
    );
    return rows.map(IpAddress.fromMap).toList();
  }

  Future<int> update(IpAddress ip) async {
    final db = await _db;
    return db.update(
      'ip_addresses',
      ip.toMap(),
      where: 'id = ?',
      whereArgs: [ip.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('ip_addresses', where: 'id = ?', whereArgs: [id]);
  }
}

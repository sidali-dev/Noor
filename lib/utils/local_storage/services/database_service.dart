import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/utils/local_storage/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  DatabaseService._();

  static final DatabaseService databaseService = DatabaseService._();

  static Future<Database> init() async {
    return _database ??= await DbHelper.initDb();
  }

  static Future<List<AdhkarModel>> getAdhkar(int adhkarType) async {
    final List<Map<String, dynamic>> response = await _database!.query(
      "adhkar_table",
      where: 'dhikr_type = ?',
      whereArgs: [adhkarType],
    );

    List<AdhkarModel> adhkars =
        response.map((e) => AdhkarModel.fromMap(e)).toList();
    return adhkars;
  }

  /// Number of adhkar per category, from a single GROUP BY query.
  static Future<Map<int, int>> getAdhkarCounts() async {
    final rows = await _database!.rawQuery(
      'SELECT dhikr_type AS type, COUNT(*) AS n '
      'FROM adhkar_table GROUP BY dhikr_type',
    );
    return {
      for (final r in rows) (r['type'] as int): (r['n'] as int),
    };
  }

  /// Every dhikr, in the same row order [getAdhkar] returns per type.
  static Future<List<AdhkarModel>> getAllAdhkar() async {
    final response = await _database!.query("adhkar_table");
    return response.map((e) => AdhkarModel.fromMap(e)).toList();
  }
}

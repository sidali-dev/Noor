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

  static getAdhkar(int adhkarType) async {
    final List<Map<String, dynamic>> response = await _database!
        .query("adhkar_table", where: "dhikr_type = $adhkarType");

    List<AdhkarModel> adhkars =
        response.map((e) => AdhkarModel.fromMap(e)).toList();
    return adhkars;
  }
}

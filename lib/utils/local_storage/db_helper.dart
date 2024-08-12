import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Future<Database> initDb() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, "noor.db");

    final bool exist = await databaseExists(path);

    if (exist) {
      Database db = await openDatabase(path);

      return db;
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "noor.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
      Database db = await openDatabase(path);
      return db;
    }
  }
}

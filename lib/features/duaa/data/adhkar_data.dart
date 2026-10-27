import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';

/// Every dhikr, read once from `assets/data/adhkar.json` at startup and kept in
/// memory, so screens read it synchronously.
class AdhkarData {
  AdhkarData._();

  static List<AdhkarModel> _all = const [];
  static Map<int, List<AdhkarModel>> _byType = const {};

  static Future<void> init() async {
    final raw = await rootBundle.loadString('assets/data/adhkar.json');
    _all = [
      for (final e in jsonDecode(raw) as List)
        AdhkarModel.fromMap(e as Map<String, dynamic>),
    ];
    final byType = <int, List<AdhkarModel>>{};
    for (final a in _all) {
      (byType[a.dhikrType] ??= []).add(a);
    }
    _byType = byType;
  }

  static List<AdhkarModel> get all => _all;

  static List<AdhkarModel> byType(int type) => _byType[type] ?? const [];

  /// Number of adhkar per category.
  static Map<int, int> get counts =>
      {for (final e in _byType.entries) e.key: e.value.length};
}

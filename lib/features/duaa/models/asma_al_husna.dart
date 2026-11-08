import 'dart:convert';

import 'package:noor/core/services/http_service.dart';
import 'package:noor/core/services/app_prefs.dart';

class AsmaName {
  final int number;
  final String name;
  final String transliteration;

  /// English only: the API has no other language.
  final String meaning;

  const AsmaName({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.meaning,
  });

  factory AsmaName.fromJson(Map<String, dynamic> json) => AsmaName(
        number: (json['number'] as num).toInt(),
        name: json['name'] as String,
        transliteration: json['transliteration'] as String,
        meaning:
            (json['en'] as Map<String, dynamic>?)?['meaning'] as String? ?? '',
      );
}

class AsmaAlHusna {
  static const count = 99;

  static List<AsmaName> parse(Object? data) {
    final names = [
      for (final item in data as List) AsmaName.fromJson(item),
    ]..sort((a, b) => a.number.compareTo(b.number));
    if (names.length != count) {
      throw const PrayerApiException(200, 'Incomplete names');
    }
    return names;
  }

  /// Fetched once, then read from the cache: the names never change.
  static Future<List<AsmaName>> load() async {
    final cached = AppPrefs.asmaAlHusnaJson;
    if (cached != null) {
      try {
        return parse(jsonDecode(cached));
      } catch (_) {}
    }
    final body = await HttpService.getJson(
      Uri.https('api.aladhan.com', '/v1/asmaAlHusna'),
    );
    final names = parse(body['data']);
    await AppPrefs.setAsmaAlHusnaJson(jsonEncode(body['data']));
    return names;
  }
}

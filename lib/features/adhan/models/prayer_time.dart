import 'datum.dart';

class PrayerTime {
  int code;
  String status;
  Map<String, List<Datum>> data;

  /// The calculation method the API used, as it reports in each day's meta.
  int? methodId;

  /// The request that produced this calendar, year left out; null in
  /// calendars cached before it was kept.
  String? source;

  PrayerTime.empty()
      : code = 0,
        status = "",
        data = {};

  PrayerTime({
    required this.code,
    required this.status,
    required this.data,
    this.methodId,
    this.source,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    final rawData = Map.from(json["data"]);
    return PrayerTime(
      code: json["code"],
      status: json["status"],
      data: rawData.map((k, v) => MapEntry<String, List<Datum>>(
          k, List<Datum>.from(v.map((x) => Datum.fromJson(x))))),
      methodId: json["methodId"] is int
          ? json["methodId"] as int
          : _methodIdOf(rawData),
      source: json["source"] as String?,
    );
  }

  static int? _methodIdOf(Map rawData) {
    for (final month in rawData.values) {
      if (month is List && month.isNotEmpty) {
        final id = month.first['meta']?['method']?['id'];
        return id is int ? id : null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "data": Map.from(data).map((k, v) => MapEntry<String, dynamic>(
            k, List<dynamic>.from(v.map((x) => x.toJson())))),
        if (methodId != null) "methodId": methodId,
        if (source != null) "source": source,
      };
}

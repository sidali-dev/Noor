import 'datum.dart';

class PrayerTime {
  int code;
  String status;
  Map<String, List<Datum>> data;

  PrayerTime.empty()
      : code = 0,
        status = "",
        data = {};

  PrayerTime({
    required this.code,
    required this.status,
    required this.data,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) => PrayerTime(
        code: json["code"],
        status: json["status"],
        data: Map.from(json["data"]).map((k, v) =>
            MapEntry<String, List<Datum>>(
                k, List<Datum>.from(v.map((x) => Datum.fromJson(x))))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "data": Map.from(data).map((k, v) => MapEntry<String, dynamic>(
            k, List<dynamic>.from(v.map((x) => x.toJson())))),
      };
}

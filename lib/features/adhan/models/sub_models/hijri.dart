import 'hijri_week_day.dart';

class HijriMonth {
  String en;
  String ar;

  HijriMonth({required this.en, required this.ar});

  factory HijriMonth.fromJson(Map<String, dynamic> json) =>
      HijriMonth(en: json["en"], ar: json["ar"]);

  Map<String, dynamic> toJson() => {"en": en, "ar": ar};
}

class Hijri {
  String date;
  HijriWeekday weekday;

  /// Null in calendars cached before the month name was kept.
  HijriMonth? month;

  Hijri({
    required this.date,
    required this.weekday,
    this.month,
  });

  factory Hijri.fromJson(Map<String, dynamic> json) => Hijri(
        date: json["date"],
        weekday: HijriWeekday.fromJson(json["weekday"]),
        month:
            json["month"] == null ? null : HijriMonth.fromJson(json["month"]),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "weekday": weekday.toJson(),
        if (month != null) "month": month!.toJson(),
      };
}

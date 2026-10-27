import 'hijri_week_day.dart';

class Hijri {
  String date;
  HijriWeekday weekday;

  Hijri({
    required this.date,
    required this.weekday,
  });

  factory Hijri.fromJson(Map<String, dynamic> json) => Hijri(
        date: json["date"],
        weekday: HijriWeekday.fromJson(json["weekday"]),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "weekday": weekday.toJson(),
      };
}

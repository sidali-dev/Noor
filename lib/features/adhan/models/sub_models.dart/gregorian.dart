import 'gregorian_week_day.dart';

class Gregorian {
  String date;
  GregorianWeekday weekday;

  Gregorian({
    required this.date,
    required this.weekday,
  });

  factory Gregorian.fromJson(Map<String, dynamic> json) => Gregorian(
        date: json["date"],
        weekday: GregorianWeekday.fromJson(json["weekday"]),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "weekday": weekday.toJson(),
      };
}

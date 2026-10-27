import 'sub_models/date.dart';
import 'sub_models/timings.dart';

class Datum {
  Timings timings;
  Date date;

  Datum({
    required this.timings,
    required this.date,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        timings: Timings.fromJson(json["timings"]),
        date: Date.fromJson(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "timings": timings.toJson(),
        "date": date.toJson(),
      };
}

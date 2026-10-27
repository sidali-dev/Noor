import 'sub_models/timings.dart';

enum Prayer {
  fajr(
    key: 'fajr',
    adhanId: 1,
    alarmId1: 101,
    alarmId2: 102,
    durationKey1: 'fajr_alarm_1_duration',
    durationKey2: 'fajr_alarm_2_duration',
  ),
  chourouk(
    key: 'chourouk',
    adhanId: 2,
    alarmId1: 201,
    alarmId2: 202,
    durationKey1: 'chourouk_alarm_1_duration',
    durationKey2: 'chourouk_alarm_2_duration',
  ),
  dhuhr(
    key: 'dhuhr',
    adhanId: 3,
    alarmId1: 301,
    alarmId2: 302,
    durationKey1: 'dhuhr_alarm_1_duration',
    durationKey2: 'dhuhr_alarm_2_duration',
  ),
  asr(
    key: 'asr',
    adhanId: 4,
    alarmId1: 401,
    alarmId2: 402,
    durationKey1: 'asr_alarm_1_duration',
    durationKey2: 'asr_alarm_2_duration',
  ),
  maghrib(
    key: 'maghrib',
    adhanId: 5,
    alarmId1: 501,
    alarmId2: 502,
    durationKey1: 'maghrib_alarm_1_duration',
    durationKey2: 'maghrib_alarm_2_duration',
  ),
  isha(
    key: 'isha',
    adhanId: 6,
    alarmId1: 601,
    alarmId2: 602,
    durationKey1: 'isha_alarm_1_duration',
    durationKey2: 'isha_alarm_2_duration',
  );

  const Prayer({
    required this.key,
    required this.adhanId,
    required this.alarmId1,
    required this.alarmId2,
    required this.durationKey1,
    required this.durationKey2,
  });

  final String key;
  final int adhanId;
  final int alarmId1;
  final int alarmId2;
  final String durationKey1;
  final String durationKey2;

  static const List<Prayer> all = Prayer.values;

  static Prayer? byKey(String key) {
    for (final prayer in values) {
      if (prayer.key == key) return prayer;
    }
    return null;
  }

  /// Extracts this prayer's time string from [Timings].
  /// Chourouk's time is [Timings.sunrise].
  String timeFromTimings(Timings timings) {
    switch (this) {
      case Prayer.fajr:
        return timings.fajr;
      case Prayer.chourouk:
        return timings.sunrise;
      case Prayer.dhuhr:
        return timings.dhuhr;
      case Prayer.asr:
        return timings.asr;
      case Prayer.maghrib:
        return timings.maghrib;
      case Prayer.isha:
        return timings.isha;
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/features/adhan/models/sub_models.dart/timings.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';

PrayerTime createTestPrayerTime({
  required int year,
  Map<int, int>? daysPerMonth,
  Map<String, String>? timings,
}) {
  final defaultDays = <int, int>{
    1: 31,
    2: (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31,
  };
  final effectiveDays = daysPerMonth ?? defaultDays;

  final dataJson = <String, dynamic>{};
  effectiveDays.forEach((month, numDays) {
    dataJson[month.toString()] = List.generate(numDays, (i) {
      return {
        'timings': {
          'Fajr': timings?['Fajr'] ?? '05:00',
          'Sunrise': timings?['Sunrise'] ?? '06:30',
          'Dhuhr': timings?['Dhuhr'] ?? '12:30',
          'Asr': timings?['Asr'] ?? '16:00',
          'Sunset': '18:50',
          'Maghrib': timings?['Maghrib'] ?? '19:00',
          'Isha': timings?['Isha'] ?? '20:30',
          'Imsak': '04:50',
          'Midnight': '00:00',
          'Firstthird': '22:00',
          'Lastthird': '02:00',
        },
        'date': {
          'readable': '${i + 1} $month $year',
          'timestamp': '1000',
          'gregorian': {
            'date': '${i + 1}',
            'weekday': {'en': 'Monday'},
          },
          'hijri': {
            'date': '${i + 1}',
            'weekday': {'en': 'Al Ithnin', 'ar': 'الاثنين'},
          },
        },
      };
    });
  });

  return PrayerTime.fromJson({
    'code': 200,
    'status': 'OK',
    'data': dataJson,
  });
}

void main() {
  group('Prayer.all literals', () {
    test('contains exact keys, adhanIds, alarmIds and duration keys', () {
      expect(Prayer.all.length, 6);

      const fajr = Prayer.fajr;
      expect(fajr.key, 'fajr');
      expect(fajr.adhanId, 1);
      expect(fajr.alarmId1, 101);
      expect(fajr.alarmId2, 102);
      expect(fajr.durationKey1, 'fajr_alarm_1_duration');
      expect(fajr.durationKey2, 'fajr_alarm_2_duration');

      const chourouk = Prayer.chourouk;
      expect(chourouk.key, 'chourouk');
      expect(chourouk.adhanId, 2);
      expect(chourouk.alarmId1, 201);
      expect(chourouk.alarmId2, 202);
      expect(chourouk.durationKey1, 'chourouk_alarm_1_duration');
      expect(chourouk.durationKey2, 'chourouk_alarm_2_duration');

      const dhuhr = Prayer.dhuhr;
      expect(dhuhr.key, 'dhuhr');
      expect(dhuhr.adhanId, 3);
      expect(dhuhr.alarmId1, 301);
      expect(dhuhr.alarmId2, 302);
      expect(dhuhr.durationKey1, 'dhuhr_alarm_1_duration');
      expect(dhuhr.durationKey2, 'dhuhr_alarm_2_duration');

      const asr = Prayer.asr;
      expect(asr.key, 'asr');
      expect(asr.adhanId, 4);
      expect(asr.alarmId1, 401);
      expect(asr.alarmId2, 402);
      expect(asr.durationKey1, 'asr_alarm_1_duration');
      expect(asr.durationKey2, 'asr_alarm_2_duration');

      const maghrib = Prayer.maghrib;
      expect(maghrib.key, 'maghrib');
      expect(maghrib.adhanId, 5);
      expect(maghrib.alarmId1, 501);
      expect(maghrib.alarmId2, 502);
      expect(maghrib.durationKey1, 'maghrib_alarm_1_duration');
      expect(maghrib.durationKey2, 'maghrib_alarm_2_duration');

      const isha = Prayer.isha;
      expect(isha.key, 'isha');
      expect(isha.adhanId, 6);
      expect(isha.alarmId1, 601);
      expect(isha.alarmId2, 602);
      expect(isha.durationKey1, 'isha_alarm_1_duration');
      expect(isha.durationKey2, 'isha_alarm_2_duration');
    });

    test('Chourouk time is Timings.sunrise', () {
      final t = Timings(
        fajr: '05:00',
        sunrise: '06:30',
        dhuhr: '12:30',
        asr: '16:00',
        sunset: '18:50',
        maghrib: '19:00',
        isha: '20:30',
        imsak: '04:50',
        midnight: '00:00',
        firstthird: '22:00',
        lastthird: '02:00',
      );
      expect(Prayer.chourouk.timeFromTimings(t), '06:30');
      expect(Prayer.fajr.timeFromTimings(t), '05:00');
    });
  });

  group('idFor and baseOf', () {
    test('round trip and offset values', () {
      for (final prayer in Prayer.all) {
        for (var offset = 0; offset < 5; offset++) {
          final adhanId = idFor(prayer.adhanId, offset);
          expect(baseOf(adhanId), prayer.adhanId);

          final alarm1 = idFor(prayer.alarmId1, offset);
          expect(baseOf(alarm1), prayer.alarmId1);

          final alarm2 = idFor(prayer.alarmId2, offset);
          expect(baseOf(alarm2), prayer.alarmId2);
        }
      }

      expect(idFor(1, 0), 1);
      expect(idFor(1, 1), 10001);
      expect(idFor(1, 2), 20001);
      expect(idFor(101, 1), 10101);
      expect(baseOf(20001), 1);
      expect(baseOf(10101), 101);
    });
  });

  group('planAlarms', () {
    final calendar2026 = createTestPrayerTime(year: 2026);
    final calendar2024 = createTestPrayerTime(year: 2024);

    test('mid-month: 3 days x enabled prayers', () {
      final now = DateTime(2026, 4, 15, 3, 0);
      final plan = AdhanScheduler.planAlarms(
        now: now,
        getCalendar: (y) => y == 2026 ? calendar2026 : null,
        isPrayerEnabled: (_) => true,
        reminders: (_) => [],
        windowDays: 3,
      );

      // 3 days * 6 prayers = 18 alarms
      expect(plan.alarmsToSet.length, 18);
      expect(plan.idsToCancel.where((id) => id < 100).isEmpty, isTrue);

      final day0Alarms = plan.alarmsToSet
          .where((a) => a.time.day == 15 && a.time.month == 4)
          .toList();
      final day1Alarms = plan.alarmsToSet
          .where((a) => a.time.day == 16 && a.time.month == 4)
          .toList();
      final day2Alarms = plan.alarmsToSet
          .where((a) => a.time.day == 17 && a.time.month == 4)
          .toList();

      expect(day0Alarms.length, 6);
      expect(day1Alarms.length, 6);
      expect(day2Alarms.length, 6);

      expect(day0Alarms.map((a) => a.id).toList(), [1, 2, 3, 4, 5, 6]);
      expect(day1Alarms.map((a) => a.id).toList(),
          [10001, 10002, 10003, 10004, 10005, 10006]);
      expect(day2Alarms.map((a) => a.id).toList(),
          [20001, 20002, 20003, 20004, 20005, 20006]);
    });

    test('Jan 31 -> Feb 1 rollover', () {
      final now = DateTime(2026, 1, 31, 3, 0);
      final plan = AdhanScheduler.planAlarms(
        now: now,
        getCalendar: (y) => y == 2026 ? calendar2026 : null,
        isPrayerEnabled: (_) => true,
        reminders: (_) => [],
        windowDays: 3,
      );

      expect(plan.alarmsToSet.length, 18);

      final jan31 = plan.alarmsToSet.where((a) => a.time.month == 1 && a.time.day == 31);
      final feb1 = plan.alarmsToSet.where((a) => a.time.month == 2 && a.time.day == 1);
      final feb2 = plan.alarmsToSet.where((a) => a.time.month == 2 && a.time.day == 2);

      expect(jan31.length, 6);
      expect(feb1.length, 6);
      expect(feb2.length, 6);
    });

    test('Dec 31 with no next-year data skips days and never throws', () {
      final now = DateTime(2026, 12, 31, 3, 0);
      final plan = AdhanScheduler.planAlarms(
        now: now,
        getCalendar: (y) => y == 2026 ? calendar2026 : null, // 2027 returns null
        isPrayerEnabled: (_) => true,
        reminders: (_) => [],
        windowDays: 3,
      );

      // Dec 31 has 6 alarms; Jan 1 and Jan 2 of 2027 are safely skipped
      expect(plan.alarmsToSet.length, 6);
      expect(plan.alarmsToSet.every((a) => a.time.year == 2026 && a.time.month == 12 && a.time.day == 31), isTrue);
    });

    test('leap day rollover (2024-02-28 -> 2024-02-29 -> 2024-03-01)', () {
      final now = DateTime(2024, 2, 28, 3, 0);
      final plan = AdhanScheduler.planAlarms(
        now: now,
        getCalendar: (y) => y == 2024 ? calendar2024 : null,
        isPrayerEnabled: (_) => true,
        reminders: (_) => [],
        windowDays: 3,
      );

      expect(plan.alarmsToSet.length, 18);
      final feb28 = plan.alarmsToSet.where((a) => a.time.month == 2 && a.time.day == 28);
      final feb29 = plan.alarmsToSet.where((a) => a.time.month == 2 && a.time.day == 29);
      final mar1 = plan.alarmsToSet.where((a) => a.time.month == 3 && a.time.day == 1);

      expect(feb28.length, 6);
      expect(feb29.length, 6);
      expect(mar1.length, 6);
    });

    test('past prayer times on day 0 are skipped', () {
      // 14:00 is after Fajr (05:00), Sunrise (06:30), Dhuhr (12:30), but before Asr (16:00)
      final now = DateTime(2026, 4, 15, 14, 0);
      final plan = AdhanScheduler.planAlarms(
        now: now,
        getCalendar: (y) => y == 2026 ? calendar2026 : null,
        isPrayerEnabled: (_) => true,
        reminders: (_) => [],
        windowDays: 3,
      );

      final day0Alarms = plan.alarmsToSet
          .where((a) => a.time.day == 15 && a.time.month == 4)
          .toList();
      // Only Asr, Maghrib, Isha on day 0
      expect(day0Alarms.length, 3);
      expect(day0Alarms.map((a) => a.prayer).toList(), [
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha,
      ]);

      // Day 1 and Day 2 have all 6
      final day1Alarms = plan.alarmsToSet.where((a) => a.time.day == 16);
      final day2Alarms = plan.alarmsToSet.where((a) => a.time.day == 17);
      expect(day1Alarms.length, 6);
      expect(day2Alarms.length, 6);
      expect(plan.alarmsToSet.length, 15);
    });

    test('disabled prayer yields cancellation of all offsets', () {
      final now = DateTime(2026, 4, 15, 3, 0);
      final plan = AdhanScheduler.planAlarms(
        now: now,
        getCalendar: (y) => y == 2026 ? calendar2026 : null,
        isPrayerEnabled: (prayer) => prayer != Prayer.fajr,
        reminders: (_) => [],
        windowDays: 3,
      );

      // Fajr adhan offsets 1, 10001, 20001 must be cancelled
      expect(plan.idsToCancel.contains(1), isTrue);
      expect(plan.idsToCancel.contains(10001), isTrue);
      expect(plan.idsToCancel.contains(20001), isTrue);

      // None of the alarms to set should be Fajr adhan
      expect(plan.alarmsToSet.any((a) => a.prayer == Prayer.fajr), isFalse);
    });

    test('reminder offsets (-10 before, +15 after)', () {
      final now = DateTime(2026, 4, 15, 3, 0);
      final plan = AdhanScheduler.planAlarms(
        now: now,
        getCalendar: (y) => y == 2026 ? calendar2026 : null,
        isPrayerEnabled: (_) => true,
        reminders: (prayer) {
          if (prayer == Prayer.fajr) {
            return [(slot: 1, minutes: -10), (slot: 2, minutes: 15)];
          }
          return [];
        },
        windowDays: 3,
      );

      // Fajr adhan is at 05:00
      // Slot 1 (-10): 04:50, id 101, 10101, 20101
      // Slot 2 (+15): 05:15, id 102, 10102, 20102
      final fajrRemindersDay0 = plan.alarmsToSet
          .where((a) => a.prayer == Prayer.fajr && a.kind == AlarmKind.reminder && a.time.day == 15)
          .toList();

      expect(fajrRemindersDay0.length, 2);

      final r1 = fajrRemindersDay0.firstWhere((a) => a.minutes == -10);
      expect(r1.id, 101);
      expect(r1.time, DateTime(2026, 4, 15, 4, 50));

      final r2 = fajrRemindersDay0.firstWhere((a) => a.minutes == 15);
      expect(r2.id, 102);
      expect(r2.time, DateTime(2026, 4, 15, 5, 15));

      final fajrRemindersDay1 = plan.alarmsToSet
          .where((a) => a.prayer == Prayer.fajr && a.kind == AlarmKind.reminder && a.time.day == 16)
          .toList();
      expect(fajrRemindersDay1.firstWhere((a) => a.minutes == -10).id, 10101);
      expect(fajrRemindersDay1.firstWhere((a) => a.minutes == 15).id, 10102);
    });
  });
}

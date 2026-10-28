import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/features/adhan/services/adhan_texts.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:permission_handler/permission_handler.dart';

enum AlarmKind { adhan, reminder }

class PlannedAlarm {
  final int id;
  final DateTime time;
  final AlarmKind kind;
  final Prayer prayer;
  final int minutes;

  const PlannedAlarm({
    required this.id,
    required this.time,
    required this.kind,
    required this.prayer,
    this.minutes = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedAlarm &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          time == other.time &&
          kind == other.kind &&
          prayer == other.prayer &&
          minutes == other.minutes;

  @override
  int get hashCode => Object.hash(id, time, kind, prayer, minutes);

  @override
  String toString() =>
      'PlannedAlarm(id: $id, time: $time, kind: $kind, prayer: ${prayer.key}, minutes: $minutes)';
}

typedef AlarmPlan = ({List<PlannedAlarm> alarmsToSet, List<int> idsToCancel});

int idFor(int baseId, int dayOffset) => baseId + dayOffset * 10000;
int baseOf(int id) => id % 10000;

class AdhanScheduler {
  AdhanScheduler._();

  static const int windowDays = 7;

  static int idFor(int baseId, int dayOffset) => baseId + dayOffset * 10000;
  static int baseOf(int id) => id % 10000;

  /// Rotating day slot, so a date keeps the same alarm ids from one launch to
  /// the next and an unchanged alarm is never re-set.
  static int slotOf(DateTime day, int windowDays) =>
      (DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay) %
      windowDays;

  /// Pure planning function.
  /// Inputs:
  /// - [now]: current time reference.
  /// - [getCalendar]: lookup for cached prayer calendar by year.
  /// - [isPrayerEnabled]: checks if a prayer is enabled.
  /// - [reminders]: active reminders for a prayer.
  /// - [windowDays]: rolling window in days (default: 3).
  static AlarmPlan planAlarms({
    required DateTime now,
    required PrayerTime? Function(int year) getCalendar,
    required bool Function(Prayer prayer) isPrayerEnabled,
    required List<({int slot, int minutes})> Function(Prayer prayer) reminders,
    int windowDays = windowDays,
  }) {
    final alarmsToSet = <PlannedAlarm>[];
    final idsToCancel = <int>[];

    for (final prayer in Prayer.all) {
      final enabled = isPrayerEnabled(prayer);
      if (!enabled) {
        for (var offset = 0; offset < windowDays; offset++) {
          idsToCancel.add(idFor(prayer.adhanId, offset));
        }
      }

      final activeReminders = reminders(prayer);
      final slot1 = activeReminders.where((r) => r.slot == 1).firstOrNull;
      final slot2 = activeReminders.where((r) => r.slot == 2).firstOrNull;

      if (!enabled || slot1 == null) {
        for (var offset = 0; offset < windowDays; offset++) {
          idsToCancel.add(idFor(prayer.alarmId1, offset));
        }
      }
      if (!enabled || slot2 == null) {
        for (var offset = 0; offset < windowDays; offset++) {
          idsToCancel.add(idFor(prayer.alarmId2, offset));
        }
      }

      for (var offset = 0; offset < windowDays; offset++) {
        final targetDate = DateTime(now.year, now.month, now.day + offset);
        final slot = slotOf(targetDate, windowDays);
        final calendar = getCalendar(targetDate.year);
        if (calendar == null) {
          // Missing day data (e.g. next year not cached) -> skip, never throw
          continue;
        }

        final monthKey = targetDate.month.toString();
        final dayList = calendar.data[monthKey];
        if (dayList == null) continue;

        final dayIndex = targetDate.day - 1;
        if (dayIndex < 0 || dayIndex >= dayList.length) continue;

        final datum = dayList[dayIndex];
        final timeStr = prayer.timeFromTimings(datum.timings);
        final prayerTime = _parseTiming(targetDate, timeStr);
        if (prayerTime == null) continue;

        if (enabled && prayerTime.isAfter(now)) {
          alarmsToSet.add(PlannedAlarm(
            id: idFor(prayer.adhanId, slot),
            time: prayerTime,
            kind: AlarmKind.adhan,
            prayer: prayer,
            minutes: 0,
          ));
        }

        if (enabled) {
          if (slot1 != null) {
            final reminderTime =
                prayerTime.add(Duration(minutes: slot1.minutes));
            if (reminderTime.isAfter(now)) {
              alarmsToSet.add(PlannedAlarm(
                id: idFor(prayer.alarmId1, slot),
                time: reminderTime,
                kind: AlarmKind.reminder,
                prayer: prayer,
                minutes: slot1.minutes,
              ));
            }
          }

          if (slot2 != null) {
            final reminderTime =
                prayerTime.add(Duration(minutes: slot2.minutes));
            if (reminderTime.isAfter(now)) {
              alarmsToSet.add(PlannedAlarm(
                id: idFor(prayer.alarmId2, slot),
                time: reminderTime,
                kind: AlarmKind.reminder,
                prayer: prayer,
                minutes: slot2.minutes,
              ));
            }
          }
        }
      }
    }

    return (alarmsToSet: alarmsToSet, idsToCancel: idsToCancel);
  }

  static DateTime? _parseTiming(DateTime date, String timeString) {
    try {
      final clean = timeString.trim().split(RegExp(r'\s+')).first;
      final parts = clean.split(':');
      if (parts.length < 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// Returns active reminders for [prayer] as (slot, minutes).
  static List<({int slot, int minutes})> reminders(Prayer prayer) {
    final result = <({int slot, int minutes})>[];
    if (AppPrefs.reminderActive(prayer.alarmId1)) {
      result.add(
          (slot: 1, minutes: AppPrefs.reminderMinutes(prayer.durationKey1)));
    }
    if (AppPrefs.reminderActive(prayer.alarmId2)) {
      result.add(
          (slot: 2, minutes: AppPrefs.reminderMinutes(prayer.durationKey2)));
    }
    return result;
  }

  /// Adds a reminder in the first free slot, saves to AppPrefs, and calls [sync].
  static Future<void> addReminder(Prayer prayer, int minutes) async {
    if (minutes == 0) return;
    if (!await Permission.notification.isGranted) {
      final status = await Permission.notification.request();
      if (!status.isGranted) return;
    }

    if (!AppPrefs.reminderActive(prayer.alarmId1)) {
      await AppPrefs.setReminder(prayer.alarmId1, prayer.durationKey1, minutes);
      await sync();
    } else if (!AppPrefs.reminderActive(prayer.alarmId2)) {
      await AppPrefs.setReminder(prayer.alarmId2, prayer.durationKey2, minutes);
      await sync();
    }
  }

  /// Clears reminder pref, cancels all its rolling offsets, and calls [sync].
  static Future<void> removeReminder(Prayer prayer, int slot) async {
    final alarmId = slot == 1 ? prayer.alarmId1 : prayer.alarmId2;
    final durationKey = slot == 1 ? prayer.durationKey1 : prayer.durationKey2;

    await AppPrefs.clearReminder(alarmId, durationKey);
    for (var offset = 0; offset < windowDays; offset++) {
      await Alarm.stop(idFor(alarmId, offset));
    }
    await sync();
  }

  // ponytail: serializes within one isolate only; the Workmanager isolate can still overlap, add a prefs lock if that bites
  static Future<void> _tail = Future.value();

  /// Single entry point to synchronize adhans and reminders for the rolling window.
  /// Runs are chained so overlapping callers never interleave cancels and sets.
  static Future<void> sync() {
    final run = _tail.then((_) => _sync());
    _tail = run.catchError((_) {});
    return run;
  }

  /// Starts the alarm plugin, then syncs. Alarm.init re-arms every stored
  /// alarm, so it goes on the same chain and later syncs wait for it.
  static Future<void> init() {
    _tail = _tail.then((_) => Alarm.init());
    return sync();
  }

  static Future<void> _sync() async {
    if (!await Permission.notification.isGranted) {
      return;
    }

    final now = DateTime.now();
    final currentYearJson = AppPrefs.prayerYearJson(now.year);
    if (currentYearJson == null || currentYearJson.isEmpty) {
      return;
    }

    // From Dec 24, try (best effort, never throw) to fetch next year's calendar
    if (now.month == 12 && now.day >= 24) {
      final nextYear = now.year + 1;
      if (AppPrefs.prayerYearJson(nextYear) == null) {
        final country = AppPrefs.country;
        final city = AppPrefs.city;
        if (country.isNotEmpty && city.isNotEmpty) {
          try {
            final response =
                await SHttpHelper.get(country, city, nextYear.toString());
            final pt = PrayerTime.fromJson(response);
            if (pt.code == 200) {
              await AppPrefs.setPrayerYearJson(nextYear, jsonEncode(pt));
            }
          } catch (_) {
            // best effort, never throw
          }
        }
      }
    }

    final texts = await AdhanTexts.load();

    final calendarCache = <int, PrayerTime?>{};
    PrayerTime? getCalendar(int year) {
      if (calendarCache.containsKey(year)) {
        return calendarCache[year];
      }
      final jsonStr = AppPrefs.prayerYearJson(year);
      if (jsonStr == null || jsonStr.isEmpty) {
        calendarCache[year] = null;
        return null;
      }
      try {
        final pt = PrayerTime.fromJson(jsonDecode(jsonStr));
        calendarCache[year] = pt;
        return pt;
      } catch (_) {
        calendarCache[year] = null;
        return null;
      }
    }

    final plan = planAlarms(
      now: now,
      getCalendar: getCalendar,
      isPrayerEnabled: (prayer) => AppPrefs.prayerEnabled(prayer.key),
      reminders: (prayer) => reminders(prayer),
      windowDays: windowDays,
    );

    // Diff against what is stored: every Alarm call is several platform round
    // trips and log lines, and on a normal launch nothing has changed.
    final stored = {for (final a in await Alarm.getAlarms()) a.id: a};
    final plannedIds = {for (final p in plan.alarmsToSet) p.id};
    final toCancel = plan.idsToCancel.toSet();
    for (final a in stored.values) {
      // Past alarms not asked for may be ringing; leave them to the plugin.
      if (plannedIds.contains(a.id)) continue;
      if (toCancel.contains(a.id) || a.dateTime.isAfter(now)) {
        await Alarm.stop(a.id);
      }
    }

    for (final planned in plan.alarmsToSet) {
      final String title;
      final String body;
      if (planned.kind == AlarmKind.adhan) {
        title = texts.adhanTitle(planned.prayer);
        body = texts.adhanBody(planned.prayer);
      } else {
        title = texts.reminderTitle(planned.prayer);
        body = texts.reminderBody(planned.prayer, planned.minutes);
      }

      final settings = AlarmSettings(
        id: planned.id,
        dateTime: planned.time,
        assetAudioPath: AppPrefs.adhanSoundPath,
        loopAudio: false,
        vibrate: false,
        volumeSettings: VolumeSettings.fade(
          fadeDuration: const Duration(seconds: 3),
          volume: 0.5,
        ),
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
          stopButton: texts.stopAdhan,
        ),
      );

      if (stored[planned.id] == settings) continue;
      await Alarm.set(alarmSettings: settings);
    }
  }
}

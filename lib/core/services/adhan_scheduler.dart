import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:flutter/services.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/core/services/adhan_texts.dart';
import 'package:noor/core/services/api/prayer_api.dart';
import 'package:noor/core/services/app_prefs.dart';
import 'package:permission_handler/permission_handler.dart';

enum AlarmKind { adhan, reminder }

class PrayerReminder {
  final int slot;
  final int minutes;
  final bool everyDay;
  final DateTime? date;

  const PrayerReminder({
    required this.slot,
    required this.minutes,
    this.everyDay = true,
    this.date,
  });

  Map<String, dynamic> toJson() => {
        'slot': slot,
        'minutes': minutes,
        'everyDay': everyDay,
        if (!everyDay && date != null)
          'date':
              '${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
      };

  factory PrayerReminder.fromJson(Map<String, dynamic> json) {
    final slot = (json['slot'] as num?)?.toInt() ?? 1;
    final minutes = (json['minutes'] as num?)?.toInt() ?? 0;
    final everyDay = json['everyDay'] as bool? ?? true;
    DateTime? date;
    final rawDate = json['date'] as String?;
    if (!everyDay && rawDate != null) {
      final parts = rawDate.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          date = DateTime(y, m, d);
        }
      }
    }
    final isDaily = everyDay || date == null;
    return PrayerReminder(
      slot: slot,
      minutes: minutes,
      everyDay: isDaily,
      date: isDaily ? null : date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerReminder &&
          runtimeType == other.runtimeType &&
          slot == other.slot &&
          minutes == other.minutes &&
          everyDay == other.everyDay &&
          date == other.date;

  @override
  int get hashCode => Object.hash(slot, minutes, everyDay, date);
}

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
  /// - [windowDays]: rolling window in days.
  static AlarmPlan planAlarms({
    required DateTime now,
    required PrayerTime? Function(int year) getCalendar,
    required bool Function(Prayer prayer) isPrayerEnabled,
    required List<({int slot, int minutes})> Function(Prayer prayer) reminders,
    List<PrayerReminder> Function(Prayer prayer)? savedReminders,
    int windowDays = windowDays,
  }) {
    final alarmsToSet = <PlannedAlarm>[];
    final idsToCancel = <int>[];
    final today = DateTime(now.year, now.month, now.day);
    final windowEnd = DateTime(now.year, now.month, now.day + windowDays - 1);

    DateTime? prayerTimeOn(Prayer prayer, DateTime targetDate) {
      final calendar = getCalendar(targetDate.year);
      if (calendar == null) return null;
      final monthKey = targetDate.month.toString();
      final dayList = calendar.data[monthKey];
      if (dayList == null) return null;
      final dayIndex = targetDate.day - 1;
      if (dayIndex < 0 || dayIndex >= dayList.length) return null;
      final datum = dayList[dayIndex];
      final timeStr = prayer.timeFromTimings(datum.timings);
      return parseTiming(targetDate, timeStr);
    }

    for (final prayer in Prayer.all) {
      final enabled = isPrayerEnabled(prayer);
      if (!enabled) {
        for (var offset = 0; offset < windowDays; offset++) {
          idsToCancel.add(idFor(prayer.adhanId, offset));
        }
      }

      final activeReminders = savedReminders != null
          ? savedReminders(prayer)
          : [
              for (final r in reminders(prayer))
                PrayerReminder(slot: r.slot, minutes: r.minutes),
            ];
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
      if (!enabled) {
        for (final r in activeReminders) {
          if (r.slot > 2) {
            for (var offset = 0; offset < windowDays; offset++) {
              idsToCancel.add(idFor(prayer.alarmIdForSlot(r.slot), offset));
            }
          }
        }
      }

      for (var offset = 0; offset < windowDays; offset++) {
        final targetDate = DateTime(now.year, now.month, now.day + offset);
        final slot = slotOf(targetDate, windowDays);
        final prayerTime = prayerTimeOn(prayer, targetDate);
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
          for (final r in activeReminders) {
            if (!r.everyDay) {
              final d = r.date;
              if (d == null ||
                  d.year != targetDate.year ||
                  d.month != targetDate.month ||
                  d.day != targetDate.day) {
                continue;
              }
            }
            final reminderTime = prayerTime.add(Duration(minutes: r.minutes));
            if (reminderTime.isAfter(now)) {
              alarmsToSet.add(PlannedAlarm(
                id: idFor(prayer.alarmIdForSlot(r.slot), slot),
                time: reminderTime,
                kind: AlarmKind.reminder,
                prayer: prayer,
                minutes: r.minutes,
              ));
            }
          }
        }
      }

      if (enabled) {
        for (final r in activeReminders) {
          if (r.everyDay || r.date == null) continue;
          final d = DateTime(r.date!.year, r.date!.month, r.date!.day);
          if (!d.isAfter(windowEnd) && !d.isBefore(today)) continue;
          if (d.isBefore(today)) continue;
          final prayerTime = prayerTimeOn(prayer, d);
          if (prayerTime == null) continue;
          final reminderTime = prayerTime.add(Duration(minutes: r.minutes));
          if (reminderTime.isAfter(now)) {
            alarmsToSet.add(PlannedAlarm(
              id: idFor(prayer.alarmIdForSlot(r.slot), slotOf(d, windowDays)),
              time: reminderTime,
              kind: AlarmKind.reminder,
              prayer: prayer,
              minutes: r.minutes,
            ));
          }
        }
      }
    }

    return (alarmsToSet: alarmsToSet, idsToCancel: idsToCancel);
  }

  /// The moment of an API time on this phone's clock; null when unreadable.
  /// An ISO 8601 time carries its own date and offset. An older "HH:mm (TZ)"
  /// one is read on [date] in the phone's time zone.
  static DateTime? parseTiming(DateTime date, String timeString) {
    final iso = _isoTime(timeString);
    if (iso != null) return iso.toLocal();
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

  static DateTime? _isoTime(String timeString) {
    final s = timeString.trim();
    return s.contains('T') ? DateTime.tryParse(s) : null;
  }

  /// "HH:mm" as the place's own clock reads it, from either format.
  static String clockOf(String timeString) {
    final s = timeString.trim();
    if (_isoTime(s) != null) return s.substring(11, 16);
    return s.split(RegExp(r'\s+')).first;
  }

  /// Returns active reminders for [prayer].
  static List<PrayerReminder> reminders(Prayer prayer) {
    final jsonStr = AppPrefs.prayerRemindersJson(prayer.key);
    if (jsonStr != null) {
      try {
        final rawList = jsonDecode(jsonStr) as List<dynamic>;
        return [
          for (final item in rawList)
            if (item is Map<String, dynamic>)
              PrayerReminder.fromJson(item)
            else if (item is Map)
              PrayerReminder.fromJson(Map<String, dynamic>.from(item)),
        ]..removeWhere((r) => r.minutes == 0);
      } catch (_) {}
    }

    final result = <PrayerReminder>[];
    if (AppPrefs.reminderActive(prayer.alarmId1)) {
      final m = AppPrefs.reminderMinutes(prayer.durationKey1);
      if (m != 0) result.add(PrayerReminder(slot: 1, minutes: m));
    }
    if (AppPrefs.reminderActive(prayer.alarmId2)) {
      final m = AppPrefs.reminderMinutes(prayer.durationKey2);
      if (m != 0) result.add(PrayerReminder(slot: 2, minutes: m));
    }
    return result;
  }

  static Future<void> _saveReminders(
    Prayer prayer,
    List<PrayerReminder> list,
  ) async {
    await AppPrefs.setPrayerRemindersJson(
      prayer.key,
      jsonEncode([for (final r in list) r.toJson()]),
    );
    final slot1 = list.where((r) => r.slot == 1).firstOrNull;
    if (slot1 != null) {
      await AppPrefs.setReminder(
          prayer.alarmId1, prayer.durationKey1, slot1.minutes);
    } else {
      await AppPrefs.clearReminder(prayer.alarmId1, prayer.durationKey1);
    }
    final slot2 = list.where((r) => r.slot == 2).firstOrNull;
    if (slot2 != null) {
      await AppPrefs.setReminder(
          prayer.alarmId2, prayer.durationKey2, slot2.minutes);
    } else {
      await AppPrefs.clearReminder(prayer.alarmId2, prayer.durationKey2);
    }
  }

  static Future<bool> _ensureNotificationPermission() async {
    try {
      if (!await Permission.notification.isGranted) {
        final status = await Permission.notification.request();
        if (!status.isGranted) return false;
      }
    } on MissingPluginException {
      // Host plugin unavailable in widget tests; allow persisting reminders.
    }
    return true;
  }

  /// Adds a reminder in the first free slot, saves to AppPrefs, and calls [sync].
  static Future<bool> addReminder(
    Prayer prayer,
    int minutes, {
    bool everyDay = true,
    DateTime? date,
  }) async {
    if (minutes == 0) return false;
    if (!await _ensureNotificationPermission()) return false;

    final current = List<PrayerReminder>.from(reminders(prayer));
    final usedSlots = {for (final r in current) r.slot};
    var slot = 1;
    while (usedSlots.contains(slot)) {
      slot++;
    }

    final normalizedDate = !everyDay && date != null
        ? DateTime(date.year, date.month, date.day)
        : null;
    current.add(PrayerReminder(
      slot: slot,
      minutes: minutes,
      everyDay: everyDay || normalizedDate == null,
      date: normalizedDate,
    ));

    await _saveReminders(prayer, current);
    await sync();
    return true;
  }

  /// Updates an existing reminder at [slot], saves to AppPrefs, and calls [sync].
  static Future<bool> updateReminder(
    Prayer prayer,
    int slot,
    int minutes, {
    bool everyDay = true,
    DateTime? date,
  }) async {
    if (minutes == 0) return false;
    if (!await _ensureNotificationPermission()) return false;

    final current = List<PrayerReminder>.from(reminders(prayer));
    final normalizedDate = !everyDay && date != null
        ? DateTime(date.year, date.month, date.day)
        : null;
    final updated = PrayerReminder(
      slot: slot,
      minutes: minutes,
      everyDay: everyDay || normalizedDate == null,
      date: normalizedDate,
    );

    final idx = current.indexWhere((r) => r.slot == slot);
    if (idx >= 0) {
      current[idx] = updated;
    } else {
      current.add(updated);
    }

    await _saveReminders(prayer, current);
    final baseId = prayer.alarmIdForSlot(slot);
    for (var offset = 0; offset < windowDays; offset++) {
      try {
        await Alarm.stop(idFor(baseId, offset));
      } on MissingPluginException {
        break;
      }
    }
    await sync();
    return true;
  }

  /// Clears reminder pref, cancels all its rolling offsets, and calls [sync].
  static Future<bool> removeReminder(Prayer prayer, int slot) async {
    final current = List<PrayerReminder>.from(reminders(prayer))
      ..removeWhere((r) => r.slot == slot);
    await _saveReminders(prayer, current);

    final alarmId = prayer.alarmIdForSlot(slot);
    for (var offset = 0; offset < windowDays; offset++) {
      try {
        await Alarm.stop(idFor(alarmId, offset));
      } on MissingPluginException {
        break;
      }
    }
    await sync();
    return true;
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
    try {
      if (!await Permission.notification.isGranted) {
        return;
      }
    } on MissingPluginException {
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
      if (AppPrefs.prayerYearJson(nextYear) == null &&
          AppPrefs.country.isNotEmpty &&
          AppPrefs.city.isNotEmpty) {
        try {
          final pt = await PrayerApi.fetchYear(nextYear);
          await AppPrefs.setPrayerYearJson(nextYear, jsonEncode(pt));
        } catch (_) {
          // best effort, never throw
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
      reminders: (prayer) => [
        for (final r in reminders(prayer)) (slot: r.slot, minutes: r.minutes)
      ],
      savedReminders: reminders,
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
          icon: 'ic_notification',
          iconColor: const Color(0xFF7A6436),
        ),
      );

      if (stored[planned.id] == settings) continue;
      await Alarm.set(alarmSettings: settings);
    }
  }
}

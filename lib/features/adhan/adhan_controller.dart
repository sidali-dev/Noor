import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/features/adhan/models/sub_models.dart/timings.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';

class AdhanController extends GetxController {
  final Rx<PrayerTime?> prayerTime = PrayerTime.empty().obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool isLoading = false.obs;

  late final RxBool adhanFajr = AppPrefs.prayerEnabled('fajr').obs;
  late final RxBool adhanChourouk = AppPrefs.prayerEnabled('chourouk').obs;
  late final RxBool adhanDhuhr = AppPrefs.prayerEnabled('dhuhr').obs;
  late final RxBool adhanAsr = AppPrefs.prayerEnabled('asr').obs;
  late final RxBool adhanMaghrib = AppPrefs.prayerEnabled('maghrib').obs;
  late final RxBool adhanIsha = AppPrefs.prayerEnabled('isha').obs;

  final LocationController locationController = Get.put(LocationController());

  @override
  void onInit() {
    super.onInit();
    initController(DateTime.now().year);
  }

  /// Returns the RxBool for a given prayer key.
  RxBool enabledFor(String key) {
    switch (key) {
      case 'fajr':
        return adhanFajr;
      case 'chourouk':
        return adhanChourouk;
      case 'dhuhr':
        return adhanDhuhr;
      case 'asr':
        return adhanAsr;
      case 'maghrib':
        return adhanMaghrib;
      case 'isha':
        return adhanIsha;
      default:
        throw ArgumentError('Unknown prayer key: $key');
    }
  }

  /// Toggles the prayer on/off state, persists it, and syncs alarms.
  Future<void> toggle(String key) async {
    final rx = enabledFor(key);
    final nextValue = !rx.value;
    await AppPrefs.setPrayerEnabled(key, nextValue);
    rx.value = nextValue;
    await AdhanScheduler.sync();
  }

  /// Fetches prayer data first; only on success persists location + calendar,
  /// then syncs alarms.
  Future<void> refreshAdhanData(
      String country, String state, String city, int year) async {
    isLoading.value = true;
    try {
      final response = await SHttpHelper.get(country, city, year.toString());
      final pt = PrayerTime.fromJson(response);

      // Persist only after successful fetch
      await AppPrefs.setLocation(country, state, city);
      locationController.country.value = country;
      locationController.state.value = state;
      locationController.city.value = city;

      await AppPrefs.setPrayerYearJson(year, jsonEncode(pt));
      prayerTime.value = pt;

      await AdhanScheduler.sync();
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns [Timings] for [d] from the active prayer calendar or cached calendar.
  Timings? timingsFor(DateTime d) {
    PrayerTime? pt = prayerTime.value;
    if (pt == null || pt.data.isEmpty) {
      final jsonStr = AppPrefs.prayerYearJson(d.year);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          pt = PrayerTime.fromJson(jsonDecode(jsonStr));
        } catch (_) {}
      }
    }
    if (pt == null || pt.data.isEmpty) return null;

    final monthList = pt.data[d.month.toString()];
    if (monthList == null) return null;

    final dayIndex = d.day - 1;
    if (dayIndex < 0 || dayIndex >= monthList.length) return null;

    return monthList[dayIndex].timings;
  }

  /// Timings for the currently selected [date].
  Timings? get selectedTimings => timingsFor(date.value);

  /// Calculates the next upcoming prayer from [from] (defaults to DateTime.now()).
  ({Prayer prayer, DateTime at, bool isTomorrow})? nextPrayer(
      [DateTime? from]) {
    final now = from ?? DateTime.now();

    final todayTimings = timingsFor(now);
    if (todayTimings != null) {
      for (final prayer in Prayer.all) {
        final timeStr = prayer.timeFromTimings(todayTimings);
        final pTime = _parseTiming(now, timeStr);
        if (pTime != null && pTime.isAfter(now)) {
          return (prayer: prayer, at: pTime, isTomorrow: false);
        }
      }
    }

    // Rollover to tomorrow
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final tomorrowTimings = timingsFor(tomorrow);
    if (tomorrowTimings != null) {
      for (final prayer in Prayer.all) {
        final timeStr = prayer.timeFromTimings(tomorrowTimings);
        final pTime = _parseTiming(tomorrow, timeStr);
        if (pTime != null) {
          return (prayer: prayer, at: pTime, isTomorrow: true);
        }
      }
    }

    return null;
  }

  static DateTime? _parseTiming(DateTime targetDate, String timeString) {
    try {
      final clean = timeString.trim().split(RegExp(r'\s+')).first;
      final parts = clean.split(':');
      if (parts.length < 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(
          targetDate.year, targetDate.month, targetDate.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  // ---- Deprecated delegates for backward compatibility ---------------------

  @Deprecated('Use AdhanScheduler.sync()')
  static Future<void> scheduleAdhans() => AdhanScheduler.sync();

  @Deprecated('Use toggle(prayerName)')
  Future<void> switchAdhan(String prayerName) async {
    await toggle(prayerName);
  }

  @Deprecated('Managed in onInit / refreshAdhanData')
  Future<void> initController(int year) async {
    locationController.getLocation();
    final jsonStr = AppPrefs.prayerYearJson(year);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        prayerTime.value = PrayerTime.fromJson(jsonDecode(jsonStr));
        return;
      } catch (_) {}
    }

    if (locationController.city.value.isNotEmpty) {
      try {
        await refreshAdhanData(
          locationController.country.value,
          locationController.state.value,
          locationController.city.value,
          year,
        );
      } catch (_) {}
    }
  }

  @Deprecated('Use refreshAdhanData')
  Future<void> getAdhanTimeCalendarByCity(int year) async {
    final response = await SHttpHelper.get(
      locationController.country.value,
      locationController.city.value,
      year.toString(),
    );
    prayerTime.value = PrayerTime.fromJson(response);
    await AppPrefs.setPrayerYearJson(year, jsonEncode(prayerTime.value));
  }

  void incrementDay() {
    date.value = date.value.add(const Duration(days: 1));
  }

  void decrementDay() {
    date.value = date.value.subtract(const Duration(days: 1));
  }
}

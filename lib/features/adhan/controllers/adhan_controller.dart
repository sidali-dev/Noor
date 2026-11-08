import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:noor/features/adhan/models/datum.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_settings.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/features/adhan/models/sub_models/timings.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:noor/core/services/api/prayer_api.dart';
import 'package:noor/core/services/location_service.dart';
import 'package:noor/core/services/app_prefs.dart';

class AdhanController extends GetxController {
  /// This year's calendar.
  final Rx<PrayerTime?> prayerTime = PrayerTime.empty().obs;
  final Rx<DateTime> date = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final Rx<PrayerSettings> settings = AppPrefs.prayerSettings.obs;

  /// Other years' calendars, read from prefs or fetched as the day arrows
  /// reach them.
  final Map<int, PrayerTime> _years = {};
  int _prayerTimeYear = DateTime.now().year;

  final Map<String, RxBool> _enabledPrayers = {
    for (final p in Prayer.all) p.key: AppPrefs.prayerEnabled(p.key).obs,
  };

  final LocationService locationController = Get.put(LocationService());

  @override
  void onInit() {
    super.onInit();
    initController(DateTime.now().year).then((_) => rollPastIsha());
    ever<DateTime>(date, (d) => ensureYear(d.year));
  }

  /// Returns the RxBool for a given prayer key.
  RxBool enabledFor(String key) {
    var rx = _enabledPrayers[key];
    if (rx == null) {
      rx = AppPrefs.prayerEnabled(key).obs;
      _enabledPrayers[key] = rx;
    }
    return rx;
  }

  /// Toggles the prayer on/off state, persists it, and syncs alarms.
  Future<void> toggle(String key) async {
    final rx = enabledFor(key);
    final nextValue = !rx.value;
    await AppPrefs.setPrayerEnabled(key, nextValue);
    rx.value = nextValue;
    await AdhanScheduler.sync();
  }

  bool get _hasLocation =>
      AppPrefs.country.isNotEmpty && AppPrefs.city.isNotEmpty;

  /// Fetches prayer data first; only on success persists location + calendar,
  /// then syncs alarms. [coordinates] are GPS's; without them the city is
  /// looked up by name.
  Future<void> refreshAdhanData(
      String country, String state, String city, int year,
      {Coordinates? coordinates}) async {
    isLoading.value = true;
    try {
      final pt = await PrayerApi.fetchYear(
        year,
        country: country,
        city: city,
        coordinates: coordinates,
        useSavedCoordinates: false,
      );

      // Persist only after successful fetch
      await AppPrefs.setLocation(country, state, city,
          coordinates: coordinates);
      locationController.country.value = country;
      locationController.state.value = state;
      locationController.city.value = city;

      await _replaceCalendars(year, pt);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches this year with [next]; only on success saves [next], replaces
  /// the cached years and syncs alarms.
  Future<void> applySettings(PrayerSettings next) async {
    isLoading.value = true;
    final year = DateTime.now().year;
    try {
      final pt = await PrayerApi.fetchYear(year, settings: next);
      await AppPrefs.setPrayerSettings(next);
      settings.value = next;
      await _replaceCalendars(year, pt);
    } finally {
      isLoading.value = false;
    }
    unawaited(ensureYear(date.value.year));
  }

  Future<void> _replaceCalendars(int year, PrayerTime pt) async {
    await AppPrefs.clearPrayerYears();
    await AppPrefs.setPrayerYearJson(year, jsonEncode(pt));
    _years
      ..clear()
      ..[year] = pt;
    _prayerTimeYear = year;
    prayerTime.value = pt;
    await AdhanScheduler.sync();
  }

  /// The calendar holding [year], or null before it has been fetched.
  PrayerTime? calendarFor(int year) {
    if (year == _prayerTimeYear) {
      final pt = prayerTime.value;
      if (pt != null && pt.data.isNotEmpty) return pt;
    }
    final known = _years[year];
    if (known != null) return known;
    final jsonStr = AppPrefs.prayerYearJson(year);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return _years[year] = PrayerTime.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  /// The calendar entry for [d]: its timings and dates.
  Datum? datumFor(DateTime d) {
    final monthList = calendarFor(d.year)?.data[d.month.toString()];
    if (monthList == null) return null;
    final dayIndex = d.day - 1;
    if (dayIndex < 0 || dayIndex >= monthList.length) return null;
    return monthList[dayIndex];
  }

  /// Returns [Timings] for [d] from the cached calendar of its year.
  Timings? timingsFor(DateTime d) => datumFor(d)?.timings;

  /// Timings for the currently selected [date].
  Timings? get selectedTimings => timingsFor(date.value);

  /// Fetches [year]'s calendar when the days shown reach a year not cached
  /// yet. Kept only for the years either side of this one.
  Future<void> ensureYear(int year) async {
    if (calendarFor(year) != null || !_hasLocation || isLoading.value) return;
    isLoading.value = true;
    try {
      final pt = await PrayerApi.fetchYear(year);
      _years[year] = pt;
      if ((year - DateTime.now().year).abs() <= 1) {
        await AppPrefs.setPrayerYearJson(year, jsonEncode(pt));
        unawaited(AdhanScheduler.sync());
      }
    } catch (_) {
      // The page shows the failure with a retry.
    } finally {
      isLoading.value = false;
    }
  }

  /// The failed page's retry: this year, then the year being looked at.
  Future<void> retry() async {
    await initController(DateTime.now().year);
    await ensureYear(date.value.year);
  }

  DateTime? _rolledFrom;

  /// Once today's last prayer has passed, moves the page on to tomorrow, whose
  /// Fajr is the next prayer. Once a day, so stepping back to today stays put.
  void rollPastIsha() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = nextPrayer(now);
    if (next == null || !next.isTomorrow || _rolledFrom == today) return;
    _rolledFrom = today;
    final d = date.value;
    if (DateTime(d.year, d.month, d.day) == today) {
      date.value = DateTime(now.year, now.month, now.day + 1);
    }
  }

  /// Calculates the next upcoming prayer from [from] (defaults to DateTime.now()).
  ({Prayer prayer, DateTime at, bool isTomorrow})? nextPrayer(
      [DateTime? from]) {
    final now = from ?? DateTime.now();

    final todayTimings = timingsFor(now);
    if (todayTimings != null) {
      for (final prayer in Prayer.all) {
        final timeStr = prayer.timeFromTimings(todayTimings);
        final pTime = AdhanScheduler.parseTiming(now, timeStr);
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
        final pTime = AdhanScheduler.parseTiming(tomorrow, timeStr);
        if (pTime != null) {
          return (prayer: prayer, at: pTime, isTomorrow: true);
        }
      }
    }

    return null;
  }

  /// Loads this year's calendar. One fetched for another place or other
  /// settings (or before times carried their offset) is shown at once and
  /// replaced in the background.
  Future<void> initController(int year) async {
    locationController.getLocation();
    final cached = calendarFor(year);
    if (cached != null) {
      _prayerTimeYear = year;
      prayerTime.value = cached;
      if (_hasLocation && cached.source != PrayerApi.currentSource()) {
        unawaited(_refreshQuietly(year));
      }
      return;
    }

    if (_hasLocation) {
      try {
        await refreshAdhanData(
          AppPrefs.country,
          AppPrefs.state,
          AppPrefs.city,
          year,
          coordinates: AppPrefs.coordinates,
        );
      } catch (_) {}
    }
  }

  Future<void> _refreshQuietly(int year) async {
    try {
      await _replaceCalendars(year, await PrayerApi.fetchYear(year));
    } catch (_) {
      // Keep the old calendar; the next launch tries again.
    }
  }

  // By calendar day: a picked date is local midnight, where adding 24 hours
  // lands on the wrong day across a DST change.
  void incrementDay() {
    final d = date.value;
    date.value = DateTime(d.year, d.month, d.day + 1);
  }

  void decrementDay() {
    final d = date.value;
    date.value = DateTime(d.year, d.month, d.day - 1);
  }
}

import 'dart:convert';

import 'package:noor/features/adhan/models/prayer_settings.dart';
import 'package:noor/utils/constants/shared_pref_keys.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';

/// The one typed door to SharedPreferences. Defaults live here and nowhere
/// else; getters never return null and never throw on wrongly typed values.
/// `SharedPrefService.init()` must have run first.
class AppPrefs {
  AppPrefs._();

  static const String defaultAdhanSoundPath =
      'assets/sounds/ahmad_alnafees.mp3';
  static const String defaultAdhanSoundName = 'أذان الشيخ النفيس';
  static const String defaultLanguage = 'ar';

  static const Map<String, bool> _prayerDefaults = {
    SharedPrefKeys.fajr: true,
    SharedPrefKeys.chourouk: false,
    SharedPrefKeys.dhuhr: true,
    SharedPrefKeys.asr: true,
    SharedPrefKeys.maghrib: true,
    SharedPrefKeys.isha: true,
  };

  // ---- safe typed reads ---------------------------------------------------

  static bool _bool(String key, bool fallback) {
    try {
      return SharedPrefService.getBool(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static String _string(String key, String fallback) {
    try {
      return SharedPrefService.getString(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static int? _int(String key) {
    try {
      return SharedPrefService.getInt(key);
    } catch (_) {
      // Stored with another type: accept a numeric string, else give up.
      try {
        return int.tryParse(SharedPrefService.getString(key) ?? '');
      } catch (_) {
        return null;
      }
    }
  }

  // ---- prayers ------------------------------------------------------------

  static bool prayerEnabled(String key) =>
      _bool(key, _prayerDefaults[key] ?? false);

  static Future<void> setPrayerEnabled(String key, bool value) =>
      SharedPrefService.setBool(key, value);

  // ---- reminders ----------------------------------------------------------

  static bool reminderActive(int alarmId) => _bool(alarmId.toString(), false);

  /// Minutes relative to the prayer (negative = before). Missing or
  /// non-numeric values read as 0.
  static int reminderMinutes(String durationKey) => _int(durationKey) ?? 0;

  static Future<void> setReminder(
      int alarmId, String durationKey, int minutes) async {
    await SharedPrefService.setBool(alarmId.toString(), true);
    await SharedPrefService.setInt(durationKey, minutes);
  }

  static Future<void> clearReminder(int alarmId, String durationKey) async {
    await SharedPrefService.setBool(alarmId.toString(), false);
    await SharedPrefService.setInt(durationKey, 0);
  }

  static String? prayerRemindersJson(String prayerKey) {
    try {
      return SharedPrefService.getString(
          SharedPrefKeys.prayerReminders(prayerKey));
    } catch (_) {
      return null;
    }
  }

  static Future<void> setPrayerRemindersJson(String prayerKey, String json) =>
      SharedPrefService.setString(
          SharedPrefKeys.prayerReminders(prayerKey), json);

  // ---- location -----------------------------------------------------------

  static String get country => _string(SharedPrefKeys.country, '');
  static String get state => _string(SharedPrefKeys.state, '');
  static String get city => _string(SharedPrefKeys.city, '');

  static double? _double(String key) {
    try {
      return SharedPrefService.getDouble(key);
    } catch (_) {
      return null;
    }
  }

  /// Where GPS put the user; null for a city picked by hand.
  static ({double latitude, double longitude})? get coordinates {
    final lat = _double(SharedPrefKeys.latitude);
    final lng = _double(SharedPrefKeys.longitude);
    return lat == null || lng == null ? null : (latitude: lat, longitude: lng);
  }

  /// Without [coordinates] the location counts as picked by hand, and any
  /// saved ones are dropped.
  static Future<void> setLocation(String country, String state, String city,
      {({double latitude, double longitude})? coordinates}) async {
    await SharedPrefService.setString(SharedPrefKeys.country, country);
    await SharedPrefService.setString(SharedPrefKeys.state, state);
    await SharedPrefService.setString(SharedPrefKeys.city, city);
    if (coordinates == null) {
      await SharedPrefService.remove(SharedPrefKeys.latitude);
      await SharedPrefService.remove(SharedPrefKeys.longitude);
    } else {
      await SharedPrefService.setDouble(
          SharedPrefKeys.latitude, coordinates.latitude);
      await SharedPrefService.setDouble(
          SharedPrefKeys.longitude, coordinates.longitude);
    }
  }

  // ---- prayer calculation -------------------------------------------------

  static PrayerSettings get prayerSettings {
    final raw = _string(SharedPrefKeys.prayerSettings, '');
    if (raw.isEmpty) return const PrayerSettings();
    try {
      return PrayerSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PrayerSettings();
    }
  }

  static Future<void> setPrayerSettings(PrayerSettings settings) =>
      SharedPrefService.setString(
          SharedPrefKeys.prayerSettings, jsonEncode(settings.toJson()));

  // ---- asma al-husna ------------------------------------------------------

  static String? get asmaAlHusnaJson {
    final raw = _string(SharedPrefKeys.asmaAlHusna, '');
    return raw.isEmpty ? null : raw;
  }

  static Future<void> setAsmaAlHusnaJson(String json) =>
      SharedPrefService.setString(SharedPrefKeys.asmaAlHusna, json);

  // ---- adhan sound --------------------------------------------------------

  static String get adhanSoundPath =>
      _string(SharedPrefKeys.adhanSoundPath, defaultAdhanSoundPath);
  static String get adhanSoundName =>
      _string(SharedPrefKeys.adhanSoundName, defaultAdhanSoundName);

  static Future<void> setAdhanSoundPath(String value) =>
      SharedPrefService.setString(SharedPrefKeys.adhanSoundPath, value);
  static Future<void> setAdhanSoundName(String value) =>
      SharedPrefService.setString(SharedPrefKeys.adhanSoundName, value);

  // ---- quran --------------------------------------------------------------

  static int get lastReadPage {
    final page = _int(SharedPrefKeys.lastReadQuran) ?? 1;
    return page < 1 ? 1 : page;
  }

  static Future<void> setLastReadPage(int page) =>
      SharedPrefService.setInt(SharedPrefKeys.lastReadQuran, page);

  static List<int> get bookmarks =>
      parseBookmarks(_string(SharedPrefKeys.quranBookmark, ''));

  static Future<void> setBookmarks(List<int> pages) =>
      SharedPrefService.setString(
          SharedPrefKeys.quranBookmark, serializeBookmarks(pages));

  /// `"12--x-45-"` -> `[12, 45]`. Skips empty, non-numeric and non-positive
  /// parts.
  static List<int> parseBookmarks(String raw) => [
        for (final part in raw.split('-'))
          if ((int.tryParse(part.trim()) ?? 0) > 0) int.parse(part.trim()),
      ];

  static String serializeBookmarks(List<int> pages) => pages.join('-');

  static String get quranReadPages =>
      _string(SharedPrefKeys.quranReadPages, '');

  static Future<void> setQuranReadPages(String value) =>
      SharedPrefService.setString(SharedPrefKeys.quranReadPages, value);

  // ---- app settings -------------------------------------------------------

  static String get languageCode =>
      _string(SharedPrefKeys.language, defaultLanguage);

  static Future<void> setLanguage(String code) =>
      SharedPrefService.setString(SharedPrefKeys.language, code);

  static bool get isDark => _bool(SharedPrefKeys.isDarkTheme, false);

  static Future<void> setIsDark(bool value) =>
      SharedPrefService.setBool(SharedPrefKeys.isDarkTheme, value);

  // ---- prayer calendar cache ---------------------------------------------

  static String? prayerYearJson(int year) {
    try {
      final json = SharedPrefService.getString(SharedPrefKeys.adhanYear(year));
      return json == null ? null : _undoLatin1(json);
    } catch (_) {
      return null;
    }
  }

  /// Calendars saved by older versions hold UTF-8 bytes misread as Latin-1.
  /// Good text doesn't survive this round trip, so it comes back as it was.
  static String _undoLatin1(String text) {
    try {
      return utf8.decode(latin1.encode(text));
    } catch (_) {
      return text;
    }
  }

  static Future<void> setPrayerYearJson(int year, String json) =>
      SharedPrefService.setString(SharedPrefKeys.adhanYear(year), json);

  /// Drops every cached year: they were calculated for another place or
  /// other settings.
  static Future<void> clearPrayerYears() async {
    final keys = SharedPrefService.getKeys()
        .where(SharedPrefKeys.adhanYearPattern.hasMatch)
        .toList();
    for (final key in keys) {
      await SharedPrefService.remove(key);
    }
  }
}

/// Every SharedPreferences key the app uses, spelled exactly as already stored
/// on users' devices. Never rename a value here: that would orphan saved data.
class SharedPrefKeys {
  SharedPrefKeys._();

  // Prayer on/off flags (bool).
  static const String fajr = 'fajr';
  static const String chourouk = 'chourouk';
  static const String dhuhr = 'dhuhr';
  static const String asr = 'asr';
  static const String maghrib = 'maghrib';
  static const String isha = 'isha';

  // Reminder active flags (bool); the key is the alarm id as a string.
  static const String reminder101 = '101';
  static const String reminder102 = '102';
  static const String reminder201 = '201';
  static const String reminder202 = '202';
  static const String reminder301 = '301';
  static const String reminder302 = '302';
  static const String reminder401 = '401';
  static const String reminder402 = '402';
  static const String reminder501 = '501';
  static const String reminder502 = '502';
  static const String reminder601 = '601';
  static const String reminder602 = '602';

  // Reminder offsets in minutes (int, negative = before the prayer).
  static const String fajrAlarm1Duration = 'fajr_alarm_1_duration';
  static const String fajrAlarm2Duration = 'fajr_alarm_2_duration';
  static const String chouroukAlarm1Duration = 'chourouk_alarm_1_duration';
  static const String chouroukAlarm2Duration = 'chourouk_alarm_2_duration';
  static const String dhuhrAlarm1Duration = 'dhuhr_alarm_1_duration';
  static const String dhuhrAlarm2Duration = 'dhuhr_alarm_2_duration';
  static const String asrAlarm1Duration = 'asr_alarm_1_duration';
  static const String asrAlarm2Duration = 'asr_alarm_2_duration';
  static const String maghribAlarm1Duration = 'maghrib_alarm_1_duration';
  static const String maghribAlarm2Duration = 'maghrib_alarm_2_duration';
  static const String ishaAlarm1Duration = 'isha_alarm_1_duration';
  static const String ishaAlarm2Duration = 'isha_alarm_2_duration';

  // Location (String).
  static const String country = 'country';
  static const String state = 'state';
  static const String city = 'city';

  // Adhan sound (String).
  static const String adhanSoundPath = 'adhan_sound_path';
  static const String adhanSoundName = 'adhan_sound_name';

  // Quran.
  static const String lastReadQuran = 'last_read_quran';
  static const String quranBookmark = 'quran_bookmark';
  static const String quranReadPages = 'quran_read_pages';

  // App settings.
  static const String language = 'language';
  static const String isDarkTheme = 'isDarkTheme';
  static const String isFirstRun = 'isFirstRun';

  /// Cached prayer calendar for a year (JSON String), e.g. `Adhan2026`.
  static String adhanYear(int year) => 'Adhan$year';
}

import 'package:flutter_test/flutter_test.dart';
import 'package:noor/utils/constants/shared_pref_keys.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _useStore(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  SharedPrefService.resetForTest();
  await SharedPrefService.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('defaults on an empty store', () {
    setUp(() => _useStore({}));

    test('prayers', () {
      for (final k in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        expect(AppPrefs.prayerEnabled(k), isTrue, reason: k);
      }
      expect(AppPrefs.prayerEnabled('chourouk'), isFalse);
      expect(AppPrefs.prayerEnabled('unknown'), isFalse);
    });

    test('everything else', () {
      expect(AppPrefs.reminderActive(101), isFalse);
      expect(AppPrefs.reminderMinutes('fajr_alarm_1_duration'), 0);
      expect(AppPrefs.country, '');
      expect(AppPrefs.state, '');
      expect(AppPrefs.city, '');
      expect(AppPrefs.adhanSoundPath, 'assets/sounds/ahmad_alnafees.mp3');
      expect(AppPrefs.adhanSoundName, 'أذان الشيخ النفيس');
      expect(AppPrefs.lastReadPage, 1);
      expect(AppPrefs.bookmarks, isEmpty);
      expect(AppPrefs.languageCode, 'ar');
      expect(AppPrefs.isDark, isFalse);
      expect(AppPrefs.prayerYearJson(2026), isNull);
      expect(AppPrefs.quranReadPages, '');
    });
  });

  group('round trips', () {
    setUp(() => _useStore({}));

    test('prayer flags', () async {
      await AppPrefs.setPrayerEnabled('chourouk', true);
      await AppPrefs.setPrayerEnabled('fajr', false);
      expect(AppPrefs.prayerEnabled('chourouk'), isTrue);
      expect(AppPrefs.prayerEnabled('fajr'), isFalse);
    });

    test('reminders, including negative offsets', () async {
      await AppPrefs.setReminder(101, 'fajr_alarm_1_duration', -10);
      expect(AppPrefs.reminderActive(101), isTrue);
      expect(AppPrefs.reminderMinutes('fajr_alarm_1_duration'), -10);
      expect(AppPrefs.reminderActive(102), isFalse);

      await AppPrefs.clearReminder(101, 'fajr_alarm_1_duration');
      expect(AppPrefs.reminderActive(101), isFalse);
      expect(AppPrefs.reminderMinutes('fajr_alarm_1_duration'), 0);
    });

    test('location, sound, quran, settings, calendar', () async {
      await AppPrefs.setLocation('Algeria', 'Algiers', 'Bab Ezzouar');
      expect([AppPrefs.country, AppPrefs.state, AppPrefs.city],
          ['Algeria', 'Algiers', 'Bab Ezzouar']);

      await AppPrefs.setAdhanSoundPath('assets/sounds/x.mp3');
      await AppPrefs.setAdhanSoundName('X');
      expect(AppPrefs.adhanSoundPath, 'assets/sounds/x.mp3');
      expect(AppPrefs.adhanSoundName, 'X');

      await AppPrefs.setLastReadPage(77);
      expect(AppPrefs.lastReadPage, 77);

      await AppPrefs.setBookmarks([3, 12, 604]);
      expect(AppPrefs.bookmarks, [3, 12, 604]);

      await AppPrefs.setLanguage('fr');
      expect(AppPrefs.languageCode, 'fr');
      await AppPrefs.setIsDark(true);
      expect(AppPrefs.isDark, isTrue);

      await AppPrefs.setPrayerYearJson(2026, '{"a":1}');
      expect(AppPrefs.prayerYearJson(2026), '{"a":1}');
      expect(AppPrefs.prayerYearJson(2027), isNull);

      await AppPrefs.setQuranReadPages('0101');
      expect(AppPrefs.quranReadPages, '0101');
    });
  });

  group('bookmark parsing', () {
    test('parse', () {
      expect(AppPrefs.parseBookmarks(''), isEmpty);
      expect(AppPrefs.parseBookmarks('12'), [12]);
      expect(AppPrefs.parseBookmarks('12-45'), [12, 45]);
      expect(AppPrefs.parseBookmarks('12-45-'), [12, 45]);
      expect(AppPrefs.parseBookmarks('-12-45'), [12, 45]);
      expect(AppPrefs.parseBookmarks('12--x-45-'), [12, 45]);
      expect(AppPrefs.parseBookmarks('x-y-0'), isEmpty);
      expect(AppPrefs.parseBookmarks('---'), isEmpty);
    });

    test('serialise', () {
      expect(AppPrefs.serializeBookmarks([]), '');
      expect(AppPrefs.serializeBookmarks([7]), '7');
      expect(AppPrefs.serializeBookmarks([12, 45]), '12-45');
    });

    test('garbage in the store reads clean', () async {
      await _useStore({SharedPrefKeys.quranBookmark: '12--x-45-'});
      expect(AppPrefs.bookmarks, [12, 45]);
    });
  });

  group('garbage tolerance', () {
    test('wrong types fall back to defaults', () async {
      await _useStore({
        'fajr': 'yes',
        'fajr_alarm_1_duration': 'abc',
        'fajr_alarm_2_duration': '25',
        'last_read_quran': 'oops',
        'country': 5,
        'isDarkTheme': 'true',
      });
      expect(AppPrefs.prayerEnabled('fajr'), isTrue); // default, not a throw
      expect(AppPrefs.reminderMinutes('fajr_alarm_1_duration'), 0);
      expect(AppPrefs.reminderMinutes('fajr_alarm_2_duration'), 25);
      expect(AppPrefs.lastReadPage, 1);
      expect(AppPrefs.country, '');
      expect(AppPrefs.isDark, isFalse);
    });

    test('non-positive last read page reads as 1', () async {
      await _useStore({'last_read_quran': -4});
      expect(AppPrefs.lastReadPage, 1);
    });
  });

  group('compatibility with data written by the old code', () {
    test('reads and writes the same keys and formats', () async {
      await _useStore({
        'fajr': true,
        'chourouk': true,
        'dhuhr': false,
        'asr': true,
        'maghrib': true,
        'isha': false,
        '101': true,
        'fajr_alarm_1_duration': -10,
        '602': true,
        'isha_alarm_2_duration': 15,
        'country': 'Algeria',
        'state': 'Algiers',
        'city': 'Algiers',
        'adhan_sound_path': 'assets/sounds/other.mp3',
        'adhan_sound_name': 'Other',
        'last_read_quran': 250,
        'quran_bookmark': '5-250-604',
        'language': 'en',
        'isDarkTheme': true,
        'Adhan2026': '{"data":{}}',
      });

      expect(AppPrefs.prayerEnabled('chourouk'), isTrue);
      expect(AppPrefs.prayerEnabled('dhuhr'), isFalse);
      expect(AppPrefs.prayerEnabled('isha'), isFalse);
      expect(AppPrefs.reminderActive(101), isTrue);
      expect(AppPrefs.reminderMinutes('fajr_alarm_1_duration'), -10);
      expect(AppPrefs.reminderActive(602), isTrue);
      expect(AppPrefs.reminderMinutes('isha_alarm_2_duration'), 15);
      expect(AppPrefs.country, 'Algeria');
      expect(AppPrefs.city, 'Algiers');
      expect(AppPrefs.adhanSoundPath, 'assets/sounds/other.mp3');
      expect(AppPrefs.adhanSoundName, 'Other');
      expect(AppPrefs.lastReadPage, 250);
      expect(AppPrefs.bookmarks, [5, 250, 604]);
      expect(AppPrefs.languageCode, 'en');
      expect(AppPrefs.isDark, isTrue);
      expect(AppPrefs.prayerYearJson(2026), '{"data":{}}');
    });

    test('writes land under the old key names and formats', () async {
      await _useStore({});
      await AppPrefs.setPrayerEnabled('asr', false);
      await AppPrefs.setReminder(401, 'asr_alarm_1_duration', 20);
      await AppPrefs.setLocation('A', 'B', 'C');
      await AppPrefs.setLastReadPage(9);
      await AppPrefs.setBookmarks([1, 2]);
      await AppPrefs.setLanguage('fr');
      await AppPrefs.setIsDark(true);
      await AppPrefs.setPrayerYearJson(2030, 'j');

      expect(SharedPrefService.getBool('asr'), isFalse);
      expect(SharedPrefService.getBool('401'), isTrue);
      expect(SharedPrefService.getInt('asr_alarm_1_duration'), 20);
      expect(SharedPrefService.getString('country'), 'A');
      expect(SharedPrefService.getString('state'), 'B');
      expect(SharedPrefService.getString('city'), 'C');
      expect(SharedPrefService.getInt('last_read_quran'), 9);
      expect(SharedPrefService.getString('quran_bookmark'), '1-2');
      expect(SharedPrefService.getString('language'), 'fr');
      expect(SharedPrefService.getBool('isDarkTheme'), isTrue);
      expect(SharedPrefService.getString('Adhan2030'), 'j');
    });

    test('key constants keep their on-disk spelling', () {
      expect(SharedPrefKeys.adhanYear(2026), 'Adhan2026');
      expect(SharedPrefKeys.quranReadPages, 'quran_read_pages');
      expect(SharedPrefKeys.reminder602, '602');
      expect(
          SharedPrefKeys.chouroukAlarm2Duration, 'chourouk_alarm_2_duration');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/quran/data/quran_progress.dart';
import 'package:noor/utils/constants/shared_pref_keys.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _useStore(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  SharedPrefService.resetForTest();
  await SharedPrefService.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranProgress', () {
    setUp(() => _useStore({}));

    test('initial state on empty store', () {
      expect(QuranProgress.readCount, 0);
      expect(QuranProgress.overallFraction, 0.0);
      expect(QuranProgress.isRead(1), isFalse);
      expect(QuranProgress.isRead(604), isFalse);
      expect(QuranProgress.isRead(0), isFalse);
      expect(QuranProgress.isRead(605), isFalse);
      expect(QuranProgress.surahFraction(1), 0.0);
      expect(QuranProgress.surahFraction(2), 0.0);
    });

    test('markRead and idempotent mark', () async {
      await QuranProgress.markRead(5);
      expect(QuranProgress.isRead(5), isTrue);
      expect(QuranProgress.isRead(4), isFalse);
      expect(QuranProgress.isRead(6), isFalse);
      expect(QuranProgress.readCount, 1);
      expect(QuranProgress.overallFraction, closeTo(1 / 604, 0.0001));

      // Idempotent mark on same page
      await QuranProgress.markRead(5);
      expect(QuranProgress.isRead(5), isTrue);
      expect(QuranProgress.readCount, 1);
      expect(QuranProgress.overallFraction, closeTo(1 / 604, 0.0001));

      // Mark another page
      await QuranProgress.markRead(10);
      expect(QuranProgress.isRead(10), isTrue);
      expect(QuranProgress.readCount, 2);
      expect(QuranProgress.overallFraction, closeTo(2 / 604, 0.0001));
    });

    test('surahFraction for 1-page and multi-page surahs', () async {
      // Surah Al-Fatihah (1) is 1 page: page 1
      final fatihahPages = quran.getSurahPages(1);
      expect(fatihahPages.length, 1);
      expect(fatihahPages.first, 1);

      expect(QuranProgress.surahFraction(1), 0.0);
      await QuranProgress.markRead(1);
      expect(QuranProgress.surahFraction(1), 1.0);

      // Surah Al-Baqarah (2) is multi-page (pages 2 to 49)
      final baqarahPages = quran.getSurahPages(2);
      expect(baqarahPages.length, greaterThan(1));
      expect(QuranProgress.surahFraction(2), 0.0);

      // Mark first page of Al-Baqarah (page 2)
      await QuranProgress.markRead(baqarahPages[0]);
      expect(
        QuranProgress.surahFraction(2),
        closeTo(1 / baqarahPages.length, 0.0001),
      );

      // Mark second page of Al-Baqarah
      await QuranProgress.markRead(baqarahPages[1]);
      expect(
        QuranProgress.surahFraction(2),
        closeTo(2 / baqarahPages.length, 0.0001),
      );
    });

    test('overall progress and reset', () async {
      await QuranProgress.markRead(1);
      await QuranProgress.markRead(2);
      await QuranProgress.markRead(3);
      expect(QuranProgress.readCount, 3);
      expect(QuranProgress.overallFraction, closeTo(3 / 604, 0.0001));

      await QuranProgress.reset();
      expect(AppPrefs.quranReadPages, '');
      expect(QuranProgress.readCount, 0);
      expect(QuranProgress.overallFraction, 0.0);
      expect(QuranProgress.isRead(1), isFalse);
      expect(QuranProgress.isRead(2), isFalse);
    });

    test('safely handles corrupted or short stored string', () async {
      // Store malformed shorter string containing junk
      await _useStore({
        SharedPrefKeys.quranReadPages: '10x_garbage_short',
      });

      // Character at index 0 ('1') is page 1, other characters ('0', 'x', etc.) read as unread
      expect(QuranProgress.isRead(1), isTrue);
      expect(QuranProgress.isRead(2), isFalse);
      expect(QuranProgress.isRead(3), isFalse);
      expect(QuranProgress.isRead(50), isFalse);

      // markRead repairs the string to 604 characters
      await QuranProgress.markRead(50);
      expect(QuranProgress.isRead(50), isTrue);
      expect(QuranProgress.isRead(1), isTrue);
      expect(AppPrefs.quranReadPages.length, 604);
      expect(AppPrefs.quranReadPages[0], '1');
      expect(AppPrefs.quranReadPages[49], '1');
      // All other characters should be '0'
      final ones = AppPrefs.quranReadPages.codeUnits.where((c) => c == 0x31).length;
      expect(ones, 2);
    });

    test('safely handles overly long corrupted stored string', () async {
      // Over 700 chars of garbage with a '1' at index 603 (page 604) and index 650 (out of bounds)
      final longJunk = '1' * 700;
      await _useStore({
        SharedPrefKeys.quranReadPages: longJunk,
      });

      // Only 604 pages are recognized
      expect(QuranProgress.readCount, 604);
      expect(QuranProgress.overallFraction, 1.0);
      expect(QuranProgress.isRead(604), isTrue);
      expect(QuranProgress.isRead(605), isFalse); // out of bounds
    });

    test('ignores invalid page numbers in markRead', () async {
      await QuranProgress.markRead(0);
      await QuranProgress.markRead(-1);
      await QuranProgress.markRead(605);
      expect(QuranProgress.readCount, 0);
    });
  });
}

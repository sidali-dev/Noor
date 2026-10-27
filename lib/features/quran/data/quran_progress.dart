import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:quran/quran.dart' as quran;

/// Pages actually read, persisted as a 604-character `0/1` string in
/// `AppPrefs.quranReadPages`. Garbage is tolerated: the stored value is padded
/// or truncated to 604 characters and anything other than `1` reads as unread.
class QuranProgress {
  QuranProgress._();

  static const int totalPages = 604;

  static String _read() {
    final raw = AppPrefs.quranReadPages;
    final buf = StringBuffer();
    for (var i = 0; i < totalPages; i++) {
      buf.write(i < raw.length && raw[i] == '1' ? '1' : '0');
    }
    return buf.toString();
  }

  static bool _validPage(int page) => page >= 1 && page <= totalPages;

  static bool isRead(int page) => _validPage(page) && _read()[page - 1] == '1';

  /// Idempotent; out-of-range pages are ignored.
  static Future<void> markRead(int page) async {
    if (!_validPage(page)) return;
    final s = _read();
    if (s[page - 1] == '1') {
      if (AppPrefs.quranReadPages.length != totalPages) {
        await AppPrefs.setQuranReadPages(s); // repair a malformed value
      }
      return;
    }
    await AppPrefs.setQuranReadPages(
        '${s.substring(0, page - 1)}1${s.substring(page)}');
  }

  static int get readCount => _read().codeUnits.where((c) => c == 0x31).length;

  static double get overallFraction => readCount / totalPages;

  /// Read pages of the surah / pages of the surah, 0..1.
  static double surahFraction(int surah) {
    if (surah < 1 || surah > 114) return 0;
    final pages = quran.getSurahPages(surah);
    if (pages.isEmpty) return 0;
    final s = _read();
    var read = 0;
    for (final p in pages) {
      if (_validPage(p) && s[p - 1] == '1') read++;
    }
    return read / pages.length;
  }

  static Future<void> reset() => AppPrefs.setQuranReadPages('');
}

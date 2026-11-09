import 'package:noor/core/utils/text_normalize.dart';
import 'package:quran/quran.dart' as quran;

class QuranAyahHit {
  final int surah;
  final int ayah;
  final int page;
  final String snippet;

  const QuranAyahHit({
    required this.surah,
    required this.ayah,
    required this.page,
    required this.snippet,
  });
}

class _AyahEntry {
  final int surah;
  final int ayah;
  final int page;
  final String original;
  final String normalized;
  final String normalizedModern;
  final List<int> origins;

  const _AyahEntry({
    required this.surah,
    required this.ayah,
    required this.page,
    required this.original,
    required this.normalized,
    required this.normalizedModern,
    required this.origins,
  });
}

/// Full-text search across all 6,236 ayahs of the Quran, built lazily on first
/// query and kept in memory.
class QuranSearch {
  QuranSearch._();

  static final QuranSearch instance = QuranSearch._();

  static const int minQueryLength = 2;
  static const int maxHits = 25;
  static const int snippetLength = 85;

  List<_AyahEntry>? _index;

  List<_AyahEntry> _ensureIndex() {
    if (_index != null) return _index!;
    final entries = <_AyahEntry>[];
    for (var page = 1; page <= quran.totalPagesCount; page++) {
      final blocks = quran.getPageData(page);
      for (final block in blocks) {
        final s = block['surah'] as int;
        final start = block['start'] as int;
        final end = block['end'] as int;
        for (var v = start; v <= end; v++) {
          final raw = quran.getVerse(s, v);
          final n = normalizeWithMap(raw);
          // Uthmani script writes dagger alef (U+0670) where modern standard
          // Arabic often writes a full alef (e.g. ٱلۡعَٰلَمِينَ -> العالمين).
          final modern =
              normalizeArabic(raw.replaceAll('\u0670', '\u0627'));
          entries.add(_AyahEntry(
            surah: s,
            ayah: v,
            page: page,
            original: raw,
            normalized: n.text,
            normalizedModern: modern,
            origins: n.origins,
          ));
        }
      }
    }
    _index = entries;
    return entries;
  }

  List<QuranAyahHit> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return const [];

    // Support direct "surah:ayah" reference lookup (e.g. "2:255" or "18:10").
    final refMatch = RegExp(r'^(\d{1,3})\s*[:/]\s*(\d{1,3})$').firstMatch(q);
    if (refMatch != null) {
      final s = int.tryParse(refMatch.group(1)!) ?? 0;
      final v = int.tryParse(refMatch.group(2)!) ?? 0;
      if (s >= 1 && s <= 114 && v >= 1 && v <= quran.getVerseCount(s)) {
        final page = quran.getPageNumber(s, v);
        final text = quran.getVerse(s, v);
        return [
          QuranAyahHit(
            surah: s,
            ayah: v,
            page: page,
            snippet: _snippet(text, 0),
          ),
        ];
      }
    }

    final nq = normalizeArabic(q).trim();
    if (nq.length < minQueryLength) return const [];

    final index = _ensureIndex();
    final hits = <QuranAyahHit>[];
    for (final e in index) {
      var at = e.normalized.indexOf(nq);
      if (at < 0) {
        at = e.normalizedModern.indexOf(nq);
      }
      if (at < 0) continue;
      final origAt = at < e.origins.length ? e.origins[at] : 0;
      hits.add(QuranAyahHit(
        surah: e.surah,
        ayah: e.ayah,
        page: e.page,
        snippet: _snippet(e.original, origAt),
      ));
      if (hits.length >= maxHits) break;
    }
    return hits;
  }

  static final RegExp _spaces = RegExp(r'\s+');

  static String _snippet(String text, int matchStart) {
    var start = matchStart - snippetLength ~/ 3;
    if (start < 0) start = 0;
    var end = start + snippetLength;
    if (end > text.length) {
      end = text.length;
      start = end - snippetLength < 0 ? 0 : end - snippetLength;
    }
    final body = text.substring(start, end).replaceAll(_spaces, ' ').trim();
    return '${start > 0 ? '…' : ''}$body${end < text.length ? '…' : ''}';
  }
}


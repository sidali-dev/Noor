import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart' as quran;

enum MushafLineType {
  surahHeader,
  basmala,
  ayah,
}

class MushafSegment {
  final int surah;
  final int ayah;
  final String text;
  final bool isEnd;

  const MushafSegment({
    required this.surah,
    required this.ayah,
    required this.text,
    required this.isEnd,
  });

  factory MushafSegment.fromMap(Map<String, dynamic> map) {
    return MushafSegment(
      surah: map['s'] as int,
      ayah: map['v'] as int,
      text: map['x'] as String,
      isEnd: (map['e'] as bool?) ?? false,
    );
  }
}

class MushafLine {
  final MushafLineType type;
  final int? surah;
  final bool centered;
  final List<MushafSegment> segments;

  const MushafLine({
    required this.type,
    this.surah,
    this.centered = false,
    this.segments = const [],
  });

  factory MushafLine.fromMap(Map<String, dynamic> map) {
    final t = map['t'] as String;
    if (t == 'h') {
      return MushafLine(
        type: MushafLineType.surahHeader,
        surah: map['s'] as int,
        centered: true,
      );
    }
    if (t == 'b') {
      return MushafLine(
        type: MushafLineType.basmala,
        surah: map['s'] as int,
        centered: true,
      );
    }
    final rawSegs = map['g'] as List<dynamic>? ?? const [];
    return MushafLine(
      type: MushafLineType.ayah,
      centered: (map['c'] as int?) == 1,
      segments: [
        for (final s in rawSegs)
          MushafSegment.fromMap(s as Map<String, dynamic>),
      ],
    );
  }
}

class MushafPageData {
  final int pageNumber;
  final List<MushafLine> lines;

  const MushafPageData({
    required this.pageNumber,
    required this.lines,
  });

  factory MushafPageData.fromMap(Map<String, dynamic> map) {
    final rawLines = map['l'] as List<dynamic>;
    return MushafPageData(
      pageNumber: map['p'] as int,
      lines: [
        for (final l in rawLines)
          MushafLine.fromMap(l as Map<String, dynamic>),
      ],
    );
  }

  /// Ordered list of unique `(surah, ayah)` pairs that appear on this page.
  List<({int surah, int ayah})> get ayahs {
    final seen = <String>{};
    final out = <({int surah, int ayah})>[];
    for (final line in lines) {
      for (final seg in line.segments) {
        final key = '${seg.surah}:${seg.ayah}';
        if (seen.add(key)) {
          out.add((surah: seg.surah, ayah: seg.ayah));
        }
      }
    }
    return out;
  }
}

/// 15-line Madinah Mushaf layout data, loaded once from
/// `assets/data/mushaf_15lines.json` (with a synchronous fallback built from
/// `quran.getPageData` if accessed in a widget test before `init()` runs).
class MushafData {
  MushafData._();

  static List<MushafPageData>? _pages;

  static Future<void> init() async {
    if (_pages != null) return;
    try {
      final raw = await rootBundle.loadString('assets/data/mushaf_15lines.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _pages = [
        for (final item in list)
          MushafPageData.fromMap(item as Map<String, dynamic>),
      ];
    } catch (_) {
      // Fallback if asset bundle is unavailable in isolated unit tests.
    }
  }

  static MushafPageData page(int pageNumber) {
    final clamped = pageNumber.clamp(1, quran.totalPagesCount);
    final pages = _pages;
    if (pages != null && clamped <= pages.length) {
      return pages[clamped - 1];
    }
    return _buildFallbackPage(clamped);
  }

  // ---- Synchronous fallback (identical 15-line algorithm for tests) -------

  static MushafPageData _buildFallbackPage(int pageNumber) {
    final rawBlocks = quran.getPageData(pageNumber);
    if (pageNumber == 1) {
      final words7 = quran.getVerse(1, 7).split(RegExp(r'\s+'));
      final mid = (words7.length * 0.52).round();
      return MushafPageData(
        pageNumber: 1,
        lines: [
          const MushafLine(
              type: MushafLineType.surahHeader, surah: 1, centered: true),
          for (var v = 1; v <= 6; v++)
            MushafLine(
              type: MushafLineType.ayah,
              centered: true,
              segments: [
                MushafSegment(
                    surah: 1, ayah: v, text: quran.getVerse(1, v), isEnd: true),
              ],
            ),
          MushafLine(
            type: MushafLineType.ayah,
            centered: true,
            segments: [
              MushafSegment(
                  surah: 1,
                  ayah: 7,
                  text: words7.sublist(0, mid).join(' '),
                  isEnd: false),
            ],
          ),
          MushafLine(
            type: MushafLineType.ayah,
            centered: true,
            segments: [
              MushafSegment(
                  surah: 1,
                  ayah: 7,
                  text: words7.sublist(mid).join(' '),
                  isEnd: true),
            ],
          ),
        ],
      );
    }

    if (pageNumber == 2) {
      final blocks = _parseBlocks(rawBlocks);
      final partitioned = _partitionWords(blocks.first.words, 6);
      return MushafPageData(
        pageNumber: 2,
        lines: [
          const MushafLine(
              type: MushafLineType.surahHeader, surah: 2, centered: true),
          const MushafLine(
              type: MushafLineType.basmala, surah: 2, centered: true),
          for (final wl in partitioned)
            MushafLine(
              type: MushafLineType.ayah,
              centered: true,
              segments: _mergeSegments(wl),
            ),
        ],
      );
    }

    final blocks = _parseBlocks(rawBlocks);
    var overhead = 0;
    for (final b in blocks) {
      if (b.hasHeader) overhead++;
      if (b.hasBasmala) overhead++;
    }
    final avail = (15 - overhead).clamp(blocks.length, 15);
    final totalW = blocks.fold(0, (s, b) => s + b.totalWeight);
    final counts = List<int>.filled(blocks.length, 1);
    var rem = avail - blocks.length;
    if (rem > 0 && totalW > 0) {
      final extras = [
        for (final b in blocks) (b.totalWeight / totalW) * rem,
      ];
      for (var i = 0; i < blocks.length; i++) {
        final add = extras[i].floor();
        counts[i] += add;
        rem -= add;
      }
      final idx = List<int>.generate(blocks.length, (i) => i)
        ..sort((a, b) => (extras[b] - extras[b].floor())
            .compareTo(extras[a] - extras[a].floor()));
      for (var i = 0; i < rem; i++) {
        counts[idx[i % idx.length]]++;
      }
    }

    final lines = <MushafLine>[];
    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      if (b.hasHeader) {
        lines.add(MushafLine(
            type: MushafLineType.surahHeader, surah: b.surah, centered: true));
      }
      if (b.hasBasmala) {
        lines.add(MushafLine(
            type: MushafLineType.basmala, surah: b.surah, centered: true));
      }
      for (final wl in _partitionWords(b.words, counts[i])) {
        lines.add(MushafLine(
          type: MushafLineType.ayah,
          segments: _mergeSegments(wl),
        ));
      }
    }
    return MushafPageData(pageNumber: pageNumber, lines: lines);
  }

  static List<_Block> _parseBlocks(List rawBlocks) {
    final out = <_Block>[];
    for (final raw in rawBlocks) {
      final surah = raw['surah'] as int;
      final start = raw['start'] as int;
      final end = raw['end'] as int;
      final words = <_Word>[];
      for (var v = start; v <= end; v++) {
        final parts = quran.getVerse(surah, v).trim().split(RegExp(r'\s+'));
        for (var i = 0; i < parts.length; i++) {
          words.add(_Word(surah, v, parts[i], i == parts.length - 1));
        }
      }
      out.add(_Block(
        surah: surah,
        hasHeader: start == 1,
        hasBasmala: start == 1 && surah != 1 && surah != 9,
        words: words,
      ));
    }
    return out;
  }

  static List<List<_Word>> _partitionWords(List<_Word> words, int k) {
    final n = words.length;
    if (k <= 1 || n <= 1) return [words];
    if (k >= n) return [for (final w in words) [w]];

    final prefix = List<int>.filled(n + 1, 0);
    for (var i = 0; i < n; i++) {
      prefix[i + 1] = prefix[i] + words[i].weight;
    }
    final target = prefix[n] / k;
    final dp = List.generate(
        k + 1, (_) => List<double>.filled(n + 1, double.infinity));
    final parent = List.generate(k + 1, (_) => List<int>.filled(n + 1, 0));
    dp[0][0] = 0;

    for (var line = 1; line <= k; line++) {
      for (var i = line; i <= n - (k - line); i++) {
        for (var prev = line - 1; prev < i; prev++) {
          final diff = (prefix[i] - prefix[prev]) - target;
          final cost = dp[line - 1][prev] + diff * diff;
          if (cost < dp[line][i]) {
            dp[line][i] = cost;
            parent[line][i] = prev;
          }
        }
      }
    }

    final res = List<List<_Word>>.filled(k, const []);
    var curr = n;
    for (var line = k; line >= 1; line--) {
      final prev = parent[line][curr];
      res[line - 1] = words.sublist(prev, curr);
      curr = prev;
    }
    return res;
  }

  static List<MushafSegment> _mergeSegments(List<_Word> words) {
    final out = <MushafSegment>[];
    if (words.isEmpty) return out;
    var curS = words.first.surah;
    var curV = words.first.ayah;
    final buf = <String>[];
    var end = false;

    void flush() {
      if (buf.isEmpty) return;
      out.add(MushafSegment(
          surah: curS, ayah: curV, text: buf.join(' '), isEnd: end));
      buf.clear();
      end = false;
    }

    for (final w in words) {
      if (w.surah != curS || w.ayah != curV) {
        flush();
        curS = w.surah;
        curV = w.ayah;
      }
      buf.add(w.text);
      if (w.isEnd) {
        end = true;
        flush();
      }
    }
    flush();
    return out;
  }
}

class _Word {
  final int surah;
  final int ayah;
  final String text;
  final bool isEnd;

  const _Word(this.surah, this.ayah, this.text, this.isEnd);

  int get weight {
    var c = 0;
    for (final r in text.runes) {
      if ((r >= 0x064B && r <= 0x065F) ||
          r == 0x0670 ||
          (r >= 0x06D6 && r <= 0x06ED)) {
        continue;
      }
      c++;
    }
    return c.clamp(1, 20) + (isEnd ? 3 : 1);
  }
}

class _Block {
  final int surah;
  final bool hasHeader;
  final bool hasBasmala;
  final List<_Word> words;

  const _Block({
    required this.surah,
    required this.hasHeader,
    required this.hasBasmala,
    required this.words,
  });

  int get totalWeight => words.fold(0, (s, w) => s + w.weight);
}


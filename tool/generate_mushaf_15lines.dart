import 'dart:convert';
import 'dart:io';

/// Standalone Pure-Dart generator for `assets/data/mushaf_15lines.json`.
/// Reads the `quran` package's `quran_text.dart` and `page_data.dart` directly
/// so it needs no Flutter compilation.
void main() {
  const quranLib =
      r'C:/Users/ECC STORE/AppData/Local/Pub/Cache/hosted/pub.dev/quran-1.3.0/lib';

  final verses = _loadVerses(File('$quranLib/quran_text.dart'));
  final pageData = _loadPageData(File('$quranLib/page_data.dart'));

  final pages = <Map<String, dynamic>>[];
  for (var i = 0; i < pageData.length; i++) {
    pages.add(_buildPage(i + 1, pageData[i] as List<dynamic>, verses));
  }

  final out = File('assets/data/mushaf_15lines.json');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(jsonEncode(pages));
  stdout.writeln(
    'Generated ${out.path} (${pages.length} pages, ${out.lengthSync()} bytes)',
  );
}

Map<(int, int), String> _loadVerses(File file) {
  final raw = file.readAsStringSync();
  final re = RegExp(
    r'\{\s*"surah_number":\s*(\d+),\s*"verse_number":\s*(\d+),\s*"content":\s*"([^"]+)"\s*\}',
    multiLine: true,
  );
  final out = <(int, int), String>{};
  for (final m in re.allMatches(raw)) {
    final s = int.parse(m.group(1)!);
    final v = int.parse(m.group(2)!);
    out[(s, v)] = m.group(3)!;
  }
  if (out.length != 6236) {
    throw StateError('Expected 6236 verses, got ${out.length}');
  }
  return out;
}

List<dynamic> _loadPageData(File file) {
  final raw = file.readAsStringSync();
  final start = raw.indexOf('[');
  final end = raw.lastIndexOf(']');
  final list = jsonDecode(raw.substring(start, end + 1)) as List<dynamic>;
  if (list.length != 604) {
    throw StateError('Expected 604 pages, got ${list.length}');
  }
  return list;
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

Map<String, dynamic> _buildPage(
  int pageNum,
  List<dynamic> rawBlocks,
  Map<(int, int), String> verses,
) {
  if (pageNum == 1) {
    final w7 = verses[(1, 7)]!.split(RegExp(r'\s+'));
    final mid = (w7.length * 0.52).round();
    final lines = <Map<String, dynamic>>[
      {'t': 'h', 's': 1},
      for (var v = 1; v <= 6; v++)
        {
          't': 'a',
          'c': 1,
          'g': [
            {'s': 1, 'v': v, 'x': verses[(1, v)]!, 'e': true}
          ],
        },
      {
        't': 'a',
        'c': 1,
        'g': [
          {'s': 1, 'v': 7, 'x': w7.sublist(0, mid).join(' ')}
        ],
      },
      {
        't': 'a',
        'c': 1,
        'g': [
          {'s': 1, 'v': 7, 'x': w7.sublist(mid).join(' '), 'e': true}
        ],
      },
    ];
    return {'p': 1, 'l': lines};
  }

  final blocks = _parseBlocks(rawBlocks, verses);
  if (pageNum == 2) {
    final part = _partitionWords(blocks.first.words, 6);
    final lines = <Map<String, dynamic>>[
      {'t': 'h', 's': 2},
      {'t': 'b', 's': 2},
      for (final wl in part) {'t': 'a', 'c': 1, 'g': _mergeSegments(wl)},
    ];
    return {'p': 2, 'l': lines};
  }

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

  final lines = <Map<String, dynamic>>[];
  for (var i = 0; i < blocks.length; i++) {
    final b = blocks[i];
    if (b.hasHeader) {
      lines.add({'t': 'h', 's': b.surah});
    }
    if (b.hasBasmala) {
      lines.add({'t': 'b', 's': b.surah});
    }
    for (final wl in _partitionWords(b.words, counts[i])) {
      lines.add({'t': 'a', 'g': _mergeSegments(wl)});
    }
  }
  return {'p': pageNum, 'l': lines};
}

List<_Block> _parseBlocks(
  List<dynamic> rawBlocks,
  Map<(int, int), String> verses,
) {
  final out = <_Block>[];
  for (final raw in rawBlocks) {
    final m = raw as Map<String, dynamic>;
    final surah = m['surah'] as int;
    final start = m['start'] as int;
    final end = m['end'] as int;
    final words = <_Word>[];
    for (var v = start; v <= end; v++) {
      final parts = verses[(surah, v)]!.trim().split(RegExp(r'\s+'));
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

List<List<_Word>> _partitionWords(List<_Word> words, int k) {
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

List<Map<String, dynamic>> _mergeSegments(List<_Word> words) {
  final out = <Map<String, dynamic>>[];
  if (words.isEmpty) return out;
  var curS = words.first.surah;
  var curV = words.first.ayah;
  final buf = <String>[];
  var end = false;

  void flush() {
    if (buf.isEmpty) return;
    out.add({
      's': curS,
      'v': curV,
      'x': buf.join(' '),
      if (end) 'e': true,
    });
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

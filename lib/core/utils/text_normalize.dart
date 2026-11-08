/// Pure-Dart text normalisation used by search.
///
/// Arabic: strips tashkeel (U+064B..U+065F), dagger alef (U+0670) and tatweel
/// (U+0640); unifies alef forms (أ إ آ ٱ -> ا), ى -> ي and ة -> ه.
/// Latin: lowercases and strips common accents ("Médine" -> "medine").
library;

const Map<String, String> _latinFold = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'æ': 'ae',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ō': 'o',
  'œ': 'oe',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ß': 'ss',
};

/// Folds one UTF-16 unit; returns '' for characters that are dropped.
String _foldUnit(String ch) {
  final code = ch.codeUnitAt(0);
  if ((code >= 0x064B && code <= 0x065F) || code == 0x0670 || code == 0x0640) {
    return '';
  }
  switch (code) {
    case 0x0623: // أ
    case 0x0625: // إ
    case 0x0622: // آ
    case 0x0671: // ٱ
      return '\u0627';
    case 0x0649: // ى
      return '\u064A';
    case 0x0629: // ة
      return '\u0647';
  }
  if (code < 0x80) return ch.toLowerCase();
  final lower = ch.toLowerCase();
  return _latinFold[lower] ?? lower;
}

/// Normalised text plus, for each normalised unit, the offset of the original
/// character it came from (used to cut snippets from the original text).
({String text, List<int> origins}) normalizeWithMap(String input) {
  final out = StringBuffer();
  final origins = <int>[];
  for (var i = 0; i < input.length; i++) {
    final folded = _foldUnit(input[i]);
    for (var k = 0; k < folded.length; k++) {
      origins.add(i);
    }
    out.write(folded);
  }
  return (text: out.toString(), origins: origins);
}

String normalizeArabic(String input) => normalizeWithMap(input).text;

/// True when the normalised [query] occurs in the normalised [text].
/// An empty (or blank) query matches everything.
bool matchesQuery(String text, String query) {
  final q = normalizeArabic(query).trim();
  if (q.isEmpty) return true;
  return normalizeArabic(text).contains(q);
}

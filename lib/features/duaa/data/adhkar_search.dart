import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/features/duaa/data/adhkar_data.dart';
import 'package:noor/utils/text_normalize.dart';

class AdhkarHit {
  const AdhkarHit({
    required this.type,
    required this.indexInType,
    required this.snippet,
  });

  /// `dhikr_type` of the category the hit belongs to.
  final int type;

  /// Position within the category, in the order `AdhkarData.byType` returns.
  final int indexInType;

  /// About 80 characters of the original text around the first match.
  final String snippet;
}

class _Entry {
  _Entry(this.type, this.indexInType, this.original, this.normalized,
      this.origins);
  final int type;
  final int indexInType;
  final String original;
  final String normalized;
  final List<int> origins;
}

/// Search over every dhikr text. The normalised index is built lazily from
/// [AdhkarData] on first use and kept in memory.
class AdhkarSearch {
  AdhkarSearch({Future<List<AdhkarModel>> Function()? loader})
      : _loader = loader ?? (() async => AdhkarData.all);

  /// Test hook: search over the given rows instead of [AdhkarData].
  AdhkarSearch.withRows(List<AdhkarModel> rows) : _loader = (() async => rows);

  static final AdhkarSearch instance = AdhkarSearch();

  static const int minQueryLength = 2;
  static const int maxHits = 20;
  static const int snippetLength = 80;

  final Future<List<AdhkarModel>> Function() _loader;
  Future<List<_Entry>>? _index;

  Future<List<_Entry>> _build() async {
    final rows = await _loader();
    final perType = <int, int>{};
    final entries = <_Entry>[];
    for (final row in rows) {
      final i = perType.update(row.dhikrType, (v) => v + 1, ifAbsent: () => 0);
      final n = normalizeWithMap(row.dhikrContent);
      entries
          .add(_Entry(row.dhikrType, i, row.dhikrContent, n.text, n.origins));
    }
    return entries;
  }

  Future<List<AdhkarHit>> search(String q) async {
    final nq = normalizeArabic(q).trim();
    if (nq.length < minQueryLength) return const [];

    final index = await (_index ??= _build().catchError((Object e) {
      _index = null; // allow a retry after a failed load
      throw e;
    }));

    final hits = <AdhkarHit>[];
    for (final e in index) {
      final at = e.normalized.indexOf(nq);
      if (at < 0) continue;
      hits.add(AdhkarHit(
        type: e.type,
        indexInType: e.indexInType,
        snippet: _snippet(e.original, e.origins[at]),
      ));
      if (hits.length >= maxHits) break;
    }
    return hits;
  }

  static final RegExp _spaces = RegExp(r'\s+');

  /// ~[snippetLength] characters of [text] around [matchStart], with a little
  /// lead-in before the match.
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

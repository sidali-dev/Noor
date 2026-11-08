const List<int> hizbStartPages = [
  1,
  11,
  22,
  32,
  42,
  51,
  62,
  72,
  82,
  92,
  102,
  112,
  121,
  132,
  142,
  151,
  162,
  173,
  182,
  192,
  201,
  212,
  222,
  231,
  242,
  252,
  262,
  272,
  282,
  292,
  302,
  312,
  322,
  332,
  342,
  352,
  362,
  371,
  382,
  392,
  402,
  413,
  422,
  431,
  442,
  451,
  462,
  472,
  482,
  491,
  502,
  513,
  522,
  531,
  542,
  553,
  562,
  572,
  582,
  591,
];

int hizbStartPage(int hizb) {
  if (hizb < 1) return hizbStartPages.first;
  if (hizb > hizbStartPages.length) return hizbStartPages.last;
  return hizbStartPages[hizb - 1];
}

/// The hizb (1-60) a page falls in.
int hizbOfPage(int page) {
  final i = hizbStartPages.lastIndexWhere((start) => start <= page);
  return i < 0 ? 1 : i + 1;
}

/// The first and last page of the juz (1-30) the page falls in: two hizbs each.
(int, int) juzPagesOf(int page) {
  final juz = (hizbOfPage(page) + 1) ~/ 2;
  final first = hizbStartPages[2 * juz - 2];
  final last = juz == 30 ? 604 : hizbStartPages[2 * juz] - 1;
  return (first, last);
}

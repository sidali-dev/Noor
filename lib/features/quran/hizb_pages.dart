const List<int> hizbStartPages = [
  2, 12, 23, 33, 43, 52, 63, 73, 83, 93,
  103, 113, 122, 133, 143, 152, 163, 174, 183, 193,
  202, 213, 223, 232, 243, 253, 263, 273, 283, 293,
  303, 313, 323, 333, 343, 353, 363, 372, 383, 393,
  403, 414, 423, 432, 443, 452, 463, 473, 483, 492,
  503, 514, 523, 532, 543, 554, 563, 573, 583, 592,
];

int hizbStartPage(int hizb) {
  if (hizb < 1) return hizbStartPages.first;
  if (hizb > hizbStartPages.length) return hizbStartPages.last;
  return hizbStartPages[hizb - 1];
}

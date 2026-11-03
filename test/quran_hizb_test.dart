import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/quran/hizb_pages.dart';

void main() {
  group('hizbStartPages', () {
    test('has exactly 60 values', () {
      expect(hizbStartPages.length, 60);
    });

    test('all values are strictly ascending within 1..604', () {
      for (var i = 0; i < hizbStartPages.length; i++) {
        final page = hizbStartPages[i];
        expect(page, greaterThanOrEqualTo(1));
        expect(page, lessThanOrEqualTo(604));

        if (i > 0) {
          expect(page, greaterThan(hizbStartPages[i - 1]));
        }
      }
    });

    test('hizbStartPage helper maps hizb indices correctly', () {
      expect(hizbStartPage(1), 1);
      expect(hizbStartPage(2), 11);
      expect(hizbStartPage(60), 591);
      expect(hizbStartPage(3), 22); // Baqarah 2:142
      // Boundary safety
      expect(hizbStartPage(0), 1);
      expect(hizbStartPage(61), 591);
    });
  });

  test('hizbOfPage and juzPagesOf cover every page, two hizbs to a juz', () {
    expect(hizbOfPage(1), 1);
    expect(hizbOfPage(11), 2);
    expect(hizbOfPage(604), 60);
    expect(juzPagesOf(1), (1, 21));
    expect(juzPagesOf(22), (22, 41));
    expect(juzPagesOf(604), (582, 604));
    var expectedFirst = 1;
    for (var p = 1; p <= 604; p++) {
      final (first, last) = juzPagesOf(p);
      expect(p, inInclusiveRange(first, last));
      if (p == first) expect(first, expectedFirst);
      if (p == last) expectedFirst = last + 1;
    }
  });
}

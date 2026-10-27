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
      expect(hizbStartPage(1), 2);
      expect(hizbStartPage(2), 12);
      expect(hizbStartPage(60), 592);
      // Boundary safety
      expect(hizbStartPage(0), 2);
      expect(hizbStartPage(61), 592);
    });
  });
}

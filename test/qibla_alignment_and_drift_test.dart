import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/qibla/widgets/qibla_compass.dart';
import 'package:noor/generals/location_drift.dart';

void main() {
  test('angleError folds any heading into 0..180', () {
    expect(QiblaCompass.angleError(0), 0);
    expect(QiblaCompass.angleError(359), closeTo(1, 1e-9));
    expect(QiblaCompass.angleError(-2), closeTo(2, 1e-9));
    expect(QiblaCompass.angleError(720 + 181), closeTo(179, 1e-9));
  });

  test('alignment uses hysteresis', () {
    expect(QiblaCompass.nextAligned(false, 4), isFalse);
    expect(QiblaCompass.nextAligned(false, -2.5), isTrue);
    expect(QiblaCompass.nextAligned(true, 5), isTrue); // stays on
    expect(QiblaCompass.nextAligned(true, 357), isTrue);
    expect(QiblaCompass.nextAligned(true, 7), isFalse);
  });

  test('shiftMinutes: suffixes, midnight wrap, bad values', () {
    expect(shiftMinutes(['05:12 (CET)', '13:00'], ['05:10', '13:07 (WAT)']), 7);
    expect(shiftMinutes(['23:58'], ['00:03']), 5);
    expect(shiftMinutes(['--', '12:00'], ['04:00', '12:01']), 1);
    expect(shiftMinutes(['x'], ['y']), isNull);
  });
}

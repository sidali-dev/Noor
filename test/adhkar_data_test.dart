import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/duaa/data/adhkar_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('adhkar.json loads and groups by type', () async {
    await AdhkarData.init();
    expect(AdhkarData.all.length, 313);
    expect(AdhkarData.counts.length, 19);
    expect(AdhkarData.counts.values.reduce((a, b) => a + b), 313);
    expect(AdhkarData.byType(1).every((a) => a.dhikrType == 1), isTrue);
    expect(AdhkarData.byType(999), isEmpty);
  });
}

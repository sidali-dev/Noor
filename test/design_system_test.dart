import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // DESIGN.md section 8: an icon button is a NoorCloudButton, so a new screen
  // cannot drift back to Material's.
  test('no screen draws its own icon button', () {
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            file.readAsStringSync().contains('IconButton('))
          file.path,
    ];
    expect(offenders, isEmpty);
  });
}

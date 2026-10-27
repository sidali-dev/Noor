import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/utils/theme/noor_theme.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final themes = {
    'light': NoorTheme.light(),
    'dark': NoorTheme.dark(),
  };

  for (final entry in themes.entries) {
    group('NoorTheme.${entry.key}', () {
      final theme = entry.value;
      final n = theme.extension<NoorColors>();

      test('has the NoorColors extension', () {
        expect(n, isNotNull);
      });

      test('body on card >= 4.5:1', () {
        expect(contrast(n!.body, n.card), greaterThanOrEqualTo(4.5));
      });

      test('muted on card >= 4.5:1', () {
        expect(contrast(n!.muted, n.card), greaterThanOrEqualTo(4.5));
      });

      test('onPrimary on primary >= 4.5:1', () {
        expect(contrast(n!.onPrimary, n.primary), greaterThanOrEqualTo(4.5));
      });
    });
  }
}

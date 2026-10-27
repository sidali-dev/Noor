import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:noor/utils/constants/image_strings.dart';

void main() {
  // Dark variants are not checked yet (ui-plan.md 1.2 "Interim state").
  const kb = 1024;
  final webp = {
    NoorArt.heroPrayers: 200 * kb,
    NoorArt.heroQuran: 200 * kb,
    NoorArt.heroAthkar: 200 * kb,
    NoorArt.qiblaSkyline: 200 * kb,
    NoorArt.splashTop: 300 * kb,
    NoorArt.splashBottom: 300 * kb,
  };

  for (final e in webp.entries) {
    test('${e.key}_light.webp exists and fits ${e.value ~/ kb} KB', () {
      final f = File('${e.key}_light.webp');
      expect(f.existsSync(), isTrue, reason: '${f.path} is missing');
      expect(f.lengthSync(), lessThanOrEqualTo(e.value));
    });
  }

  for (final p in [
    NoorArt.emblem,
    NoorArt.emblemDark,
    NoorArt.surahCartouche,
    NoorArt.pageCorner,
    NoorArt.divider,
    'assets/logo/app_icon.png',
    'assets/logo/app_icon_foreground.png',
  ]) {
    test('$p exists', () => expect(File(p).existsSync(), isTrue));
  }
}

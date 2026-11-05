import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_sky.dart';
import 'package:noor/utils/constants/image_strings.dart';

void main() {
  for (final p in [
    NoorArt.markPaper,
    NoorArt.markNight,
    NoorArt.surahCartouche,
    NoorArt.pageCorner,
    NoorArt.divider,
    NoorArt.objectMosque,
    NoorArt.objectQuran,
    NoorArt.objectSabha,
    NoorArt.qiblaKaaba,
    for (final sky in NoorSky.values) sky.asset,
    'assets/logo/app_icon.png',
    'assets/logo/app_icon_foreground.png',
  ]) {
    test('$p exists', () => expect(File(p).existsSync(), isTrue));
  }

  // The hero twinkle repaints the stars from a table; it must follow the art.
  final path = RegExp(r'<path fill="#f7f7f4" d="([^"]*)"/>');
  final star = RegExp(r'M[\d.]+ [\d.]+Q([\d.]+) ([\d.]+) ([\d.]+) [\d.]+');
  for (final sky in noorHeroStars.keys) {
    test('${sky.name} stars match noorHeroStars', () {
      final svg = File(sky.asset).readAsStringSync();
      final found = [
        for (final p in path.allMatches(svg))
          for (final m in star.allMatches(p[1]!))
            (
              double.parse(m[1]!),
              double.parse(m[2]!),
              double.parse(m[3]!) - double.parse(m[1]!),
            ),
      ];
      final table = noorHeroStars[sky]!;
      expect(found.length, table.length);
      for (var i = 0; i < table.length; i++) {
        expect(found[i].$1, closeTo(table[i].$1, 0.01));
        expect(found[i].$2, closeTo(table[i].$2, 0.01));
        expect(found[i].$3, closeTo(table[i].$3, 0.01));
      }
    });
  }
}

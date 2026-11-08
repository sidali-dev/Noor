import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/widgets/noor_sky.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/theme/app_theme.dart';

void main() {
  for (final p in [
    NoorArt.markPaper,
    NoorArt.markNight,
    NoorArt.surahCartouche,
    NoorArt.pageCorner,
    NoorArt.divider,
    NoorArt.separator,
    for (final variant in const ['paper', 'night']) ...[
      for (final hero in NoorArt.heroes) NoorArt.frame(hero, variant),
      NoorArt.clouds(variant),
      NoorArt.band(variant),
      NoorArt.ornament(variant),
      NoorArt.disc(variant),
    ],
    for (final sky in NoorSky.values) sky.asset,
    'assets/logo/app_icon.png',
    'assets/logo/app_icon_foreground.png',
  ]) {
    test('$p exists', () => expect(File(p).existsSync(), isTrue));
  }

  // The baked frames are opaque paper around the window: if the palette moves
  // and they do not, a seam shows round every one. Re-run tool/hero_art.py.
  Future<ByteData> pixels(String path) async {
    final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
    final image = (await codec.getNextFrame()).image;
    expect(image.width % 4, 0, reason: path);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return ByteData.sublistView(
      Uint8List.fromList([
        image.width >> 8, image.width & 255, //
        ...data!.buffer.asUint8List(),
      ]),
    );
  }

  int width(ByteData d) => d.getUint8(0) << 8 | d.getUint8(1);
  // Within a level or two: a shadow's last trace, not a visible edge.
  void isPaper(ByteData d, int x, int y, Color want, String why) {
    final i = 2 + (y * width(d) + x) * 4;
    expect(d.getUint8(i + 3), 255, reason: why);
    for (final (c, v) in [(want.r, 0), (want.g, 1), (want.b, 2)]) {
      expect(d.getUint8(i + v), closeTo(c * 255, 2), reason: why);
    }
  }

  for (final (variant, paper) in [
    ('paper', NoorColors.light.paper),
    ('night', NoorColors.dark.paper),
  ]) {
    testWidgets('$variant frames are page coloured round the edge',
        (tester) async {
      await tester.runAsync(() async {
        for (final hero in NoorArt.heroes) {
          final path = NoorArt.frame(hero, variant);
          final d = await pixels(path);
          final w = width(d);
          // Top and both sides; the clouds cover the foot.
          for (var i = 0; i < w; i += 8) {
            isPaper(d, i, 0, paper, '$path top $i');
            isPaper(d, 0, i ~/ 2, paper, '$path left ${i ~/ 2}');
            isPaper(d, w - 1, i ~/ 2, paper, '$path right ${i ~/ 2}');
          }
        }
      });
    });

    testWidgets('the $variant bands repeat without a seam', (tester) async {
      await tester.runAsync(() async {
        for (final path in [NoorArt.band(variant), NoorArt.clouds(variant)]) {
          final d = await pixels(path);
          final w = width(d);
          final h = (d.lengthInBytes - 2) ~/ 4 ~/ w;
          for (var y = 0; y < h; y += 4) {
            final a = 2 + y * w * 4;
            final b = a + (w - 1) * 4;
            for (var c = 0; c < 4; c++) {
              // Neighbouring columns differ this much anywhere in the art.
              expect(d.getUint8(a + c), closeTo(d.getUint8(b + c), 48),
                  reason: '$path y $y channel $c');
            }
          }
        }
      });
    });

    testWidgets('the $variant clouds run into the page', (tester) async {
      await tester.runAsync(() async {
        final d = await pixels(NoorArt.clouds(variant));
        final w = width(d);
        final h = (d.lengthInBytes - 2) ~/ 4 ~/ w;
        for (var x = 0; x < w; x += 8) {
          isPaper(d, x, h - 1, paper, 'x $x');
        }
      });
    });
  }
}

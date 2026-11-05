import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/generals/preload_svgs.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_nav_bar.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _screen() => MaterialApp(
      theme: NoorTheme.light(),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            const NoorIcon(NoorGlyph.bell),
            const NoorIcon(NoorGlyph.kaaba),
            const NoorHero(art: NoorArt.objectMosque, title: 'Prayers'),
            NoorNavBar(selectedIndex: 0, onItemSelected: (_) {}),
          ]),
        ),
      ),
    );

int _painted(WidgetTester t) => t.allRenderObjects
    .where((r) => r.runtimeType.toString().contains('VectorGraphic'))
    .length;

void main() {
  testWidgets('preloaded SVGs paint on the first frame', (tester) async {
    // Debug builds and tests parse SVGs inline, so a first frame paints with or
    // without the preload. What the preload must get right is the cache key:
    // take the loaders the widgets really build, empty the cache, preload, and
    // each of those keys must then be a hit.
    await tester.pumpWidget(_screen());
    final loaders = [
      for (final p in tester.widgetList<SvgPicture>(find.byType(SvgPicture)))
        p.bytesLoader,
    ];
    expect(loaders.length, greaterThan(5));

    final ctx = tester.element(find.byType(NoorIcon).first);
    svg.cache.clear();
    await tester.runAsync(() => preloadSvgs(ctx));

    for (final l in loaders) {
      var miss = false;
      await svg.cache.putIfAbsent(l.cacheKey(ctx), () {
        miss = true;
        return Future.value(ByteData(0));
      });
      expect(miss, isFalse, reason: 'not preloaded: ${l.cacheKey(ctx)}');
    }

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_screen());
    expect(_painted(tester), loaders.length);
  });
}

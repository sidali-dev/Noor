import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_pressable.dart';
import 'package:noor/core/theme/app_theme.dart';

Widget _app(ThemeData theme, Widget child) => MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

BoxDecoration _deco(WidgetTester tester) => tester
    .widget<AnimatedContainer>(find
        .descendant(
            of: find.byType(NoorCard), matching: find.byType(AnimatedContainer))
        .last)
    .decoration! as BoxDecoration;

void main() {
  testWidgets(
      'NoorCard paper is raised paper with shadow-2 and no border; night is '
      'the window (RTL, text scale 1.3)', (tester) async {
    await tester.pumpWidget(_app(
      AppTheme.light(),
      const NoorCard(child: Text('paper')),
    ));
    var d = _deco(tester);
    expect(d.color, NoorColors.light.card);
    expect(d.border, isNull);
    expect(d.boxShadow, NoorColors.light.shadow2);
    expect(d.borderRadius, BorderRadius.circular(24));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_app(
      AppTheme.light(),
      const NoorCard(tone: NoorCardTone.night, child: Text('night')),
    ));
    d = _deco(tester);
    expect(d.color, NoorColors.light.window);
    expect(d.border, isNull);
    expect(d.boxShadow, NoorColors.light.shadow2);
  });

  testWidgets('a tile with no paint of its own takes taps on its empty space',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(
      AppTheme.light(),
      SizedBox(
        width: 300,
        child: NoorPressable(
          onPressed: () => taps++,
          radius: 0,
          builder: (_, __) =>
              const Row(children: [Text('a'), Spacer(), Text('b')]),
        ),
      ),
    ));

    await tester.tap(find.byType(NoorPressable)); // centre: the gap
    expect(taps, 1);
  });
}

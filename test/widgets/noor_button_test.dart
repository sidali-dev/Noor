import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _app(Widget child) => MaterialApp(
      theme: NoorTheme.light(),
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

void main() {
  testWidgets(
      'disabled NoorButton is 45% opacity, flat, inert and still 48 dp tall '
      'in RTL at text scale 1.3', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NoorButton(label: 'Off', onPressed: null, key: Key('off')),
        NoorButton(label: 'On', onPressed: () => taps++, key: const Key('on')),
      ],
    )));

    Finder inner(String key, Type type) =>
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(type));

    expect(tester.widget<Opacity>(inner('off', Opacity)).opacity, 0.45);
    expect(tester.widget<Opacity>(inner('on', Opacity)).opacity, 1.0);

    BoxDecoration deco(String key) => tester
        .widget<AnimatedContainer>(inner(key, AnimatedContainer).last)
        .decoration! as BoxDecoration;
    expect(deco('off').boxShadow, isEmpty);
    expect(deco('on').boxShadow, NoorColors.light.shadow2);

    expect(tester.getSize(find.byKey(const Key('off'))).height,
        greaterThanOrEqualTo(48));

    await tester.tap(find.byKey(const Key('off')));
    await tester.tap(find.byKey(const Key('on')));
    expect(taps, 1);
  });
}

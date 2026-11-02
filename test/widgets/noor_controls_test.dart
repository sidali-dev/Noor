import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_pill.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_search_field.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _app(Locale locale, Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? NoorTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.3)),
      child: c!,
    ),
    home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child)),
  );
}

void main() {
  group('NoorSearchField', () {
    testWidgets(
        'clear button appears with text, is 48 dp and empties the field',
        (tester) async {
      final changes = <String>[];
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(
        const Locale('en'),
        NoorSearchField(
          hint: 'Search',
          controller: controller,
          onChanged: changes.add,
        ),
      ));
      expect(find.byType(NoorCloudButton), findsNothing);
      expect(tester.getSize(find.byType(NoorSearchField)).height, 56);

      await tester.enterText(find.byType(TextField), 'fatiha');
      await tester.pump();
      expect(changes, ['fatiha']);
      expect(find.byType(NoorCloudButton), findsOneWidget);
      final size = tester.getSize(find.byType(NoorCloudButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));

      await tester.tap(find.byType(NoorCloudButton));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(changes.last, '');
      expect(find.byType(NoorCloudButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('focus adds one ring and a shadow change, a tap outside ends it',
        (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        const NoorSearchField(hint: 'Search'),
      ));
      final n = tester.element(find.byType(NoorSearchField)).noor;
      List<BoxShadow>? shadow() =>
          (tester.widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration as BoxDecoration)
              .boxShadow;
      expect(shadow(), n.shadow2);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(shadow(), n.shadow1);
      final decoration =
          tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;
      expect(decoration.focusedBorder, InputBorder.none);
      expect(decoration.enabledBorder, InputBorder.none);

      await tester.tapAt(const Offset(200, 500));
      await tester.pumpAndSettle();
      expect(shadow(), n.shadow2);

      // The icon is on the pill, not the text line: it focuses and keeps focus.
      final icon = find.byWidgetPredicate(
          (w) => w is NoorIcon && w.glyph == NoorGlyph.search);
      await tester.tap(icon);
      await tester.pumpAndSettle();
      expect(shadow(), n.shadow1);
      await tester.tap(icon);
      await tester.pumpAndSettle();
      expect(shadow(), n.shadow1);
    });

    testWidgets('search icon is at the start: right in Arabic, left in English',
        (tester) async {
      Future<double> iconX(Locale l) async {
        await tester.pumpWidget(_app(l, const NoorSearchField(hint: 'x')));
        return tester
                .getCenter(find.byWidgetPredicate(
                    (w) => w is NoorIcon && w.glyph == NoorGlyph.search))
                .dx -
            tester.getCenter(find.byType(NoorSearchField)).dx;
      }

      expect(await iconX(const Locale('en')), lessThan(0));
      expect(await iconX(const Locale('ar')), greaterThan(0));
    });
  });

  group('NoorListRow', () {
    double? chevronFlip(WidgetTester tester) {
      final flip = find.descendant(
        of: find.byIcon(Icons.chevron_right_rounded),
        matching: find.byType(Transform),
      );
      return flip.evaluate().isEmpty
          ? null
          : tester.widget<Transform>(flip.first).transform.storage[0];
    }

    testWidgets('chevron mirrors and sits at the end in Arabic',
        (tester) async {
      await tester.pumpWidget(_app(
        const Locale('ar'),
        NoorListGroup(children: [
          NoorListRow(title: 'الفاتحة', meta: '٧ آيات', onTap: () {}),
          NoorListRow(title: 'البقرة', onTap: () {}),
        ]),
      ));

      expect(chevronFlip(tester), -1);
      final title = tester.getRect(find.text('الفاتحة'));
      final chevron =
          tester.getRect(find.byIcon(Icons.chevron_right_rounded).first);
      expect(chevron.right, lessThan(title.left));
      expect(tester.getTopLeft(find.byType(NoorListRow).first).dx, 16);
    });

    testWidgets('chevron points right at the end in English', (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        NoorListGroup(
            children: [NoorListRow(title: 'Al-Fatiha', onTap: () {})]),
      ));

      expect(chevronFlip(tester), isNull); // not mirrored
      final title = tester.getRect(find.text('Al-Fatiha'));
      expect(tester.getRect(find.byIcon(Icons.chevron_right_rounded)).left,
          greaterThan(title.right));
    });
  });

  testWidgets(
      'NoorPill is at least 48 dp and keeps a long Arabic label on one line',
      (tester) async {
    await tester.pumpWidget(_app(
      const Locale('ar'),
      NoorPill(
        icon: const Icon(Icons.place),
        label: 'الجزائر العاصمة، الجزائر العاصمة، الجزائر العاصمة',
        onTap: () {},
      ),
    ));
    expect(
        tester.getSize(find.byType(NoorPill)).height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });
}

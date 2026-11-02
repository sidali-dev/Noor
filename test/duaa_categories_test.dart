import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/duaa/adhkar_categories.dart';
import 'package:noor/features/duaa/adhkar_display_screen.dart';
import 'package:noor/features/duaa/data/adhkar_data.dart';
import 'package:noor/features/duaa/duaa_screen.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_search_field.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/generals/widgets/noor_tasbih.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

void main() {
  test('adhkarCategories has exactly 19 categories with unique type IDs 1..19',
      () {
    expect(adhkarCategories.length, 19);
    final ids = adhkarCategories.map((c) => c.id).toList();
    expect(ids.toSet().length, 19, reason: 'Type ids must be unique');
    expect(ids, List.generate(19, (i) => i + 1));
  });

  test('every category has a non-empty title getter source', () async {
    for (final lang in ['ar', 'en', 'fr']) {
      final s = await S.load(Locale(lang));
      for (final cat in adhkarCategories) {
        final title = cat.title(s);
        expect(
          title.trim(),
          isNotEmpty,
          reason: 'Category ${cat.id} has empty title for locale $lang',
        );
      }
    }
  });

  test('every category has its own icon, so none reads as another', () {
    final glyphs = adhkarCategories.map((c) => c.glyph).toSet();
    expect(glyphs.length, adhkarCategories.length);
  });

  group('Athkar list', () {
    setUpAll(AdhkarData.init);

    Future<void> pump(WidgetTester tester, String lang, bool dark,
        {double scale = 1.0}) async {
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: dark ? NoorTheme.dark() : NoorTheme.light(),
        locale: Locale(lang),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: w!,
        ),
        home: const DuaaScreen(),
      ));
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (final lang in ['ar', 'fr', 'en']) {
      for (final dark in [false, true]) {
        testWidgets('lists every category, $lang dark $dark at scale 1.3',
            (tester) async {
          await pump(tester, lang, dark, scale: 1.3);
          expect(find.byType(NoorHero), findsOneWidget);
          expect(find.byType(NoorSearchField), findsOneWidget);
          expect(find.byType(NoorListRow), findsNWidgets(19));
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('search filters categories and runs over the adhkar text',
        (tester) async {
      await pump(tester, 'ar', false);
      final s = await S.load(const Locale('ar'));

      await tester.enterText(find.byType(TextField), s.morning_adhkar);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(NoorListRow), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NoorListRow),
          matching: find.text(s.morning_adhkar),
        ),
        findsOneWidget,
      );

      // A phrase from the adhkar text itself finds hits, not categories.
      await tester.enterText(find.byType(TextField), 'سبحان الله وبحمده');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(s.in_adhkar_text), findsOneWidget);
      expect(find.byType(NoorListRow), findsWidgets);

      await tester.enterText(find.byType(TextField), 'zzzzqx');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(s.no_results), findsOneWidget);
      expect(find.byType(NoorListRow), findsNothing);
    });
  });

  testWidgets(
      'AdhkarDisplayScreen pumps, decrements repetitions, and completes',
      (tester) async {
    final fakeAdhkar = [
      AdhkarModel(
        id: 1,
        dhikrType: 1,
        dhikrContent: 'سبحان الله وبحمده\nسبحان الله العظيم',
        dhikrRepetition: 2,
        dhikrInfo: 'فضل عظيم',
      ),
      AdhkarModel(
        id: 2,
        dhikrType: 1,
        dhikrContent: 'الحمد لله',
        dhikrRepetition: 1,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: NoorTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: AdhkarDisplayScreen(
          title: 'أذكار الصباح',
          adhkar: fakeAdhkar,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('أذكار الصباح'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    // The source reads under the text instead of behind an icon.
    expect(find.text('فضل عظيم'), findsOneWidget);

    // Tap repetition button to decrement from 2 to 1
    expect(tester.widget<TasbihCloud>(find.byType(TasbihCloud)).said, 0);
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    // One repetition said is one bead moved along the string.
    expect(tester.widget<TasbihCloud>(find.byType(TasbihCloud)).said, 1);

    // Tap repetition button to decrement to 0 and advance to next card
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);

    // Tap last card's single repetition to complete
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    final done = (await S.load(const Locale('ar'))).done;
    expect(find.text(done), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  group('AdhkarDisplayScreen at large text', () {
    final long = AdhkarModel(
      id: 1,
      dhikrType: 1,
      dhikrContent: 'بِسْمِ اللهِ\n${'اللهُ أَكْبَرُ ' * 80}',
      dhikrRepetition: 3,
      dhikrInfo: 'من قالها حين يصبح ${'كفته ' * 20}',
    );

    for (final loc in ['ar', 'fr', 'en']) {
      for (final dark in [false, true]) {
        testWidgets('$loc ${dark ? 'night' : 'paper'} at 1.3 lays out',
            (tester) async {
          tester.view.physicalSize = const Size(1080, 2200);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(MaterialApp(
            theme: dark ? NoorTheme.dark() : NoorTheme.light(),
            locale: Locale(loc),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            builder: (c, child) => MediaQuery(
              data: MediaQuery.of(c)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: AdhkarDisplayScreen(
              title: loc == 'fr' ? 'Invocations du matin' : 'Morning',
              adhkar: [long, long],
            ),
          ));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('3'), findsOneWidget);
          expect(find.byType(TasbihCloud), findsOneWidget);
        });
      }
    }
  });
}

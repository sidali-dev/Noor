import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/duaa/adhkar_categories.dart';
import 'package:noor/features/duaa/adhkar_display_screen.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
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

  test('every category has an asset path that exists on disk', () {
    for (final cat in adhkarCategories) {
      final file = File(cat.svgAsset);
      expect(
        file.existsSync(),
        isTrue,
        reason:
            'Asset ${cat.svgAsset} for category ${cat.id} must exist on disk',
      );
    }
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

    // Tap repetition button to decrement from 2 to 1
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    // Tap repetition button to decrement to 0 and advance to next card
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);

    // Tap last card's single repetition to complete
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}

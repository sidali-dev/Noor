import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/duaa/views/asma_al_husna_view.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/services/app_prefs.dart';
import 'package:noor/core/services/shared_prefs_service.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await SharedPrefService.init();
    await AppPrefs.setAsmaAlHusnaJson(jsonEncode([
      for (var i = 1; i <= 99; i++)
        {
          'name': 'اسم $i',
          'transliteration': 'Name $i',
          'number': i,
          'en': {'meaning': 'Meaning $i'},
        },
    ]));
  });

  Future<void> pump(WidgetTester tester, String lang) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: Locale(lang),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: (c, w) => MediaQuery(
        data:
            MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.3)),
        child: w!,
      ),
      home: const AsmaAlHusnaView(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('English shows the transliteration and meaning', (tester) async {
    await pump(tester, 'en');
    expect(find.text('اسم 1'), findsOneWidget);
    expect(find.text('Name 1 · Meaning 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('French has no meanings, only the transliteration',
      (tester) async {
    await pump(tester, 'fr');
    expect(find.text('Name 1'), findsOneWidget);
    expect(find.textContaining('Meaning'), findsNothing);
  });

  testWidgets('Arabic shows the names alone', (tester) async {
    await pump(tester, 'ar');
    expect(find.text('اسم 1'), findsOneWidget);
    expect(find.textContaining('Name'), findsNothing);
  });
}

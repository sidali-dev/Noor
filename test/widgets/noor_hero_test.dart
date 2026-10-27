import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_mark.dart';
import 'package:noor/generals/widgets/noor_pager_pill.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _app(Locale locale, Widget hero) => MaterialApp(
      theme: NoorTheme.light(),
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.3),
        ),
        child: child!,
      ),
      home: Scaffold(body: SingleChildScrollView(child: hero)),
    );

void main() {
  const missing = 'assets/images/art/does_not_exist';

  for (final lang in ['ar', 'en']) {
    for (final wordmark in [true, false]) {
      testWidgets('NoorHero, missing art, $lang, wordmark=$wordmark, x1.3',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(
          Locale(lang),
          NoorHero(
            art: missing,
            title: 'Noor Imene',
            subtitle: 'Closer to Allah, every day, in every moment',
            wordmark: wordmark,
            leading: const NoorMark(size: 28),
            settings: true,
            overlap: const SizedBox(height: 56),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 400));

        expect(tester.takeException(), isNull);
        expect(find.text('Noor Imene'), findsOneWidget);
      });
    }
  }

  for (final lang in ['ar', 'en']) {
    for (final split in [true, false]) {
      testWidgets('NoorPagerPill, $lang, split=$split, x1.3', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(
          Locale(lang),
          NoorPagerPill(
            label: '604',
            split: split,
            onPrevious: () {},
            onNext: () {},
            previousTooltip: 'Previous',
            nextTooltip: 'Next',
          ),
        ));

        expect(tester.takeException(), isNull);
        expect(find.text('604'), findsOneWidget);
        expect(find.byTooltip('Next'), findsOneWidget);
      });
    }
  }
}

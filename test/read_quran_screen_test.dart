import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

void main() {
  // pageIndex is zero-based: 1 = page 2 (Al-Baqarah opening), 49 = page 50.
  for (final page in [1, 49]) {
    for (final scale in [1.0, 1.3]) {
      for (final dark in [false, true]) {
        testWidgets('reader page ${page + 1} scale $scale dark $dark',
            (tester) async {
          tester.view.physicalSize = const Size(1080, 2200);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(MaterialApp(
            theme: dark ? NoorTheme.dark() : NoorTheme.light(),
            locale: const Locale('ar'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            builder: (c, w) => MediaQuery(
              data: MediaQuery.of(c)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: w!,
            ),
            home: ReadQuranScreen(pageIndex: page),
          ));
          await tester.pump();
          // Chrome on: top bar + pager.
          await tester.tap(find.byType(ReadQuranScreen));
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

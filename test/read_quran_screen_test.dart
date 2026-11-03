import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/quran/hizb_pages.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/features/quran/widgets/mushaf_frame.dart';
import 'package:noor/generals/widgets/noor_tasbih.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  // pageIndex is zero-based: 1 = page 2 (Al-Baqarah opening), 2 = page 3
  // (no surah starts), 49 = page 50.
  for (final page in [1, 2, 49]) {
    for (final scale in [1.0, 1.3, 2.0]) {
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

          // One marker per ayah in Arabic-Indic digits, the verse text
          // untouched, a cartouche only where a surah starts, the page
          // number at the foot.
          final data = quran.getPageData(page + 1);
          final starts = data.where((d) => d['start'] == 1).length;
          final first = data.first;
          final verses = [
            for (final d in data)
              for (var v = d['start'] as int; v <= (d['end'] as int); v++) v,
          ];
          expect(find.byType(AyahMarker), findsNWidgets(verses.length));
          expect(find.byType(SurahCartouche), findsNWidgets(starts));
          // The page's brass is the bookmark, so the counter leaves it alone.
          final counter = tester.widget<TasbihCloud>(find.byType(TasbihCloud));
          // The count runs to the end of the juz, not of the Mushaf.
          final (jFirst, jLast) = juzPagesOf(page + 1);
          expect(counter.said, page + 2 - jFirst);
          expect(counter.total, jLast - jFirst + 1);
          expect(counter.accent, isFalse);
          expect(
            find.descendant(
              of: find.byType(MushafFrame),
              matching: find.text('${page + 1}'),
            ),
            findsOneWidget,
          );
          expect(
            find.textContaining(
              quran.getVerse(first['surah'] as int, first['start'] as int),
              findRichText: true,
            ),
            findsOneWidget,
          );
          expect(
            find.text(quran.getVerseEndSymbol(verses.first).substring(1)),
            findsAtLeastNWidgets(1),
          );

          // Chrome on: top bar + pager.
          await tester.tap(find.byType(ReadQuranScreen));
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);

          // The counter names the hizb in a snackbar.
          await tester.tap(find.byType(TasbihCloud));
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.byType(SnackBar), findsOneWidget);
          expect(find.textContaining('${hizbOfPage(page + 1)}'), findsWidgets);
          await tester.pump(const Duration(seconds: 3));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

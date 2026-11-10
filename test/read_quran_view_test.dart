import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/features/quran/controllers/quran_search.dart';
import 'package:noor/features/quran/models/hizb_pages.dart';
import 'package:noor/features/quran/models/mushaf_data.dart';
import 'package:noor/features/quran/views/read_quran_view.dart';
import 'package:noor/features/quran/views/surah_player_view.dart';
import 'package:noor/features/quran/views/widgets/mushaf_frame.dart';
import 'package:noor/core/widgets/noor_tasbih.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  test('MushafData builds 15 lines for standard pages and 6236 ayahs total',
      () {
    expect(MushafData.page(3).lines.length, 15);
    expect(MushafData.page(50).lines.length, 15);
    expect(MushafData.page(604).lines.length, 15);
  });

  test('QuranSearch finds verses by Arabic query and surah:ayah reference', () {
    final byRef = QuranSearch.instance.search('2:255');
    expect(byRef.length, 1);
    expect(byRef.first.surah, 2);
    expect(byRef.first.ayah, 255);
    expect(byRef.first.page, 42);

    final byWord = QuranSearch.instance.search('الحمد لله رب العالمين');
    expect(byWord, isNotEmpty);
    expect(byWord.first.surah, 1);
    expect(byWord.first.ayah, 2);
  });
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
            theme: dark ? AppTheme.dark() : AppTheme.light(),
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
            home: ReadQuranView(pageIndex: page),
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
          final firstVerseWords = quran
              .getVerse(first['surah'] as int, first['start'] as int)
              .split(' ');
          expect(
            find.textContaining(
              firstVerseWords.first,
              findRichText: true,
            ),
            findsAtLeastNWidgets(1),
          );
          expect(
            find.text(quran.getVerseEndSymbol(verses.first).substring(1)),
            findsAtLeastNWidgets(1),
          );
          // No vertical scroll inside the Mushaf frame.
          expect(
            find.descendant(
              of: find.byType(MushafFrame),
              matching: find.byType(SingleChildScrollView),
            ),
            findsNothing,
          );

          // Chrome on: top bar + pager, slid in.
          await tester.tap(find.byType(ReadQuranView));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
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

  testWidgets('tapping an AyahMarker opens the Ayah Action Sheet',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const ReadQuranView(pageIndex: 0),
    ));
    await tester.pump();

    await tester.tap(find.byType(AyahMarker).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('1:1'), findsOneWidget);
  });

  testWidgets(
      'SurahPlayerView displays surah, verse, +/-5s controls and next verse',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final audio = QuranAudioController.instance;
    audio.isFullSurahMode.value = true;
    audio.playingAyah.value = (surah: 1, ayah: 1);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const SurahPlayerView(),
    ));
    await tester.pump();

    expect(find.text('سورة الفاتحة'), findsOneWidget);
    final surahPillTextFinder = find.textContaining('تغيير السورة');
    expect(surahPillTextFinder, findsOneWidget);
    final pillTextWidget = tester.widget<Text>(surahPillTextFinder);
    expect(pillTextWidget.style?.color, NoorColors.light.ink);

    expect(find.byIcon(Icons.replay_5_rounded), findsOneWidget);
    expect(find.byIcon(Icons.forward_5_rounded), findsOneWidget);

    // Open play mode picker and select Loop mode.
    await tester.tap(find.byIcon(Icons.repeat_rounded));
    await tester.pumpAndSettle();
    expect(find.text('تكرار السورة'), findsOneWidget);
    await tester.tap(find.text('تكرار السورة'));
    await tester.pumpAndSettle();
    expect(audio.playMode.value, QuranPlayMode.loop);

    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pump(const Duration(milliseconds: 500));
    expect(audio.playingAyah.value?.ayah, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'QuranMiniPlayerBar shows surah number and name without surah:ayah',
      (tester) async {
    final audio = QuranAudioController.instance;
    audio.isFullSurahMode.value = true;
    audio.playingAyah.value = (surah: 2, ayah: 4);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const Scaffold(body: QuranMiniPlayerBar()),
    ));
    await tester.pump();

    expect(find.text('سورة البقرة'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('2:4'), findsNothing);
    audio.playingAyah.value = null;
  });
}

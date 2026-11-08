import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_hero.dart';
import 'package:noor/core/widgets/noor_mark.dart';
import 'package:noor/core/widgets/noor_pill.dart';
import 'package:noor/core/widgets/noor_sky.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';

Widget _app(Locale locale, Widget hero,
        {ThemeData? theme, double scale = 1.3}) =>
    MaterialApp(
      theme: theme ?? AppTheme.light(),
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
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: Scaffold(body: SingleChildScrollView(child: hero)),
    );

const _artKey = ValueKey('noor-hero-art');

void main() {
  const missing = 'assets/images/art/does_not_exist';

  Future<void> pumpHero(
    WidgetTester tester,
    Locale locale,
    Widget hero, {
    ThemeData? theme,
    double scale = 1.3,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(locale, hero, theme: theme, scale: scale));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  }

  const long = NoorHero(
    art: NoorArt.heroQuran,
    title: 'القرآن',
    subtitle:
        'إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ — الإسراء 9',
    settings: true,
    overlap: SizedBox(height: 56),
  );

  testWidgets('NoorHero keeps a one-line overlap in its 56 dp slot at 200%',
      (tester) async {
    for (final locale in const [Locale('en'), Locale('fr'), Locale('ar')]) {
      await pumpHero(
        tester,
        locale,
        const NoorHero(
          art: NoorArt.heroQuran,
          title: 'Quran',
          overlap: NoorPill(
            label: 'The Democratic Republic of the Congo, Kinshasa',
          ),
        ),
        scale: 2.0,
      );
      final slot = tester.getSize(find.byType(NoorPill));
      expect(slot.height, lessThanOrEqualTo(56), reason: '$locale');
    }
  });

  const frame = ValueKey('noor-hero-frame');
  const skyImage = ValueKey('noor-hero-sky');

  String assetOf(WidgetTester tester, Key key) =>
      (tester.widget<Image>(find.byKey(key)).image as dynamic).assetName
          as String;

  testWidgets('NoorHero moves the window to the other side in RTL',
      (tester) async {
    await pumpHero(tester, const Locale('ar'), long);

    // Title on the start side (right), settings disc on the end side (left).
    final title = tester.getRect(find.text('القرآن'));
    final disc = tester.getRect(find.byTooltip('الإعدادات'));
    expect(title.right, closeTo(390 - 16, 1));
    expect(disc.left, closeTo(16, 1));
    expect(disc.size, const Size.square(NoorCloudButton.size));
    expect(tester.getRect(find.byKey(frame)).center.dx, lessThan(390 / 2));
    expect(tester.getRect(find.byKey(skyImage)).center.dx, lessThan(390 / 2));
  });

  testWidgets('NoorHero keeps the window at the end in LTR', (tester) async {
    await pumpHero(tester, const Locale('en'), long);

    expect(tester.getRect(find.text('القرآن')).left, closeTo(16, 1));
    expect(
        tester.getRect(find.byTooltip('Settings')).right, closeTo(390 - 16, 1));
    expect(tester.getRect(find.byKey(frame)).center.dx, greaterThan(390 / 2));
  });

  testWidgets('NoorHero centres the sky behind the frame, either way round',
      (tester) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await pumpHero(tester, locale, long);
      expect(tester.getRect(find.byKey(skyImage)).center.dx,
          closeTo(tester.getRect(find.byKey(frame)).center.dx, 0.01));
    }
  });

  testWidgets(
      'NoorHero draws each tab its own window, in the theme, on one sky',
      (tester) async {
    for (final (theme, variant) in [
      (AppTheme.light(), 'paper'),
      (AppTheme.dark(), 'night'),
    ]) {
      for (final hero in NoorArt.heroes) {
        await pumpHero(
            tester, const Locale('en'), NoorHero(art: hero, title: 'x'),
            theme: theme);
        expect(assetOf(tester, frame), NoorArt.frame(hero, variant));
        expect(assetOf(tester, skyImage), noorSkyNow.value.asset);
        expect(find.byKey(const ValueKey('noor-hero-separator')), findsOneWidget);
      }
    }
  });

  testWidgets('NoorHero text and status bar follow the theme, not the sky',
      (tester) async {
    final was = noorSkyNow.value;
    addTearDown(() => noorSkyNow.value = was);
    for (final (theme, n, icons) in [
      (AppTheme.light(), NoorColors.light, Brightness.dark),
      (AppTheme.dark(), NoorColors.dark, Brightness.light),
    ]) {
      for (final sky in NoorSky.values) {
        noorSkyNow.value = sky;
        await pumpHero(
          tester,
          const Locale('en'),
          const NoorHero(
              art: NoorArt.heroQuran, title: 'Quran', subtitle: 'Verse'),
          theme: theme,
        );
        expect(tester.widget<Text>(find.text('Quran')).style!.color, n.ink);
        expect(tester.widget<Text>(find.text('Verse')).style!.color, n.muted);
        final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.descendant(
                of: find.byType(NoorHero),
                matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>)));
        expect(region.value.statusBarIconBrightness, icons);
      }
    }
  });

  testWidgets('NoorHero without art is a flat window fill', (tester) async {
    await pumpHero(
      tester,
      const Locale('en'),
      const NoorHero(title: 'Qibla', subtitle: 'Turn your face', height: 180),
    );

    final n = AppTheme.light().extension<NoorColors>()!;
    expect(find.byType(Image), findsNothing);
    expect(find.byKey(_artKey), findsNothing);
    final band = tester.widget<DecoratedBox>(find
        .descendant(
          of: find.byType(NoorHero),
          matching: find.byType(DecoratedBox),
        )
        .first);
    final deco = band.decoration as BoxDecoration;
    expect(deco.color, n.window);
    expect(deco.gradient, isNull);
    expect(deco.boxShadow, n.shadow3);
    expect(tester.getRect(find.text('Qibla')).left, closeTo(16, 1));
  });

  testWidgets('NoorHero with art casts no shadow on the page', (tester) async {
    await pumpHero(tester, const Locale('en'), long);

    final band = tester.widget<DecoratedBox>(find
        .descendant(
          of: find.byType(NoorHero),
          matching: find.byType(DecoratedBox),
        )
        .first);
    expect((band.decoration as BoxDecoration).boxShadow, isNull);
  });

  const subtitles = {
    'ar': 'إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ — الإسراء 9',
    'fr':
        'C’est par l’évocation d’Allah que les cœurs s’apaisent. — Ar-Ra’d 13:28',
    'en':
        'Surely in the remembrance of Allah do hearts find rest. — Ar-Ra’d 13:28',
  };

  for (final lang in subtitles.keys) {
    testWidgets('NoorHero subtitle is not squeezed, $lang, notch, x1.3',
        (tester) async {
      tester.view.padding = const FakeViewPadding(top: 48);
      await pumpHero(
        tester,
        Locale(lang),
        NoorHero(
          art: NoorArt.heroAthkar,
          title: lang == 'ar' ? 'الأذكار' : 'Athkar',
          subtitle: subtitles[lang],
          settings: true,
          overlap: const SizedBox(height: 56),
        ),
      );

      final p =
          tester.renderObject<RenderParagraph>(find.text(subtitles[lang]!));
      expect(p.size.height,
          greaterThanOrEqualTo(p.getMaxIntrinsicHeight(p.size.width) - 0.5));
      // The clouds are the last 58 dp of the band; a long verse grows the band
      // rather than running into it.
      expect(tester.getRect(find.text(subtitles[lang]!)).bottom,
          lessThanOrEqualTo(tester.getRect(find.byKey(_artKey)).bottom - 58));
    });
  }

  for (final lang in ['ar', 'en']) {
    testWidgets('NoorHero, missing art, $lang, x1.3', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(
        Locale(lang),
        const NoorHero(
          art: missing,
          title: 'Prayers',
          subtitle: 'Establish prayer for My remembrance, in every moment',
          leading: NoorMark(size: 28),
          settings: true,
          overlap: SizedBox(height: 56),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.text('Prayers'), findsOneWidget);
    });
  }
}

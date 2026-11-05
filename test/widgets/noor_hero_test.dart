import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_mark.dart';
import 'package:noor/generals/widgets/noor_pager_pill.dart';
import 'package:noor/generals/widgets/noor_pill.dart';
import 'package:noor/generals/widgets/noor_sky.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _app(Locale locale, Widget hero,
        {ThemeData? theme, double scale = 1.3}) =>
    MaterialApp(
      theme: theme ?? NoorTheme.light(),
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
    art: NoorArt.objectQuran,
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
          art: NoorArt.objectQuran,
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

  testWidgets('NoorHero mirrors art and layout in RTL', (tester) async {
    await pumpHero(tester, const Locale('ar'), long);

    final flip = tester.widget<Transform>(find.byKey(_artKey));
    expect(flip.transform.storage[0], -1); // flipX
    expect(
        find.descendant(
            of: find.byKey(_artKey), matching: find.byType(SvgPicture)),
        findsOneWidget);

    // Title on the start side (right), settings disc on the end side (left).
    final title = tester.getRect(find.text('القرآن'));
    final disc = tester.getRect(find.byTooltip('الإعدادات'));
    expect(title.right, closeTo(390 - 16, 1));
    expect(disc.left, closeTo(16, 1));
    expect(disc.size, const Size(48, 48));
  });

  testWidgets('NoorHero keeps art and layout in LTR', (tester) async {
    await pumpHero(tester, const Locale('en'), long);

    expect(
        tester.widget<Transform>(find.byKey(_artKey)).transform.storage[0], 1);
    expect(tester.getRect(find.text('القرآن')).left, closeTo(16, 1));
    expect(
        tester.getRect(find.byTooltip('Settings')).right, closeTo(390 - 16, 1));
  });

  testWidgets('NoorHero keeps the Qibla Kaaba upright, at the end of the band',
      (tester) async {
    const hero = NoorHero(art: NoorArt.qiblaKaaba, title: 'Qibla');
    final kaaba = find.byKey(const ValueKey('noor-hero-upright'));

    await pumpHero(tester, const Locale('en'), hero);
    final ltr = tester.getRect(kaaba);
    expect(ltr.center.dx, greaterThan(390 / 2));

    await pumpHero(tester, const Locale('ar'), hero);
    final rtl = tester.getRect(kaaba);
    expect(rtl.center.dx, lessThan(390 / 2));
    expect(rtl.width, closeTo(ltr.width, 0.01));
    // The art behind it mirrors; the Kaaba is not inside that flip.
    expect(
        tester.widget<Transform>(find.byKey(_artKey)).transform.storage[0], -1);
    expect(find.descendant(of: find.byKey(_artKey), matching: kaaba),
        findsNothing);
  });

  testWidgets('NoorHero lays the other objects at the end, upright',
      (tester) async {
    for (final art in [
      NoorArt.objectQuran,
      NoorArt.objectMosque,
      NoorArt.objectSabha,
    ]) {
      final hero = NoorHero(art: art, title: 'x');
      final object = find.byKey(const ValueKey('noor-hero-upright'));
      await pumpHero(tester, const Locale('en'), hero);
      expect(tester.getRect(object).center.dx, greaterThan(390 / 2));
      await pumpHero(tester, const Locale('ar'), hero);
      expect(tester.getRect(object).center.dx, lessThan(390 / 2));
    }
  });

  testWidgets('NoorHero draws the same sky in both themes, edge to edge',
      (tester) async {
    for (final theme in [NoorTheme.light(), NoorTheme.dark()]) {
      await pumpHero(tester, const Locale('en'), long, theme: theme);
      final loader = tester
          .widget<SvgPicture>(find.descendant(
              of: find.byKey(_artKey), matching: find.byType(SvgPicture)))
          .bytesLoader as SvgAssetLoader;
      expect(loader.assetName, noorSkyNow.value.asset);
      final band = tester.widget<DecoratedBox>(find
          .descendant(
            of: find.byType(NoorHero),
            matching: find.byType(DecoratedBox),
          )
          .first);
      expect((band.decoration as BoxDecoration).color, noorSkyNow.value.edge);
    }
  });

  testWidgets('NoorHero without art is a flat window fill', (tester) async {
    await pumpHero(
      tester,
      const Locale('en'),
      const NoorHero(title: 'Qibla', subtitle: 'Turn your face', height: 180),
    );

    final n = NoorTheme.light().extension<NoorColors>()!;
    expect(find.byType(SvgPicture), findsNothing);
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
          art: NoorArt.objectSabha,
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
      // The cloud-scroll base is the last 53 dp of the band; a long verse
      // grows the band rather than running into it.
      expect(tester.getRect(find.text(subtitles[lang]!)).bottom,
          lessThanOrEqualTo(tester.getRect(find.byKey(_artKey)).bottom - 53));
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

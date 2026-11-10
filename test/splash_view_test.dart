import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/routes/app_routes.dart';
import 'package:noor/core/widgets/noor_mark.dart';
import 'package:noor/features/splash/views/splash_view.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/generated/l10n.dart';

Future<void> _never() => Completer<void>().future;

Widget _app(
  Future<void> Function() startup, {
  ThemeData? theme,
  bool reduce = false,
  Locale locale = const Locale('en'),
  Duration minDuration = Duration.zero,
  bool systemIcon = false,
}) =>
    GetMaterialApp(
      theme: theme ?? AppTheme.light(),
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: SplashView(
        startup: startup,
        minDuration: minDuration,
        systemIcon: systemIcon,
      ),
      getPages: [GetPage(name: Routes.MAIN, page: () => const Text('shell'))],
    );

Future<void> _settleArt(WidgetTester tester) => tester
    .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));

Finder _plate(String variant) => find.byWidgetPredicate((w) =>
    w is Image &&
    w.image is AssetImage &&
    (w.image as AssetImage).assetName == NoorArt.splashBg(variant));

/// Plays the 2200 ms entrance out from where it starts.
Future<void> _playEntrance(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 2200));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

/// The art decodes, one frame copies the native splash, the entrance plays
/// out, and the zero-length hold ends.
Future<void> _entered(WidgetTester tester) async {
  await _settleArt(tester);
  await tester.pump();
  await _playEntrance(tester);
}

void main() {
  testWidgets('splash holds until startup is ready, then shows next',
      (tester) async {
    final ready = Completer<void>();
    await tester.pumpWidget(_app(() => ready.future));
    await _entered(tester);
    expect(find.text('shell'), findsNothing);
    expect(find.text('Faith'), findsOneWidget);
    expect(find.text('Your Islamic Companion'), findsOneWidget);
    expect(find.byType(NoorMark), findsOneWidget);
    expect(_plate('paper'), findsOneWidget);

    ready.complete();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('shell'), findsOneWidget);
  });

  testWidgets('startup only starts once the entrance has played',
      (tester) async {
    var started = false;
    await tester.pumpWidget(_app(() {
      started = true;
      return _never();
    }));
    await _settleArt(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(started, isFalse);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 50));
    expect(started, isTrue);
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('splash is held for its minimum even when startup is instant',
      (tester) async {
    await tester.pumpWidget(
        _app(() async {}, minDuration: const Duration(seconds: 2)));
    await _entered(tester);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('shell'), findsNothing);
    expect(find.text('Faith'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('shell'), findsOneWidget);
  });

  testWidgets('the mark starts where the native splash draws it and glides up',
      (tester) async {
    await tester.pumpWidget(_app(_never));
    await _settleArt(tester);
    await tester.pump(); // the frame that hands off from the native splash

    // The emblem's centre sits 0.475 down the raster; the native splash puts
    // it on the middle of the screen.
    double emblemY() {
      final r = tester.getRect(find.byType(NoorMark));
      return r.top + r.height * 0.475;
    }

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(emblemY(), closeTo(screen.height / 2, 1));
    // Words and ring are not yet there.
    expect(
        tester.widget<FadeTransition>(find
                .ancestor(
                    of: find.text('Faith'), matching: find.byType(FadeTransition))
                .first)
            .opacity
            .value,
        0);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 700));
    final mid = emblemY();
    expect(mid, lessThan(screen.height / 2));

    await tester.pump(const Duration(milliseconds: 900));
    final end = emblemY();
    expect(end, lessThan(mid));
    expect(end, closeTo(screen.height * 0.405 - 198 / 2 + 198 * 0.475, 1));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 50));
  });

  // The emblem as drawn, in dp: the raster's 902 of 1120 px, as scaled.
  double emblemHeight(WidgetTester tester) =>
      tester.getRect(find.byType(NoorMark)).height * 902 / 1120;
  Finder systemIcon() => find.byWidgetPredicate((w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName == NoorArt.systemIcon('paper'));

  testWidgets(
      'on Android 12+ the first frame is the system icon, then the mark '
      'takes over', (tester) async {
    await tester.pumpWidget(_app(_never, systemIcon: true));
    await _settleArt(tester);
    await tester.pump(); // the frame that replaces the system splash

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    // What the system draws: a 240 dp icon, its emblem 120 dp, mid-screen.
    expect(systemIcon(), findsOneWidget);
    final icon = tester.getRect(systemIcon());
    expect(icon.size.width, closeTo(240, 0.5));
    expect(icon.center.dy, closeTo(screen.height / 2, 0.5));
    expect(icon.center.dx, closeTo(screen.width / 2, 0.5));
    expect(emblemHeight(tester), closeTo(120, 0.5));
    FadeTransition fadeOf(Finder f) => tester.widget(
        find.ancestor(of: f, matching: find.byType(FadeTransition)).first);
    expect(fadeOf(systemIcon()).opacity.value, 1);
    expect(fadeOf(find.byType(NoorMark)).opacity.value, 0);

    await _playEntrance(tester);
    expect(fadeOf(systemIcon()).opacity.value, 0);
    expect(fadeOf(find.byType(NoorMark)).opacity.value, 1);
    expect(emblemHeight(tester), closeTo(198 * 902 / 1120, 0.5));
  });

  testWidgets('before Android 12 the first frame is the splash image\'s size',
      (tester) async {
    await tester.pumpWidget(_app(_never));
    await _settleArt(tester);
    await tester.pump();
    expect(systemIcon(), findsNothing);
    expect(emblemHeight(tester), closeTo(288 * 0.8, 0.5));
    await _playEntrance(tester);
  });

  testWidgets('night theme builds the same lockup on the night plate',
      (tester) async {
    await tester.pumpWidget(_app(_never, theme: AppTheme.dark()));
    await _entered(tester);
    expect(_plate('night'), findsOneWidget);
    expect(_plate('paper'), findsNothing);
    expect(find.byType(NoorMark), findsOneWidget);
    expect(find.text('Faith'), findsOneWidget);
  });

  testWidgets('the tagline follows the language, the wordmark does not',
      (tester) async {
    for (final (locale, tagline) in [
      (const Locale('fr'), 'Votre compagnon musulman'),
      (const Locale('ar'), 'رفيقك الإسلامي'),
    ]) {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_app(_never, locale: locale));
      await _entered(tester);
      expect(find.text(tagline), findsOneWidget, reason: '$locale');
      expect(find.text('Faith'), findsOneWidget, reason: '$locale');
    }
  });

  testWidgets('the ring turns normally and is still under reduced motion',
      (tester) async {
    await tester.pumpWidget(_app(_never));
    await _entered(tester);
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(_never, reduce: true));
    await _entered(tester);
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Faith'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/bottom_navigation.dart';
import 'package:noor/features/duaa/data/adhkar_data.dart';
import 'package:noor/generals/widgets/noor_nav_bar.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {Locale locale = const Locale('en')}) =>
    GetMaterialApp(
      theme: NoorTheme.light(),
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: home,
    );

Finder _label(String label) =>
    find.descendant(of: find.byType(NoorNavBar), matching: find.text(label));

/// Where the one selector capsule is, against where [label] is.
double _gap(WidgetTester tester, String label) =>
    tester.getCenter(find.byKey(const ValueKey('nav-selector'))).dx -
    tester.getCenter(_label(label)).dx;

void main() {
  // The ring screen's "Open Adhkar" does Get.offAll(SBottomNavigation(pageIndex: 2))
  // while the old navigation's Obx is still mounted. Setting the index inside
  // build used to throw "markNeedsBuild called during build".
  testWidgets('offAll with pageIndex switches tab without a build-time error',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await tester.runAsync(() async {
      await SharedPrefService.init();
      await AdhkarData.init();
    });
    tester.view.physicalSize = const Size(840, 1870);
    tester.view.devicePixelRatio = 2.1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);

    await tester.pumpWidget(_app(const SBottomNavigation()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(Get.find<SBottomNavigationController>().selectedIndex.value, 0);

    Get.offAll(() => const SBottomNavigation(pageIndex: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(Get.find<SBottomNavigationController>().selectedIndex.value, 2);
  });

  testWidgets('tapping a tab selects it and the selector slides to it',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await tester.runAsync(() async {
      await SharedPrefService.init();
      await AdhkarData.init();
    });
    tester.view.physicalSize = const Size(840, 1870);
    tester.view.devicePixelRatio = 2.1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);

    await tester.pumpWidget(_app(const SBottomNavigation()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_gap(tester, 'Quran'), closeTo(0, 0.5));
    expect(_gap(tester, 'Athkar').abs(), greaterThan(50));

    // Athkar, not Qibla: Qibla starts the compass sensor.
    await tester.tap(_label('Athkar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Mid-change: the selector is on its way, not on Quran or Athkar yet.
    expect(_gap(tester, 'Athkar').abs(), inExclusiveRange(1, 150));
    expect(_gap(tester, 'Quran').abs(), greaterThan(1));

    await tester.pump(const Duration(milliseconds: 400));

    expect(Get.find<SBottomNavigationController>().selectedIndex.value, 2);
    expect(_gap(tester, 'Athkar'), closeTo(0, 0.5));
    expect(_gap(tester, 'Quran').abs(), greaterThan(50));
  });

  testWidgets('only the shown tab keeps its hero twinkling', (tester) async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await tester.runAsync(() async {
      await SharedPrefService.init();
      await AdhkarData.init();
    });
    tester.view.physicalSize = const Size(840, 1870);
    tester.view.devicePixelRatio = 2.1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);

    await tester.pumpWidget(_app(const SBottomNavigation()));
    await tester.pump(const Duration(milliseconds: 100));

    // IndexedStack keeps visited tabs alive; their tickers must be muted.
    int running() => find
        .byType(NoorTwinkle, skipOffstage: false)
        .evaluate()
        .where((e) => TickerMode.valuesOf(e).enabled)
        .length;
    expect(find.byType(NoorTwinkle, skipOffstage: false), findsOneWidget);
    expect(running(), 1);

    await tester.tap(_label('Athkar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(NoorTwinkle, skipOffstage: false), findsNWidgets(2));
    expect(running(), 1);

    await tester.tap(_label('Quran'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(running(), 1);
  });

  testWidgets('bar floats s4 above the safe area and mirrors in Arabic',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(bottom: 48); // 24 dp
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(
      Scaffold(
        bottomNavigationBar:
            NoorNavBar(selectedIndex: 0, onItemSelected: (_) {}),
      ),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byType(NoorNavBar));
    final strip = tester.getRect(find
        .descendant(
            of: find.byType(NoorNavBar), matching: find.byType(DecoratedBox))
        .first);
    expect(bar.bottom, 800); // the bar owns the safe area...
    expect(800 - strip.bottom, 24 + NoorSpace.s4); // ...and floats above it
    expect(strip.left, NoorSpace.s4);
    expect(400 - strip.right, NoorSpace.s4);

    // RTL: Quran (first) on the right, Qibla (last) on the left.
    expect(tester.getCenter(find.text('القرآن')).dx,
        greaterThan(tester.getCenter(find.text('القبلة')).dx));
    for (final label in ['القرآن', 'الصلاة', 'الأذكار', 'القبلة']) {
      final item = find
          .ancestor(of: find.text(label), matching: find.byType(Container))
          .first;
      expect(tester.getSize(item).height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('labels stay on one line and tappable at text scale 1.3',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    var picked = -1;

    await tester.pumpWidget(_app(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: Scaffold(
          bottomNavigationBar:
              NoorNavBar(selectedIndex: 0, onItemSelected: (i) => picked = i),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final item = find
        .ancestor(of: find.text('Prayers'), matching: find.byType(Container))
        .first;
    expect(tester.getSize(item).height, greaterThanOrEqualTo(48));
    await tester.tap(find.text('Prayers'));
    expect(picked, 1);
  });
}

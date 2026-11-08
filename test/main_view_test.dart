import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/core/routes/app_pages.dart';
import 'package:noor/features/main/controllers/main_controller.dart';
import 'package:noor/features/main/views/main_view.dart';
import 'package:noor/features/adhan/views/adhan_view.dart';
import 'package:noor/features/duaa/controllers/adhkar_data.dart';
import 'package:noor/features/duaa/views/duaa_view.dart';
import 'package:noor/features/quran/views/quran_view.dart';
import 'package:noor/core/widgets/noor_nav_bar.dart';
import 'package:noor/core/widgets/noor_sky.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/services/shared_prefs_service.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [shell]: [home] holds a MainView, so it needs the MAIN route's controllers.
Widget _app(Widget home,
        {Locale locale = const Locale('en'), bool shell = true}) =>
    GetMaterialApp(
      initialBinding: shell ? AppPages.mainBinding : null,
      theme: AppTheme.light(),
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
  // The ring screen's "Open Adhkar" does Get.offAll(MainView(pageIndex: 2))
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

    await tester.pumpWidget(_app(const MainView()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(Get.find<MainController>().selectedIndex.value, 0);

    Get.offAll(() => const MainView(pageIndex: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(Get.find<MainController>().selectedIndex.value, 2);
    Get.delete<MainController>(); // cancels its warm-up timer
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

    await tester.pumpWidget(_app(const MainView()));
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

    expect(Get.find<MainController>().selectedIndex.value, 2);
    expect(_gap(tester, 'Athkar'), closeTo(0, 0.5));
    expect(_gap(tester, 'Quran').abs(), greaterThan(50));
    Get.delete<MainController>();
  });

  Future<void> pumpShell(WidgetTester tester, Widget home,
      {Locale locale = const Locale('en')}) async {
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
    await tester.pumpWidget(_app(home, locale: locale));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('a tab slides in and the old one out, in step with the selector',
      (tester) async {
    await pumpShell(tester, const MainView());
    final width = tester.getSize(find.byType(MainView)).width;
    final from = tester.getCenter(_label('Quran')).dx;
    final to = tester.getCenter(_label('Athkar')).dx;

    await tester.tap(_label('Athkar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // How far along: the selector, then each tab.
    final t = (tester.getCenter(find.byKey(const ValueKey('nav-selector'))).dx -
            from) /
        (to - from);
    expect(t, inExclusiveRange(0, 1));
    expect(tester.getTopLeft(find.byType(DuaaView)).dx / width,
        closeTo(1 - t, 0.01));
    expect(tester.getTopLeft(find.byType(QuranView)).dx / width,
        closeTo(-t, 0.01));

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(find.byType(DuaaView)).dx, 0);
    expect(find.byType(QuranView), findsNothing);
    expect(tester.takeException(), isNull);
    Get.delete<MainController>(); // cancels its warm-up timer
  });

  testWidgets('going back to a lower tab slides the other way', (tester) async {
    await pumpShell(tester, const MainView(pageIndex: 2));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(_label('Quran'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(find.byType(QuranView)).dx, lessThan(0));
    expect(tester.getTopLeft(find.byType(DuaaView)).dx, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 300));
    Get.delete<MainController>(); // cancels its warm-up timer
  });

  testWidgets('in Arabic a higher tab slides in from the left', (tester) async {
    await pumpShell(tester, const MainView(),
        locale: const Locale('ar'));

    await tester.tap(_label('الأذكار'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getTopLeft(find.byType(DuaaView)).dx, lessThan(0));
    expect(tester.getTopLeft(find.byType(QuranView)).dx, greaterThan(0));

    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getTopLeft(find.byType(DuaaView)).dx, 0);
    Get.delete<MainController>(); // cancels its warm-up timer
  });

  testWidgets('Reduce Motion switches tabs at once', (tester) async {
    await pumpShell(
      tester,
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MainView(),
      ),
    );

    await tester.tap(_label('Athkar'));
    await tester.pump();

    expect(tester.getTopLeft(find.byType(DuaaView)).dx, 0);
    expect(find.byType(QuranView), findsNothing);
    expect(tester.takeException(), isNull);
    Get.delete<MainController>(); // cancels its warm-up timer
  });

  testWidgets('only the shown tab keeps its hero twinkling', (tester) async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await tester.runAsync(() async {
      await SharedPrefService.init();
      await AdhkarData.init();
    });
    noorSkyNow.value = NoorSky.isha; // Only a sky with stars twinkles.
    tester.view.physicalSize = const Size(840, 1870);
    tester.view.devicePixelRatio = 2.1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);

    await tester.pumpWidget(_app(const MainView()));
    await tester.pump(const Duration(milliseconds: 100));

    // Visited tabs are kept alive; their tickers must be muted.
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
    Get.delete<MainController>();
  });

  testWidgets('Prayers and Athkar are built off-stage in idle time, Qibla not',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await tester.runAsync(() async {
      await SharedPrefService.init();
      await AdhkarData.init();
    });
    noorSkyNow.value = NoorSky.isha; // Only a sky with stars twinkles.
    tester.view.physicalSize = const Size(840, 1870);
    tester.view.devicePixelRatio = 2.1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);

    await tester.pumpWidget(_app(const MainView()));
    await tester.pump(const Duration(milliseconds: 100));
    final c = Get.find<MainController>();
    expect(c.warmed, isEmpty); // not during the first frames

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(c.warmed, {1, 2});
    expect(c.selectedIndex.value, 0);
    // Mounted (Quran, Prayers, Athkar), none of the extra ones twinkling.
    expect(find.byType(NoorTwinkle, skipOffstage: false), findsNWidgets(3));
    expect(
        find
            .byType(NoorTwinkle, skipOffstage: false)
            .evaluate()
            .where((e) => TickerMode.valuesOf(e).enabled),
        hasLength(1));
  });

  testWidgets('a warming tab paints once, unseen, and keeps its state',
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

    await tester.pumpWidget(_app(const MainView()));
    final c = Get.find<MainController>();
    final prayers = find.byType(AdhanView);
    Finder above(Type t) =>
        find.ancestor(of: prayers, matching: find.byType(t));
    bool ignoring() =>
        tester.widget<IgnorePointer>(above(IgnorePointer).first).ignoring;

    // The warm frame is over within one pump, so it is read from inside it.
    int? painted, under;
    bool? inert, unread, ticking;
    c.warming.listen((k) {
      if (k == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        painted = prayers.evaluate().length; // on-stage to the finder
        final stack =
            tester.element(prayers).findAncestorWidgetOfExactType<Stack>()!;
        under = (stack.children.first.key! as ValueKey<int>).value;
        inert = ignoring();
        unread = tester
            .widget<ExcludeSemantics>(above(ExcludeSemantics).first)
            .excluding;
        ticking = TickerMode.valuesOf(tester.element(prayers)).enabled;
      });
    });

    for (var i = 0; i < 40 && !c.warmed.contains(1); i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(painted, 1);
    expect(under, 1);
    expect(inert, isTrue);
    expect(unread, isTrue);
    expect(ticking, isFalse);

    await tester.pump(); // hidden again
    expect(c.warming.value, isNull);
    expect(prayers, findsNothing);
    final state = tester.state(find.byType(AdhanView, skipOffstage: false));

    await tester.tap(_label('Prayers'));
    await tester.pump();
    expect(tester.state(prayers), state);
    expect(TickerMode.valuesOf(tester.element(prayers)).enabled, isTrue);
    expect(ignoring(), isFalse);
    Get.delete<MainController>();
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
      shell: false,
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
      shell: false,
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

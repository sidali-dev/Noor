import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/bottom_navigation.dart';
import 'package:noor/features/duaa/data/adhkar_data.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    await tester.pumpWidget(GetMaterialApp(
      theme: NoorTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const SBottomNavigation(),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(Get.find<SBottomNavigationController>().selectedIndex.value, 0);

    Get.offAll(() => const SBottomNavigation(pageIndex: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(Get.find<SBottomNavigationController>().selectedIndex.value, 2);
  });
}

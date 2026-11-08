import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/core/routes/app_pages.dart';
import 'package:noor/core/routes/app_routes.dart';
import 'package:noor/core/services/location_service.dart';
import 'package:noor/core/services/shared_prefs_service.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/features/adhan/controllers/sound_picker_controller.dart';
import 'package:noor/features/duaa/controllers/adhkar_data.dart';
import 'package:noor/features/duaa/models/adhkar_category.dart';
import 'package:noor/features/duaa/views/adhkar_display_view.dart';
import 'package:noor/features/main/controllers/main_controller.dart';
import 'package:noor/features/main/views/main_view.dart';
import 'package:noor/features/quran/views/read_quran_view.dart';
import 'package:noor/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('named routes open, and shell controllers outlive a pushed route',
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
    Get.put(LocationService()); // main() registers it

    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(disableAnimations: true),
        child: child!,
      ),
      getPages: AppPages.routes,
      initialRoute: Routes.MAIN,
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MainView), findsOneWidget);

    Get.toNamed(Routes.READ_QURAN, arguments: 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ReadQuranView), findsOneWidget);

    // First looked up while the reader is on top, as a warming tab would.
    Get.find<SoundPickerController>();
    Get.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(() => Get.find<SoundPickerController>(), returnsNormally);

    final category = adhkarCategories.first;
    Get.toNamed(Routes.ADHKAR_DISPLAY, arguments: (
      title: 'Adhkar',
      adhkar: AdhkarData.byType(category.id),
      initialIndex: 0,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AdhkarDisplayView), findsOneWidget);
    expect(tester.takeException(), isNull);

    Get.delete<MainController>(); // cancels its warm-up timer
  });
}

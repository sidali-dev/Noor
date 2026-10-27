import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/generals/controllers/theme_controller.dart';
import 'package:noor/generals/widgets/location_pill.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildWrapper({
  required Widget child,
  required ThemeData theme,
  required Locale locale,
}) {
  return GetMaterialApp(
    theme: theme,
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await SharedPrefService.init();

    Get.testMode = true;
    Get.put(ThemeController());
    Get.put(LocalizationController());
    Get.put(LocationController());
    Get.put(AdhanController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('LocationPill displays enter_location when location is empty',
      (tester) async {
    await tester.pumpWidget(
      _buildWrapper(
        theme: NoorTheme.light(),
        locale: const Locale('en'),
        child: const LocationPill(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter Your Location'), findsOneWidget);
  });

  testWidgets('LocationPill displays "Country, City" when location is set',
      (tester) async {
    final adhanController = Get.find<AdhanController>();
    adhanController.locationController.country.value = 'Algeria';
    adhanController.locationController.city.value = 'Algiers';

    await tester.pumpWidget(
      _buildWrapper(
        theme: NoorTheme.light(),
        locale: const Locale('en'),
        child: const LocationPill(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Algeria, Algiers'), findsOneWidget);
  });

  testWidgets('LocationPill updates reactively when location changes',
      (tester) async {
    final adhanController = Get.find<AdhanController>();
    adhanController.locationController.country.value = '';
    adhanController.locationController.city.value = '';

    await tester.pumpWidget(
      _buildWrapper(
        theme: NoorTheme.dark(),
        locale: const Locale('ar'),
        child: const LocationPill(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('أضف موقعك'), findsOneWidget);

    adhanController.locationController.country.value = 'الجزائر';
    adhanController.locationController.city.value = 'الجزائر العاصمة';
    await tester.pump();

    expect(find.text('الجزائر, الجزائر العاصمة'), findsOneWidget);
  });
}

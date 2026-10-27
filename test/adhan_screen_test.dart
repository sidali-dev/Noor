import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/adhan_screen.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/features/adhan/widgets/adhan_line.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/adhan/widgets/sound_picker_sheet.dart';
import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/generals/controllers/theme_controller.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/sound_string.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return GetMaterialApp(
    theme: NoorTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(
      body: child,
    ),
  );
}

Map<String, dynamic> _createMockCalendarData(int year) {
  final dataJson = <String, dynamic>{};
  for (var month = 1; month <= 12; month++) {
    dataJson[month.toString()] = List.generate(31, (i) {
      return {
        'timings': {
          'Fajr': '05:00',
          'Sunrise': '06:30',
          'Dhuhr': '12:30',
          'Asr': '16:00',
          'Sunset': '18:50',
          'Maghrib': '19:00',
          'Isha': '20:30',
          'Imsak': '04:50',
          'Midnight': '00:00',
          'Firstthird': '22:00',
          'Lastthird': '02:00',
        },
        'date': {
          'readable': '${i + 1} $month $year',
          'timestamp': '1700000000',
          'gregorian': {
            'date': '${i + 1}',
            'weekday': {'en': 'Monday'},
          },
          'hijri': {
            'date': '${i + 1}',
            'weekday': {'en': 'Al Ithnin', 'ar': 'الاثنين'},
          },
        },
      };
    });
  }

  return {
    'code': 200,
    'status': 'OK',
    'data': dataJson,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await SharedPrefService.init();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async {
        return 1;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async {
        return 1;
      },
    );

    Get.testMode = true;
    Get.put(ThemeController());
    Get.put(LocalizationController());
    Get.put(LocationController());
    Get.put(SoundPickerController());
    Get.put(AdhanController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('AdhanScreen shows empty state when location is missing',
      (tester) async {
    final controller = Get.find<AdhanController>();
    controller.locationController.country.value = '';
    controller.locationController.city.value = '';
    controller.prayerTime.value = PrayerTime.empty();

    await tester.pumpWidget(_buildTestApp(child: const AdhanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Enter Your Location'), findsWidgets);
    expect(find.text('Please add your location'), findsOneWidget);
  });

  testWidgets('AdhanScreen displays prayer rows when timings are loaded',
      (tester) async {
    final now = DateTime.now();
    final mockJson = _createMockCalendarData(now.year);
    await AppPrefs.setLocation('Algeria', 'Algiers', 'Algiers');
    await AppPrefs.setPrayerYearJson(now.year, jsonEncode(mockJson));

    final controller = Get.find<AdhanController>();
    controller.locationController.country.value = 'Algeria';
    controller.locationController.city.value = 'Algiers';
    controller.prayerTime.value = PrayerTime.fromJson(mockJson);

    await tester.pumpWidget(_buildTestApp(child: const AdhanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Sunrise'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
  });

  testWidgets('AdhanLine expands on tap to show reminder options',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const AdhanLine(
          prayer: Prayer.fajr,
          time: '05:00',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('set new alarm'), findsNothing);

    // Tap to expand
    await tester.tap(find.text('Fajr'));
    await tester.pumpAndSettle();

    expect(find.text('set new alarm'), findsOneWidget);
  });

  testWidgets('SoundPickerSheet renders 5 options and allows selection',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const SoundPickerSheet(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SoundPickerSheet), findsOneWidget);

    // Verify first sound option
    expect(find.text('Adhan Sheikh Ahmad Alnafees'), findsOneWidget);

    // Tap second option
    await tester.tap(find.text('Adhan Sheikh Alafasy 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(AppPrefs.adhanSoundPath, SSoundString.adhanAlafasy1);
  });
}

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
import 'package:noor/features/adhan/widgets/adhan_reminders_sheet.dart';
import 'package:noor/features/adhan/widgets/next_prayer_card.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/adhan/widgets/sound_picker_sheet.dart';
import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/generals/controllers/theme_controller.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/sound_string.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
  double scale = 1.0,
  bool reduceMotion = true,
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
    builder: (context, app) => MediaQuery(
      // Reduce Motion: the hero's star twinkle loops and would hang pumpAndSettle.
      data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: reduceMotion),
      child: app!,
    ),
    home: Scaffold(
      body: child,
    ),
  );
}

Map<String, dynamic> _createMockCalendarData(int year,
    {bool hijriMonth = true, String isha = '23:59'}) {
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
          'Isha': isha,
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
            'date': '${(i % 29) + 1}-07-1448',
            'weekday': {'en': 'Al Ithnin', 'ar': 'الاثنين'},
            if (hijriMonth) 'month': {'number': 7, 'en': 'Rajāb', 'ar': 'رجب'},
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

TextEditingController _reminderField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!;

Future<AdhanController> _loadCalendar(DateTime now,
    {Map<String, dynamic>? json}) async {
  final mockJson = json ?? _createMockCalendarData(now.year);
  await AppPrefs.setLocation('Algeria', 'Algiers', 'Algiers');
  await AppPrefs.setPrayerYearJson(now.year, jsonEncode(mockJson));
  final controller = Get.find<AdhanController>();
  controller.locationController.country.value = 'Algeria';
  controller.locationController.city.value = 'Algiers';
  controller.prayerTime.value = PrayerTime.fromJson(mockJson);
  return controller;
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

    expect(find.text('Enter your location'), findsWidgets);
    expect(find.text('Add your location to see prayer times'), findsOneWidget);
    expect(find.text('Add location'), findsOneWidget);
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

    // The six rows share one paper list, and the next prayer has its card.
    expect(find.byType(NoorListGroup), findsOneWidget);
    expect(find.byType(AdhanLine), findsNWidgets(6));
    expect(find.byType(NextPrayerCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NextPrayerCard),
        matching: find.textContaining(' in '),
      ),
      findsOneWidget,
    );

    // Today's Hijri date sits under the day title.
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('${(now.day - 1) % 29 + 1} Rajab 1448'), findsOneWidget);
  });

  testWidgets('AdhanScreen falls back to the raw Hijri date without a month',
      (tester) async {
    final now = DateTime.now();
    final mockJson = _createMockCalendarData(now.year, hijriMonth: false);
    await AppPrefs.setLocation('Algeria', 'Algiers', 'Algiers');
    await AppPrefs.setPrayerYearJson(now.year, jsonEncode(mockJson));

    final controller = Get.find<AdhanController>();
    controller.locationController.country.value = 'Algeria';
    controller.locationController.city.value = 'Algiers';
    controller.prayerTime.value = PrayerTime.fromJson(mockJson);

    await tester.pumpWidget(_buildTestApp(child: const AdhanScreen()));
    await tester.pumpAndSettle();

    expect(find.text('${(now.day - 1) % 29 + 1}-07-1448'), findsOneWidget);
  });

  testWidgets('AdhanLine bell toggles the prayer alarm', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const AdhanLine(prayer: Prayer.fajr, time: '05:00'),
      ),
    );
    await tester.pumpAndSettle();

    final enabled = Get.find<AdhanController>().enabledFor(Prayer.fajr.key);
    final before = enabled.value;
    await tester.tap(find.byTooltip('Fajr'));
    await tester.pumpAndSettle();

    expect(enabled.value, !before);
  });

  for (final locale in const [Locale('en'), Locale('fr'), Locale('ar')]) {
    testWidgets('AdhanLine and its reminders sheet fit 320 dp at 200%: $locale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_buildTestApp(
        locale: locale,
        scale: 2.0,
        child: const SingleChildScrollView(
          child: AdhanLine(prayer: Prayer.maghrib, time: '19:00'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(AdhanLine));
      await tester.pumpAndSettle();
      expect(find.text(S.current.set_new_alarm), findsOneWidget);
      // The audio plugin has no host in tests; only layout errors count.
      final error = tester.takeException();
      expect(error is MissingPluginException ? null : error, isNull);
    });
  }

  testWidgets('AdhanLine opens a sheet to set a new alarm', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const AdhanLine(
          prayer: Prayer.fajr,
          time: '05:00',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NoorSheet), findsNothing);

    await tester.tap(find.text('Fajr'));
    await tester.pumpAndSettle();

    expect(find.byType(NoorSheet), findsOneWidget);
    expect(find.text('Set new alarm'), findsOneWidget);
    expect(find.text('min after adhan'), findsOneWidget);
    expect(_reminderField(tester).text, '10');
  });

  testWidgets('Tapping the day opens a calendar that picks the date',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    final controller = await _loadCalendar(now);

    await tester.pumpWidget(_buildTestApp(child: const AdhanScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    final day = now.day == 15 ? 16 : 15;
    await tester.tap(find.text('$day'));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsNothing);
    expect(controller.date.value, DateTime(now.year, now.month, day));
    expect(find.byType(NextPrayerCard), findsNothing);
  });

  testWidgets('After Isha the page moves on to tomorrow and its Fajr', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    // Every prayer is long past, whatever the hour of the test run.
    final json = _createMockCalendarData(now.year, isha: '00:00');
    for (final month in (json['data'] as Map).values) {
      for (final day in month as List) {
        (day['timings'] as Map).updateAll((_, __) => '00:00');
      }
    }
    final controller = await _loadCalendar(now, json: json);
    controller.date.value = now;
    // Tomorrow's Fajr is the next prayer unless it is Dec 31 or 00:00 sharp.
    if (now.month == 12 && now.day == 31) return;

    await tester.pumpWidget(_buildTestApp(child: const AdhanScreen()));
    await tester.pumpAndSettle();
    controller.rollPastIsha();
    await tester.pumpAndSettle();

    expect(controller.date.value, DateTime(now.year, now.month, now.day + 1));
    expect(find.byType(NextPrayerCard), findsOneWidget);

    // Back on today: its prayers are done, so nothing is highlighted.
    controller.decrementDay();
    await tester.pumpAndSettle();
    expect(find.byType(NextPrayerCard), findsNothing);
    controller.rollPastIsha();
    expect(controller.date.value.day, now.day);
  });

  testWidgets('The next prayer card animates out when leaving today',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    final controller = await _loadCalendar(now);

    await tester.pumpWidget(
        _buildTestApp(child: const AdhanScreen(), reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 300));
    final before = tester.getTopLeft(find.byType(NoorWell).first).dy;

    controller.date.value =
        DateTime(now.year, now.month, now.day == 1 ? 2 : now.day - 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = tester.getTopLeft(find.byType(NoorWell).first).dy;
    expect(find.byType(NextPrayerCard), findsOneWidget);
    expect(mid, lessThan(before));

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(NextPrayerCard), findsNothing);
    expect(tester.getTopLeft(find.byType(NoorWell).first).dy, lessThan(mid));
  });

  test('The day arrows move by calendar day from local midnight', () {
    final controller = Get.find<AdhanController>();
    for (var day = 1; day <= 365; day++) {
      final midnight = DateTime(2026, 1, day);
      controller.date.value = midnight;
      controller.incrementDay();
      expect(controller.date.value, DateTime(2026, 1, day + 1));
      controller.decrementDay();
      expect(controller.date.value, midnight);
    }
  });

  testWidgets('Reminder field takes a typed value and a direction',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(
      child: const AdhanRemindersSheet(prayer: Prayer.fajr, time: '05:00'),
    ));
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    NoorButton button() => tester
        .widget<NoorButton>(find.widgetWithText(NoorButton, 'Set new alarm'));

    // The words open the field too.
    await tester.tap(find.text('min after adhan'));
    await tester.pump();
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);

    // A bare number keeps the direction; a minus means before.
    await tester.enterText(field, '15');
    await tester.pump();
    expect(find.text('min after adhan'), findsOneWidget);
    await tester.enterText(field, '-15');
    await tester.pump();
    expect(find.text('min before adhan'), findsOneWidget);

    // Past the limit it clamps; Arabic-Indic digits count.
    await tester.enterText(field, '-90');
    await tester.pump();
    expect(_reminderField(tester).text, '-60');
    await tester.enterText(field, '١٥');
    await tester.pump();
    expect(button().onPressed, isNotNull);

    // No number: nothing to set.
    await tester.enterText(field, '');
    await tester.pump();
    expect(button().onPressed, isNull);

    // Leaving an empty field falls back to the last value, direction kept.
    tester.widget<TextField>(field).focusNode!.unfocus();
    await tester.pump();
    expect(_reminderField(tester).text, '10');
    expect(find.text('min after adhan'), findsOneWidget);

    // A committed minus sticks: the next bare number stays before.
    await tester.enterText(field, '-5');
    await tester.pump();
    tester.widget<TextField>(field).focusNode!.unfocus();
    await tester.pump();
    expect(_reminderField(tester).text, '5');
    await tester.enterText(field, '8');
    await tester.pump();
    expect(find.text('min before adhan'), findsOneWidget);
  });

  testWidgets('AdhanLine sets the next prayer time in brass', (tester) async {
    await tester.pumpWidget(_buildTestApp(
      child: const AdhanLine(prayer: Prayer.fajr, time: '05:00', isNext: true),
    ));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(find.text('05:00')).style!.color,
        NoorColors.light.brass);
  });

  testWidgets('Reminders stepper crosses the adhan without stopping at zero',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(
      child: const AdhanRemindersSheet(prayer: Prayer.fajr, time: '05:00'),
    ));
    await tester.pumpAndSettle();

    final earlier = find.byTooltip('before adhan');
    for (var i = 0; i < 10; i++) {
      await tester.tap(earlier);
      await tester.pump();
    }
    expect(_reminderField(tester).text, '1');
    expect(find.text('min before adhan'), findsOneWidget);
  });

  testWidgets('Reminders sheet lists the set alarms and stops at two',
      (tester) async {
    const prayer = Prayer.fajr;
    await AppPrefs.setReminder(prayer.alarmId1, prayer.durationKey1, -15);

    await tester.pumpWidget(_buildTestApp(
      child: const AdhanRemindersSheet(prayer: prayer, time: '05:00'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Set new alarm'), findsOneWidget);

    await AppPrefs.setReminder(prayer.alarmId2, prayer.durationKey2, 20);
    await tester.pumpWidget(_buildTestApp(
      child: const AdhanRemindersSheet(
          key: ValueKey('two'), prayer: prayer, time: '05:00'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Remove'), findsNWidgets(2));
    expect(find.text('Set new alarm'), findsNothing);
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
    // stopPreview() leaves a 300 ms timer; the old ink ripple used to outlast it.
    await tester.pump(const Duration(milliseconds: 400));

    expect(AppPrefs.adhanSoundPath, SSoundString.adhanAlafasy1);
  });

  testWidgets('SoundPickerSheet puts the checked state and play on one row',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_buildTestApp(child: const SoundPickerSheet()));
    await tester.pumpAndSettle();

    expect(find.byType(NoorCloudButton), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Adhan Sheikh Alafasy 1')),
      isNot(isSemantics(isChecked: true)),
    );

    await tester.tap(find.text('Adhan Sheikh Alafasy 1'));
    await tester.pumpAndSettle();

    // Play follows the selection and stays alone.
    expect(find.byType(NoorCloudButton), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Adhan Sheikh Alafasy 1')),
      isSemantics(isChecked: true),
    );
    // stopPreview() leaves a 300 ms timer.
    await tester.pump(const Duration(milliseconds: 400));
    handle.dispose();
  });

  testWidgets('the play triangle points the way the page reads',
      (tester) async {
    for (final (locale, mirrored) in [
      (const Locale('en'), false),
      (const Locale('ar'), true),
    ]) {
      await tester.pumpWidget(const SizedBox()); // a fresh app per locale
      await tester.pumpWidget(
          _buildTestApp(child: const SoundPickerSheet(), locale: locale));
      await tester.pumpAndSettle();

      final flips = tester
          .widgetList<Transform>(find.descendant(
              of: find.byType(NoorCloudButton),
              matching: find.byType(Transform)))
          .where((t) => t.transform.storage[0] == -1);
      expect(flips.isNotEmpty, mirrored, reason: '$locale');
    }
  });
}

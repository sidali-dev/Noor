import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/adhan/views/adhan_app.dart';
import 'package:noor/features/adhan/views/adhan_ring_view.dart';
import 'package:noor/features/adhan/models/adhan_ring.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:noor/core/services/adhan_texts.dart';
import 'package:noor/core/widgets/noor_sky.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/services/shared_prefs_service.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _at = DateTime(2026, 1, 1, 15, 34);

AdhanRing _ring(Prayer? prayer, {DateTime? time}) => AdhanRing(
      id: prayer?.adhanId ?? 9,
      prayer: prayer,
      prayerTime: time ?? _at,
      title: 'An alarm',
    );

Future<void> _pump(
  WidgetTester tester,
  AdhanRing ring, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
  DateTime? now,
  VoidCallback? onStop,
  VoidCallback? onOpenAthkar,
  Size size = const Size(840, 1870),
  double ratio = 2.1,
  double scale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = ratio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
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
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: AdhanRingView(
      ring: ring,
      onStop: onStop ?? () {},
      onOpenAthkar: onOpenAthkar ?? () {},
      now: () => now ?? _at.add(const Duration(minutes: 4)),
    ),
  ));
  await tester.pump();
}

String _asset(WidgetTester tester, String key) =>
    (tester.widget<Image>(find.byKey(ValueKey(key))).image as AssetImage)
        .assetName;

String _name(Prayer prayer) => AdhanTexts(S.current).prayerName(prayer);

AlarmSettings _settings(int id, DateTime at) => AlarmSettings(
      id: id,
      dateTime: at,
      assetAudioPath: 'a.mp3',
      loopAudio: false,
      vibrate: false,
      volumeSettings: const VolumeSettings.fixed(volume: 0.5),
      warningNotificationOnKill: false,
      androidFullScreenIntent: true,
      notificationSettings: const NotificationSettings(
          title: 'Maghrib', body: '', stopButton: 'stop'),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefService.init();
  });

  for (final (name, locale, theme) in [
    ('ar paper', const Locale('ar'), AppTheme.light()),
    ('ar night', const Locale('ar'), AppTheme.dark()),
    ('fr paper', const Locale('fr'), AppTheme.light()),
    ('en night', const Locale('en'), AppTheme.dark()),
  ]) {
    testWidgets('ring screen at text scale 1.3 without overflow: $name',
        (tester) async {
      // Maghrib is the longest name.
      await _pump(tester, _ring(Prayer.maghrib),
          locale: locale, theme: theme, scale: 1.3);

      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.text('المغرب'), findsOneWidget);
      expect(find.text('15:34'), findsOneWidget);
      expect(find.text(S.current.reminder_after(4, _name(Prayer.maghrib))),
          findsOneWidget);
      expect(find.text(S.current.stop_adhan), findsOneWidget);
      expect(find.text(S.current.open_adhkar), findsOneWidget);
      expect(_asset(tester, 'adhan-frame'),
          contains(theme.brightness == Brightness.dark ? 'night' : 'paper'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the pill counts to the prayer, then from it', (tester) async {
    final name = _name(Prayer.fajr);
    final fajr = _ring(Prayer.fajr);

    await _pump(tester, fajr, now: _at.subtract(const Duration(minutes: 10)));
    expect(find.text(S.current.reminder_before(10, name)), findsOneWidget);

    // A part minute before still counts as one.
    await _pump(tester, fajr, now: _at.subtract(const Duration(seconds: 20)));
    expect(find.text(S.current.reminder_before(1, name)), findsOneWidget);

    await _pump(tester, fajr, now: _at.add(const Duration(seconds: 40)));
    expect(find.text(S.current.adhan_now(name)), findsOneWidget);

    await _pump(tester, fajr, now: _at.add(const Duration(minutes: 4)));
    expect(find.text(S.current.reminder_after(4, name)), findsOneWidget);
  });

  testWidgets('an alarm that is no prayer shows its title and no pill',
      (tester) async {
    await _pump(tester, _ring(null));
    expect(find.text('An alarm'), findsOneWidget);
    expect(find.text('15:34'), findsOneWidget);
    expect(find.textContaining('min'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final (prayer, sky) in [
    (Prayer.fajr, NoorSky.fajr),
    (Prayer.chourouk, NoorSky.fajr),
    (Prayer.dhuhr, NoorSky.dhuhr),
    (Prayer.asr, NoorSky.asr),
    (Prayer.maghrib, NoorSky.maghrib),
    (Prayer.isha, NoorSky.isha),
  ]) {
    testWidgets('${prayer.key} rings under the ${sky.name} sky',
        (tester) async {
      await _pump(tester, _ring(prayer));
      expect(_asset(tester, 'adhan-sky'), sky.asset);
      // Only Isha's sky has stars to twinkle, and a moon of its own; the
      // rest get the crescent.
      expect(find.byType(NoorTwinkle),
          sky == NoorSky.isha ? findsOneWidget : findsNothing);
      expect(find.byKey(const ValueKey('adhan-moon')),
          sky == NoorSky.isha ? findsNothing : findsOneWidget);
    });
  }

  testWidgets('each button acts once', (tester) async {
    var stops = 0, athkar = 0;
    await _pump(tester, _ring(Prayer.asr),
        onStop: () => stops++, onOpenAthkar: () => athkar++);

    await tester.tap(find.text(S.current.stop_adhan));
    await tester.pump();
    await tester.tap(find.text(S.current.stop_adhan));
    await tester.tap(find.text(S.current.open_adhkar));
    await tester.pump();
    expect((stops, athkar), (1, 0));
  });

  for (final locale in const [Locale('en'), Locale('fr'), Locale('ar')]) {
    testWidgets('ring screen scrolls on a 320 dp phone at 200%: $locale',
        (tester) async {
      await _pump(
        tester,
        _ring(Prayer.maghrib),
        locale: locale,
        theme: AppTheme.dark(),
        size: const Size(320, 640),
        ratio: 1,
        scale: 2.0,
      );

      expect(tester.takeException(), isNull);
      // Both buttons stay reachable by scrolling.
      await tester.ensureVisible(find.text(S.current.open_adhkar));
      expect(tester.takeException(), isNull);
    });
  }

  group('AdhanRing.of', () {
    final at = DateTime(2026, 1, 1, 5, 0);

    test('an adhan is at its own time, on any day of the window', () {
      for (final id in [
        Prayer.isha.adhanId,
        AdhanScheduler.idFor(Prayer.isha.adhanId, 3),
      ]) {
        final ring = AdhanRing.of(id: id, alarmTime: at);
        expect(ring.prayer, Prayer.isha);
        expect(ring.prayerTime, at);
      }
    });

    test('a reminder takes the prayer time back from its offset', () {
      int minutes(Prayer p, int slot) => slot == 1 ? -10 : 15;
      final before = AdhanRing.of(
          id: AdhanScheduler.idFor(Prayer.fajr.alarmIdForSlot(1), 2),
          alarmTime: at,
          reminderMinutes: minutes);
      expect(before.prayer, Prayer.fajr);
      expect(before.prayerTime, at.add(const Duration(minutes: 10)));

      final after = AdhanRing.of(
          id: Prayer.asr.alarmIdForSlot(2),
          alarmTime: at,
          reminderMinutes: minutes);
      expect(after.prayer, Prayer.asr);
      expect(after.prayerTime, at.subtract(const Duration(minutes: 15)));
    });

    test('an id that is no prayer has none', () {
      expect(AdhanRing.of(id: 9, alarmTime: at).prayer, isNull);
    });
  });

  group('loadAdhanRing', () {
    final at = DateTime(2026, 1, 1, 18, 2);

    Future<void> save(List<AlarmSettings> alarms) async {
      SharedPreferences.setMockInitialValues({
        for (final a in alarms)
          '__alarm_id__${a.id}': jsonEncode(a.toJson()),
      });
      await SharedPrefService.init();
    }

    test('reads the ringing alarm the plugin saved', () async {
      final id = AdhanScheduler.idFor(Prayer.maghrib.adhanId, 1);
      await save([
        _settings(id, at),
        _settings(Prayer.isha.adhanId, at.add(const Duration(hours: 1))),
      ]);
      final ring = await loadAdhanRing({'id': id});
      expect((ring.id, ring.prayer, ring.prayerTime, ring.title),
          (id, Prayer.maghrib, at, 'Maghrib'));
    });

    test('without an id, takes the latest alarm already due', () async {
      final now = DateTime.now();
      await save([
        _settings(Prayer.asr.adhanId, now.subtract(const Duration(hours: 3))),
        _settings(
            Prayer.maghrib.adhanId, now.subtract(const Duration(minutes: 1))),
        _settings(Prayer.isha.adhanId, now.add(const Duration(hours: 1))),
      ]);
      final ring = await loadAdhanRing({'id': 0});
      expect(ring.prayer, Prayer.maghrib);
    });

    test('an alarm the plugin no longer has keeps its id and title', () async {
      await save([]);
      final ring = await loadAdhanRing(
          {'id': Prayer.dhuhr.adhanId, 'title': 'Dhuhr adhan'});
      expect((ring.prayer, ring.title), (Prayer.dhuhr, 'Dhuhr adhan'));
    });
  });
}

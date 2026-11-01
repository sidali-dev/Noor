import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor/features/adhan/adhan_ring_screen.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

AlarmSettings _settings(Prayer prayer, {String body = ''}) => AlarmSettings(
      id: prayer.adhanId,
      dateTime: DateTime(2026, 1, 1, 15, 34),
      assetAudioPath: 'a.mp3',
      loopAudio: false,
      vibrate: false,
      volumeSettings: const VolumeSettings.fixed(volume: 0.5),
      warningNotificationOnKill: false,
      androidFullScreenIntent: false,
      notificationSettings: NotificationSettings(
        title: 'title',
        body: body,
        stopButton: 'stop',
      ),
    );

Future<void> _pump(
  WidgetTester tester,
  AlarmSettings settings, {
  required Locale locale,
  required ThemeData theme,
  Size size = const Size(840, 1870),
  double ratio = 2.1,
  double scale = 1.3,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = ratio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: theme,
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
    home: AdhanRingScreen(alarmSettings: settings),
  ));
  await tester.pump();
}

void main() {
  setUp(() async {
    // dispose() calls Alarm.stop, which needs the plugin's storage.
    SharedPreferences.setMockInitialValues({});
  });

  for (final (name, locale, theme) in [
    ('ar paper', const Locale('ar'), NoorTheme.light()),
    ('ar night', const Locale('ar'), NoorTheme.dark()),
    ('fr paper', const Locale('fr'), NoorTheme.light()),
    ('en night', const Locale('en'), NoorTheme.dark()),
  ]) {
    testWidgets('ring screen at text scale 1.3 without overflow: $name',
        (tester) async {
      await tester.runAsync(() => Alarm.init());
      // Maghrib is the longest name.
      await _pump(
        tester,
        _settings(Prayer.maghrib, body: 'حان وقت الذهاب إلى المسجد'),
        locale: locale,
        theme: theme,
      );

      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.text('المغرب'), findsOneWidget);
      expect(find.text('15:34'), findsOneWidget);
      expect(find.text('حان وقت الذهاب إلى المسجد'), findsOneWidget);
      expect(find.text(S.current.stop_adhan), findsOneWidget);
      expect(find.text(S.current.open_adhkar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in const [Locale('en'), Locale('fr'), Locale('ar')]) {
    testWidgets('ring screen scrolls on a 320 dp phone at 200%: $locale',
        (tester) async {
      await tester.runAsync(() => Alarm.init());
      await _pump(
        tester,
        _settings(Prayer.maghrib, body: 'حان وقت الذهاب إلى المسجد ' * 4),
        locale: locale,
        theme: NoorTheme.dark(),
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
}

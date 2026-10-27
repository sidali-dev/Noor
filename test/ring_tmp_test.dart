import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor/features/adhan/adhan_ring_screen.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Future<void> _font(String family, List<String> files) async {
  final l = FontLoader(family);
  for (final f in files) {
    l.addFont(rootBundle.load(f));
  }
  await l.load();
}

void main() {
  testWidgets(
      'ring screen shows prayer, time and both actions without overflow',
      (tester) async {
    // dispose() calls Alarm.stop, which needs the plugin's storage.
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() => Alarm.init(showDebugLogs: false));
    tester.view.physicalSize = const Size(840, 1870);
    tester.view.devicePixelRatio = 2.1;
    addTearDown(tester.view.reset);

    final settings = AlarmSettings(
      id: 1,
      dateTime: DateTime(2026, 1, 1, 15, 34),
      assetAudioPath: 'a.mp3',
      loopAudio: false,
      vibrate: false,
      volume: 0.5,
      fadeDuration: 0,
      warningNotificationOnKill: false,
      androidFullScreenIntent: false,
      notificationSettings: const NotificationSettings(
        title: 'أذان العصر',
        body: 'حان وقت الذهاب إلى المسجد',
        stopButton: 'stop',
      ),
    );

    await tester.pumpWidget(MaterialApp(
      theme: NoorTheme.light(),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: AdhanRingScreen(alarmSettings: settings),
    ));
    await tester.runAsync(() async {
      await _font('Amiri', ['assets/fonts/amiri/Amiri-Bold.ttf', 'assets/fonts/amiri/Amiri-Regular.ttf']);
      await _font('Plex', ['assets/fonts/plex/IBMPlexSansArabic-SemiBold.ttf', 'assets/fonts/plex/IBMPlexSansArabic-Regular.ttf']);
      await _font('Spectral', ['assets/fonts/spectral/Spectral-Medium.ttf']);
    });
    await tester.pump();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('ring_tmp.png'));

    expect(find.text('15:34'), findsOneWidget);
    expect(find.text('أذان العصر'), findsOneWidget);
    expect(find.text(S.current.open_adhkar), findsOneWidget);
    expect(find.text(S.current.close), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

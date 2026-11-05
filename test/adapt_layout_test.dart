import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/adhan/adhan_ring_screen.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_nav_bar.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _phone = Size(412, 915);
const _small = Size(320, 640);
const _fold = Size(673, 841);
const _tabletPortrait = Size(800, 1280);
const _tabletLandscape = Size(1280, 800);
const _phoneLandscape = Size(844, 390);
const _sizes = {
  '320 dp': _small,
  'phone': _phone,
  'foldable': _fold,
  'tablet portrait': _tabletPortrait,
  'tablet landscape': _tabletLandscape,
  'phone landscape': _phoneLandscape,
};

Future<void> _pump(
  WidgetTester tester,
  Size size,
  Widget home, {
  Locale locale = const Locale('ar'),
  double scale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: NoorTheme.light(),
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
    home: home,
  ));
  await tester.pump(const Duration(milliseconds: 400));
}

const _hero = NoorHero(
  art: NoorArt.objectQuran,
  title: 'القرآن',
  subtitle:
      'إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ — الإسراء 9',
  settings: true,
  overlap: SizedBox(height: 56),
);

const _artKey = ValueKey('noor-hero-art');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final e in _sizes.entries) {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final scale in const [1.0, 2.0]) {
        final name = '${e.key} / $locale / x$scale';

        testWidgets('hero fits: $name', (tester) async {
          await _pump(
              tester, e.value, const SingleChildScrollView(child: _hero),
              locale: locale, scale: scale);
          expect(tester.takeException(), isNull);
          final short = e.value.height < NoorLayout.shortHeight;
          expect(find.byKey(_artKey).evaluate().isEmpty, short);
          if (!short) {
            // The art stops growing past a phone and keeps to the end side.
            expect(tester.getSize(find.byKey(_artKey)).width,
                lessThanOrEqualTo(480));
          }
        });

        testWidgets('nav bar stays in the column: $name', (tester) async {
          await _pump(
            tester,
            e.value,
            Scaffold(
              bottomNavigationBar:
                  NoorNavBar(selectedIndex: 0, onItemSelected: (_) {}),
            ),
            locale: locale,
            scale: scale,
          );
          expect(tester.takeException(), isNull);
          expect(tester.getSize(find.byType(NoorNavBar)).width,
              lessThanOrEqualTo(e.value.width));
          final bar = find.descendant(
              of: find.byType(NoorNavBar), matching: find.byType(DecoratedBox));
          expect(tester.getSize(bar.first).width,
              lessThanOrEqualTo(NoorLayout.columnWidth));
        });

        testWidgets('ring screen fits: $name', (tester) async {
          final alarm = AlarmSettings(
            id: Prayer.fajr.adhanId,
            dateTime: DateTime(2026, 1, 1, 5, 0),
            assetAudioPath: 'a.mp3',
            loopAudio: false,
            vibrate: false,
            volumeSettings: const VolumeSettings.fixed(volume: 0.5),
            warningNotificationOnKill: false,
            androidFullScreenIntent: false,
            notificationSettings: const NotificationSettings(
                title: 'Fajr', body: 'in 10 minutes', stopButton: 'stop'),
          );
          await _pump(tester, e.value, AdhanRingScreen(alarmSettings: alarm),
              locale: locale, scale: scale);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('sheet is held to the column on a tablet', (tester) async {
    await _pump(
      tester,
      _tabletLandscape,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showNoorSheet(
            context,
            title: 'T',
            builder: (_) => const SizedBox(height: 80),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(NoorSheet)).width,
        lessThanOrEqualTo(NoorLayout.columnWidth));
  });
}

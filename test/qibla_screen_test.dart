import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/features/qibla/qibla_controller.dart';
import 'package:noor/features/qibla/qibla_screen.dart';
import 'package:noor/features/qibla/widgets/qibla_calibration_sheet.dart';
import 'package:noor/features/qibla/widgets/qibla_compass.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('ar'),
  ThemeData? theme,
  double textScale = 1.0,
}) {
  return GetMaterialApp(
    theme: theme ?? NoorTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    builder: (c, w) => MediaQuery(
      data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)),
      child: w!,
    ),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('afterTabSwitch', () {
    const settle = Duration(milliseconds: 400);
    const justShort = Duration(milliseconds: 399);
    const rest = Duration(milliseconds: 1);

    testWidgets('starts and stops the source late, passing events through',
        (tester) async {
      var starts = 0, stops = 0;
      final source = StreamController<int>.broadcast(
        onListen: () => starts++,
        onCancel: () => stops++,
      );
      final got = <Object>[];
      final sub =
          afterTabSwitch(() => source.stream).listen(got.add, onError: got.add);

      await tester.pump(justShort);
      expect(starts, 0);
      await tester.pump(rest);
      expect(starts, 1);

      source
        ..add(7)
        ..addError('no sensor');
      await tester.pump();
      expect(got, [7, 'no sensor']);

      // Not awaited: it completes outside the test's fake clock, and hangs pump.
      sub.cancel();
      await tester.pump(justShort);
      expect(stops, 0);
      await tester.pump(rest);
      expect(stops, 1);
    });

    testWidgets('never starts the source when left before it settles',
        (tester) async {
      var starts = 0;
      final source = StreamController<int>.broadcast(onListen: () => starts++);
      final sub = afterTabSwitch(() => source.stream).listen((_) {});

      await tester.pump(justShort);
      sub.cancel();
      await tester.pump(settle * 2);
      expect(starts, 0);
    });

    testWidgets('can be listened to again after a cancel', (tester) async {
      var starts = 0;
      final source = StreamController<int>.broadcast(onListen: () => starts++);
      final stream = afterTabSwitch(() => source.stream);

      stream.listen((_) {}).cancel();
      final again = stream.listen((_) {});
      await tester.pump(settle);
      expect(starts, 1);
      again.cancel();
      await tester.pump(settle);
    });
  });

  group('QiblaDirectionCard Widget Tests', () {
    testWidgets('pumps direction card and asserts degrees and distance text',
        (WidgetTester tester) async {
      bool calibrated = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: QiblaDirectionCard(
            offset: 105.35,
            distanceKm: 11280,
            onCalibrate: () {
              calibrated = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert degrees text
      expect(find.text('105.35°'), findsOneWidget);

      // Assert distance to Kaaba text
      expect(find.text('~ 11280 km'), findsOneWidget);

      // Assert calibrate button is found and can be tapped
      final calibrateFinder = find.byType(NoorButton);
      expect(calibrateFinder, findsWidgets);

      await tester.tap(calibrateFinder.first);
      expect(calibrated, isTrue);
    });

    testWidgets('hides distance row when distanceKm is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const QiblaDirectionCard(
            offset: 42.10,
            distanceKm: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert degrees text
      expect(find.text('42.10°'), findsOneWidget);

      // Assert distance text is not shown
      expect(find.textContaining('km'), findsNothing);
    });

    testWidgets('compass shrinks to the height it is given',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const SizedBox(
            width: 360,
            height: 170,
            child: QiblaCompass(direction: 30, qiblah: 105),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(QiblaCompass)).height,
          lessThanOrEqualTo(170));
    });

    testWidgets('renders properly in dark mode and English locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          theme: NoorTheme.dark(),
          locale: const Locale('en'),
          child: const QiblaDirectionCard(
            offset: 90.00,
            distanceKm: 5400,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('90.00°'), findsOneWidget);
      expect(find.text('~ 5400 km'), findsOneWidget);
    });
  });

  group('Qibla look', () {
    testWidgets('the compass announces facing the qibla only when aligned',
        (tester) async {
      final handle = tester.ensureSemantics();
      final label = (await S.load(const Locale('en'))).facing_qibla;

      Future<void> pump(double qiblah) async {
        await tester.pumpWidget(_buildTestApp(
          locale: const Locale('en'),
          child: QiblaCompass(direction: 40, qiblah: qiblah),
        ));
        await tester.pump(const Duration(milliseconds: 300));
      }

      await pump(1);
      expect(find.bySemanticsLabel(label), findsOneWidget);
      await pump(105);
      expect(find.bySemanticsLabel(label), findsNothing);
      handle.dispose();
    });

    testWidgets('the rim turns success when aligned, with no chip',
        (tester) async {
      final success = NoorTheme.light().extension<NoorColors>()!.success;
      Color? rim() => ((tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
              .decoration) as BoxDecoration)
          .border
          ?.top
          .color;

      Future<void> pump(double qiblah) async {
        await tester.pumpWidget(_buildTestApp(
          locale: const Locale('en'),
          child: QiblaCompass(direction: 40, qiblah: qiblah),
        ));
        await tester.pump(const Duration(milliseconds: 300));
      }

      await pump(1);
      expect(rim(), success);
      expect(find.text('Facing the qibla'), findsNothing);
      await pump(105);
      expect(rim(), isNot(success));
    });

    for (final scale in [1.3, 2.0]) {
      for (final loc in ['ar', 'fr', 'en']) {
        for (final dark in [false, true]) {
          testWidgets(
              'card, compass and sheet lay out at $scale, $loc dark $dark',
              (tester) async {
            tester.view.physicalSize = const Size(1080, 3200);
            tester.view.devicePixelRatio = 3;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(_buildTestApp(
              locale: Locale(loc),
              theme: dark ? NoorTheme.dark() : NoorTheme.light(),
              textScale: scale,
              child: const SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: QiblaCompass(direction: 40, qiblah: 2),
                    ),
                    QiblaDirectionCard(offset: 105.35, distanceKm: 11280),
                    QiblaCalibrationContent(),
                  ],
                ),
              ),
            ));
            await tester.pump(const Duration(milliseconds: 400));

            expect(tester.takeException(), isNull);
            expect(find.text('105.35°'), findsOneWidget);
          });
        }
      }
    }

    testWidgets('the calibration sheet lists three numbered steps',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        locale: const Locale('en'),
        child: const SingleChildScrollView(child: QiblaCalibrationContent()),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      for (final n in ['1', '2', '3']) {
        expect(find.text(n), findsOneWidget);
      }
    });

    testWidgets('the figure-8 guide sits in a sunken well, tips have no icons',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(
        locale: const Locale('en'),
        child: const SingleChildScrollView(child: QiblaCalibrationContent()),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.descendant(
          of: find.byType(NoorWell),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
      expect(find.byType(NoorButton), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/features/qibla/qibla_screen.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('ar'),
  ThemeData? theme,
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
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      final calibrateFinder = find.byType(InkWell);
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
}

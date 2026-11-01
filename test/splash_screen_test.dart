import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/splash_screen.dart';
import 'package:noor/generals/widgets/arch_frame.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _app(Future<void> ready, {ThemeData? theme, bool reduce = false}) =>
    MaterialApp(
      theme: theme ?? NoorTheme.light(),
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: SplashScreen(ready: ready, next: (_) => const Text('shell')),
    );

Future<void> _settleArt(WidgetTester tester) => tester
    .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));

void main() {
  testWidgets('splash holds until startup is ready, then shows next',
      (tester) async {
    final ready = Completer<void>();
    await tester.pumpWidget(_app(ready.future));
    await _settleArt(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('shell'), findsNothing);
    expect(find.text('FAITH'), findsOneWidget);
    expect(find.text('نور الإيمان'), findsOneWidget);
    expect(find.byType(ArchFrame), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    ready.complete();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('shell'), findsOneWidget);
  });

  testWidgets('night theme builds the same hero', (tester) async {
    await tester
        .pumpWidget(_app(Completer<void>().future, theme: NoorTheme.dark()));
    await _settleArt(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ArchFrame), findsOneWidget);
    expect(find.text('FAITH'), findsOneWidget);
  });

  testWidgets('twinkle runs normally and is off under reduced motion',
      (tester) async {
    await tester.pumpWidget(_app(Completer<void>().future));
    await _settleArt(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(Completer<void>().future, reduce: true));
    await _settleArt(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('FAITH'), findsOneWidget);
  });
}

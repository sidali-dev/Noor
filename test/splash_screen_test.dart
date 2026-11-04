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

/// A real run of frames: one long pump draws only one, at its end.
Future<void> _frames(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _Counted extends StatefulWidget {
  const _Counted(this.built);
  final List<int> built;

  @override
  State<_Counted> createState() => _CountedState();
}

class _CountedState extends State<_Counted> {
  @override
  void initState() {
    super.initState();
    widget.built.add(widget.built.length + 1);
  }

  @override
  Widget build(BuildContext context) => const Text('shell');
}

void main() {
  testWidgets('splash holds until ready, then for its minimum over the shell',
      (tester) async {
    final ready = Completer<void>();
    await tester.pumpWidget(_app(ready.future));
    await _settleArt(tester);
    await _frames(tester, 400);
    expect(find.text('shell'), findsNothing);
    expect(find.text('FAITH'), findsOneWidget);
    expect(find.byType(ArchFrame), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    ready.complete();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    // Loading under the splash, for its minimum time.
    await _frames(tester, 900);
    expect(find.text('shell'), findsOneWidget);
    expect(find.text('FAITH'), findsOneWidget);

    await _frames(tester, 400);
    expect(find.text('shell'), findsOneWidget);
    expect(find.text('FAITH'), findsNothing);
  });

  testWidgets('the shell under the splash stays mounted when it lifts',
      (tester) async {
    final built = <int>[];
    await tester.pumpWidget(MaterialApp(
      theme: NoorTheme.light(),
      home: SplashScreen(
        ready: Future<void>.value(),
        next: (_) => _Counted(built),
      ),
    ));
    await _settleArt(tester);
    await _frames(tester, 400);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await _frames(tester, 1400);

    expect(find.text('FAITH'), findsNothing);
    expect(built, [1]); // one State, never remounted
  });

  testWidgets('under reduced motion the splash lifts at once after its hold',
      (tester) async {
    await tester.pumpWidget(_app(Future<void>.value(), reduce: true));
    await _settleArt(tester);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await _frames(tester, 1100);
    expect(find.text('shell'), findsOneWidget);
    expect(find.text('FAITH'), findsNothing);
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

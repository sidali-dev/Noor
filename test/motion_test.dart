import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _app(Widget child, {bool reduce = false}) => MaterialApp(
      theme: NoorTheme.light(),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: c!,
      ),
      home: Scaffold(body: child),
    );

double _opacityOf(WidgetTester tester, Finder f) => tester
    .widget<Opacity>(find.ancestor(of: f, matching: find.byType(Opacity)).first)
    .opacity;

/// Nothing is animating: the route transition is let to finish first.
Future<void> _idle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  expect(tester.binding.transientCallbackCount, 0);
}

void main() {
  test('twinkle stays within 0.85 to 1 and the groups are staggered', () {
    for (var t = 0.0; t <= 1; t += 0.01) {
      for (var i = 0; i < 7; i++) {
        expect(noorTwinkleOpacity(t, i), inInclusiveRange(0.85, 1));
      }
    }
    expect(noorTwinkleOpacity(0, 0), isNot(noorTwinkleOpacity(0, 1)));
    expect(noorTwinkleOpacity(0, 0), noorTwinkleOpacity(0, 3));
    expect(kNoorTwinkleCycle, const Duration(seconds: 8));
  });

  group('NoorSettle', () {
    testWidgets('fades from 0 and rises 6 dp over 200 ms, once',
        (tester) async {
      await tester.pumpWidget(_app(const NoorSettle(child: Text('x'))));
      final rest = tester.getTopLeft(find.text('x')).dy;
      expect(_opacityOf(tester, find.text('x')), 0);
      expect(rest, greaterThan(0)); // first frame sits kNoorSettleDistance low

      await tester.pump(kNoorSettleDuration);
      expect(_opacityOf(tester, find.text('x')), 1);
      expect(tester.getTopLeft(find.text('x')).dy, rest - kNoorSettleDistance);
      await _idle(tester);

      await tester.pumpWidget(_app(const NoorSettle(child: Text('x'))));
      await tester.pump();
      expect(_opacityOf(tester, find.text('x')), 1);
    });

    testWidgets('is the bare child under Reduce Motion', (tester) async {
      await tester
          .pumpWidget(_app(const NoorSettle(child: Text('x')), reduce: true));
      expect(find.byType(Opacity), findsNothing);
      await _idle(tester);
    });
  });

  group('NoorTwinkle', () {
    Widget twinkle() => NoorTwinkle(
          builder: (_, t) => Text(t == null ? 'still' : 'loop'),
        );

    testWidgets('loops, and stops when hidden or unmounted', (tester) async {
      await tester.pumpWidget(_app(twinkle()));
      expect(find.text('loop'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester
          .pumpWidget(_app(TickerMode(enabled: false, child: twinkle())));
      await tester.pump();
      await _idle(tester);

      await tester.pumpWidget(_app(twinkle()));
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester.pumpWidget(_app(const SizedBox()));
      await _idle(tester);
    });

    testWidgets('is still under Reduce Motion, and live changes apply',
        (tester) async {
      await tester.pumpWidget(_app(twinkle(), reduce: true));
      expect(find.text('still'), findsOneWidget);
      await _idle(tester);

      await tester.pumpWidget(_app(twinkle()));
      expect(find.text('loop'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester.pumpWidget(_app(twinkle(), reduce: true));
      await tester.pump();
      expect(find.text('still'), findsOneWidget);
      await _idle(tester);
    });
  });

  group('sheet', () {
    Future<void> open(WidgetTester tester, {required bool reduce}) async {
      await tester.pumpWidget(_app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showNoorSheet<void>(
              context,
              title: 'T',
              builder: (_) => const SizedBox(height: 200, child: Text('body')),
            ),
            child: const Text('open'),
          ),
        ),
        reduce: reduce,
      ));
      await tester.tap(find.text('open'));
      await tester.pump();
    }

    testWidgets('rises onto the page over 200 ms', (tester) async {
      await open(tester, reduce: false);
      await tester.pump(const Duration(milliseconds: 20));
      final early = tester.getTopLeft(find.text('body')).dy;
      await tester.pump(kNoorSettleDuration);
      final rest = tester.getTopLeft(find.text('body')).dy;
      expect(early, greaterThan(rest));
      await _idle(tester);
    });

    testWidgets('appears in place under Reduce Motion', (tester) async {
      await open(tester, reduce: true);
      await tester.pump(const Duration(milliseconds: 1));
      final first = tester.getTopLeft(find.text('body')).dy;
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.getTopLeft(find.text('body')).dy, first);
    });
  });
}

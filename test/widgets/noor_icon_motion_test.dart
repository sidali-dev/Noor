import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';

Widget _app(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: AppTheme.light(),
    builder: (context, c) => MediaQuery(
      data:
          MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
      child: c!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('NoorIcon', () {
    testWidgets('draws every glyph at the requested size', (tester) async {
      for (final g in NoorGlyph.values) {
        await tester.pumpWidget(_app(NoorIcon(g, size: 20)));
        expect(tester.getSize(find.byType(SvgPicture)), const Size(20, 20),
            reason: g.name);
      }
    });

    testWidgets('keeps its size inside a tight box', (tester) async {
      await tester.pumpWidget(_app(
        const SizedBox(
          width: 56,
          height: 56,
          child: NoorIcon(NoorGlyph.calendar, size: 28),
        ),
      ));
      expect(tester.getSize(find.byType(SvgPicture)), const Size(28, 28));
    });

    testWidgets('takes size and colour from the ambient IconTheme',
        (tester) async {
      await tester.pumpWidget(_app(
        const IconTheme(
          data: IconThemeData(size: 18, color: Colors.red),
          child: NoorIcon(NoorGlyph.plus),
        ),
      ));
      expect(tester.getSize(find.byType(SvgPicture)), const Size(18, 18));
      final filter =
          tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter;
      expect(filter, const ColorFilter.mode(Colors.red, BlendMode.srcIn));
    });
  });

  group('NoorSettle', () {
    const key = Key('child');
    const child = SizedBox(key: key, width: 40, height: 40);

    testWidgets('fades from 0 and rises into place, then rests',
        (tester) async {
      await tester.pumpWidget(_app(const NoorSettle(child: child)));
      double y() => tester.getTopLeft(find.byKey(key)).dy;
      final startY = y();
      Opacity op() => tester.widget<Opacity>(
          find.ancestor(of: find.byKey(key), matching: find.byType(Opacity)));

      expect(op().opacity, 0);

      await tester.pump(kNoorSettleDuration ~/ 2);
      expect(op().opacity, inExclusiveRange(0, 1));
      final midY = y();

      await tester.pump(kNoorSettleDuration);
      final restY = y();
      expect(op().opacity, 1);
      expect(startY, restY + kNoorSettleDistance);
      expect(midY, inExclusiveRange(restY, startY));
    });

    testWidgets('does nothing when animations are disabled', (tester) async {
      await tester.pumpWidget(
          _app(const NoorSettle(child: child), disableAnimations: true));
      expect(find.byType(Opacity), findsNothing);
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      expect(find.byKey(key), findsOneWidget);
    });
  });
}

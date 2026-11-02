import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/check_dialog.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_pager_pill.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Widget _app(Locale locale, Widget child) {
  return MaterialApp(
    theme: NoorTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.3)),
      child: c!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('NoorSheet', () {
    testWidgets('dismisses when the handle area is swiped down',
        (tester) async {
      var closed = false;
      Object? result = 'pending';

      await tester.pumpWidget(_app(
        const Locale('ar'),
        Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              result = await showNoorSheet<String>(
                ctx,
                title: 'الإعدادات',
                builder: (_) => const Text('content'),
              );
              closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('content'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);

      // The title sits outside the scroll view, so the drag reaches the sheet.
      await tester.fling(find.text('الإعدادات'), const Offset(0, 400), 1500);
      await tester.pumpAndSettle();

      expect(find.text('content'), findsNothing);
      expect(closed, isTrue);
      expect(result, isNull);
    });
  });

  group('NoorPagePanel', () {
    Finder clouds() => find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is CloudBankPainter);

    testWidgets('a card keeps its content clear of the clouds', (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        const NoorCard(child: SizedBox(key: ValueKey('c'), height: 40, width: 200)),
      ));
      final content = tester.getRect(find.byKey(const ValueKey('c')));
      expect(content.bottom, lessThanOrEqualTo(tester.getTopLeft(clouds()).dy));
    });

    testWidgets('a sheet gives its clouds up to the keyboard', (tester) async {
      Widget sheet(double keyboard) => _app(
            const Locale('en'),
            Builder(
              builder: (c) => MediaQuery(
                data: MediaQuery.of(c).copyWith(
                  viewInsets: EdgeInsets.only(bottom: keyboard),
                ),
                child: const NoorSheet(title: 'Title', child: Text('content')),
              ),
            ),
          );

      await tester.pumpWidget(sheet(0));
      expect(clouds(), findsOneWidget);

      await tester.pumpWidget(sheet(300));
      expect(clouds(), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });
  });

  group('CheckDialog', () {
    testWidgets('Done closes it once; the timer never pops the page below',
        (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        Builder(
          builder: (ctx) => TextButton(
            onPressed: () => showDialog<void>(
              context: ctx,
              builder: (_) => const CheckDialog(
                title: 'Saved',
                icon: Icons.check_rounded,
                color: Colors.green,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('Saved'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-exit the dialog is still mounted when the 2.2 s timer would fire.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('NoorPagerPill', () {
    for (final split in [true, false]) {
      testWidgets(
          'RTL: previous at the start (right), next at the left, '
          'split=$split', (tester) async {
        var previous = 0;
        var next = 0;

        await tester.pumpWidget(_app(
          const Locale('ar'),
          NoorPagerPill(
            label: '12',
            split: split,
            onPrevious: () => previous++,
            onNext: () => next++,
            previousTooltip: 'prev',
            nextTooltip: 'next',
          ),
        ));

        final prevX = tester.getCenter(find.byTooltip('prev')).dx;
        final nextX = tester.getCenter(find.byTooltip('next')).dx;
        final labelX = tester.getCenter(find.text('12')).dx;
        expect(nextX, lessThan(labelX));
        expect(labelX, lessThan(prevX));

        // Left = next page.
        await tester.tap(find.byTooltip('next'));
        expect((previous, next), (0, 1));
        await tester.tap(find.byTooltip('prev'));
        expect((previous, next), (1, 1));
      });
    }

    testWidgets('LTR: the order is reversed', (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        NoorPagerPill(
          label: '12',
          split: true,
          onPrevious: () {},
          onNext: () {},
          previousTooltip: 'prev',
          nextTooltip: 'next',
        ),
      ));

      expect(
        tester.getCenter(find.byTooltip('prev')).dx,
        lessThan(tester.getCenter(find.byTooltip('next')).dx),
      );
    });
  });
}

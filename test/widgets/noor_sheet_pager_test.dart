import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';

Widget _app(Locale locale, Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
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
    testWidgets('dismisses when its title area is swiped down', (tester) async {
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
    Finder clouds() => find.byType(NoorMotifBand);

    testWidgets('a card keeps its content clear of the clouds', (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        const NoorCard(
            child: SizedBox(key: ValueKey('c'), height: 40, width: 200)),
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
}

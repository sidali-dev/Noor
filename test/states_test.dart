import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/adhan/views/widgets/permission_notice.dart';
import 'package:noor/core/widgets/empty_state.dart';
import 'package:noor/core/widgets/loading_state.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';

Widget _app(
  Widget Function(BuildContext) build, {
  Locale locale = const Locale('en'),
  bool dark = false,
  bool reduceMotion = false,
}) {
  return MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.3),
        disableAnimations: reduceMotion,
      ),
      child: child!,
    ),
    home: Scaffold(body: Builder(builder: build)),
  );
}

void main() {
  testWidgets('error state is a danger glyph with the alert shape and a word',
      (tester) async {
    await tester.pumpWidget(_app((c) => EmptyState(
          danger: true,
          icon: NoorGlyph.alert,
          message: S.of(c).prayer_times_failed,
          actionLabel: S.of(c).try_again,
          onAction: () {},
        )));
    await tester.pumpAndSettle();

    final icon = tester.widget<NoorIcon>(find.byType(NoorIcon));
    expect(icon.glyph, NoorGlyph.alert);
    expect(icon.color, AppTheme.light().extension<NoorColors>()!.danger);
    expect(find.text("Couldn't load prayer times"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('empty state is not danger; noResults uses the search glyph',
      (tester) async {
    await tester.pumpWidget(_app(EmptyState.noResults));
    await tester.pumpAndSettle();

    final icon = tester.widget<NoorIcon>(find.byType(NoorIcon));
    expect(icon.glyph, NoorGlyph.search);
    expect(icon.color, AppTheme.light().extension<NoorColors>()!.muted);
  });

  testWidgets('loading shows three dots, and keeps still under reduced motion',
      (tester) async {
    await tester.pumpWidget(_app((_) => const LoadingState(message: 'Wait')));
    expect(find.byType(LoadingDots), findsOneWidget);
    expect(find.text('Wait'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpWidget(_app(
      (_) => const LoadingState(),
      reduceMotion: true,
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, 0);
    expect(find.byType(LoadingDots), findsOneWidget);
    expect(find.byType(DecoratedBox), findsWidgets);
  });

  testWidgets('permission notice says nothing when the status is unreadable',
      (tester) async {
    await tester.pumpWidget(_app((_) => const PermissionNotice()));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsNothing);
  });

  group('no overflow at 1.3x text', () {
    for (final locale in const ['ar', 'fr', 'en']) {
      for (final dark in [false, true]) {
        testWidgets('$locale ${dark ? 'dark' : 'light'}', (tester) async {
          await tester.pumpWidget(_app(
            (c) {
              final s = S.of(c);
              return ListView(children: [
                EmptyState(
                  danger: true,
                  icon: NoorGlyph.alert,
                  message: s.no_internet,
                  actionLabel: s.try_again,
                  onAction: () {},
                ),
                EmptyState(
                  icon: NoorGlyph.compass,
                  message: s.alarms_off,
                  actionLabel: s.open_settings,
                  onAction: () {},
                ),
                LoadingState(message: s.wait_please),
              ]);
            },
            locale: Locale(locale),
            dark: dark,
            reduceMotion: true, // the bouncing dots never settle
          ));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}

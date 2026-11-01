import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/location_flow.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_radio.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

void main() {
  for (final loc in ['ar', 'fr', 'en']) {
    testWidgets(
        'location sheet: one grouped radio list, Confirm after a pick, '
        '$loc at 1.3', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        locale: Locale(loc),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: w!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => pickLocation(context),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final s = await S.load(Locale(loc));
      expect(find.byType(NoorListRow), findsNWidgets(2));
      expect(find.byType(NoorRadioMark), findsNWidgets(2));
      expect(
        tester.widget<NoorButton>(find.byType(NoorButton)).onPressed,
        isNull,
      );

      await tester.tap(find.text(s.manually));
      await tester.pumpAndSettle();

      expect(
        tester.widget<NoorButton>(find.byType(NoorButton)).onPressed,
        isNotNull,
      );
      expect(
        tester.getSemantics(find.text(s.manually)),
        isSemantics(isChecked: true),
      );
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  }
}

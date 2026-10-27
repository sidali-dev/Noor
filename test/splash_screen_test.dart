import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/splash_screen.dart';
import 'package:noor/utils/theme/noor_theme.dart';

void main() {
  testWidgets('splash holds until startup is ready, then shows next',
      (tester) async {
    final ready = Completer<void>();
    await tester.pumpWidget(MaterialApp(
      theme: NoorTheme.light(),
      home: SplashScreen(ready: ready.future, next: (_) => const Text('shell')),
    ));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('shell'), findsNothing);
    expect(find.text('NOOR IMENE'), findsOneWidget);

    ready.complete();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('shell'), findsOneWidget);
  });
}

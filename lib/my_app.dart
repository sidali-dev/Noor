import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:noor/bottom_navigation.dart';
import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/generals/splash_screen.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

import 'generals/controllers/theme_controller.dart';

class MyApp extends StatelessWidget {
  /// App startup still running; the splash holds the shell back until it ends.
  final Future<void> startup;

  const MyApp({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.put(ThemeController());

    LocalizationController localizationController =
        Get.put(LocalizationController());

    return GetMaterialApp(
      title: 'Noor Imene',
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: Locale(localizationController.getLanguage()),
      debugShowCheckedModeBanner: false,
      themeMode:
          themeController.isDarkMode() ? ThemeMode.dark : ThemeMode.light,
      theme: NoorTheme.light(),
      darkTheme: NoorTheme.dark(),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: noorSystemOverlay(Theme.of(context).brightness),
        child: child ?? const SizedBox.shrink(),
      ),
      home: SplashScreen(
        ready: startup,
        next: (_) => const SBottomNavigation(),
      ),
    );
  }
}

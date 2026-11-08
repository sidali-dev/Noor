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

  // Built once: a ThemeData is not cheap, and the same instance lets [Theme]
  // skip notifying dependents when nothing changed.
  static final ThemeData _light = NoorTheme.light();
  static final ThemeData _dark = NoorTheme.dark();

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.put(ThemeController());

    LocalizationController localizationController =
        Get.put(LocalizationController());

    return GetMaterialApp(
      title: 'Faith',
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
      theme: _light,
      darkTheme: _dark,
      // MaterialApp cross-fades themes over ~12 frames, lerping every colour;
      // each frame then rebuilt every kept-alive tab and re-baked every
      // [BakedPaint] (new colours, new cache key), and the night art decoded
      // mid-fade. The app's own Theme snaps to the target in one frame, so
      // nothing below sees the lerped theme. GetMaterialApp has no
      // themeAnimationDuration to set to zero instead.
      builder: (context, child) {
        final theme = themeController.isDarkMode() ? _dark : _light;
        return Theme(
          data: theme,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: noorSystemOverlay(theme.brightness),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: SplashScreen(
        ready: startup,
        next: (_) => const SBottomNavigation(),
      ),
    );
  }
}

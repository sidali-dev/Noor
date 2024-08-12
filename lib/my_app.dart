import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:noor/bottom_navigation.dart';
import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';

import 'features/adhan/adhan_ring_screen.dart';
import 'generals/controllers/theme_controller.dart';
import 'utils/theme/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static StreamSubscription<AlarmSettings>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    Get.to(() => AdhanRingScreen(alarmSettings: alarmSettings));
  }

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.put(ThemeController());

    LocalizationController localizationController =
        Get.put(LocalizationController());

    precacheImage(const AssetImage(SImageString.backgroundImage1), context);
    precacheImage(const AssetImage(SImageString.backgroundImage2), context);
    precacheImage(const AssetImage(SImageString.backgroundImage3), context);
    precacheImage(const AssetImage(SImageString.backgroundImage4), context);

    FlutterNativeSplash.remove();

    return GetMaterialApp(
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
      theme: SAppTheme.getLightTheme(true),
      darkTheme: SAppTheme.getDarkTheme(true),
      home: const SBottomNavigation(),
    );
  }
}

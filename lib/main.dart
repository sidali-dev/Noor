import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:noor/core/routes/app_pages.dart';
import 'package:noor/core/services/language_service.dart';
import 'package:noor/core/services/location_service.dart';
import 'package:noor/core/services/theme_service.dart';
import 'package:noor/features/adhan/views/adhan_app.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:noor/features/duaa/controllers/adhkar_data.dart';
import 'package:noor/features/quran/models/mushaf_data.dart';
import 'package:noor/my_app.dart';
import 'package:noor/core/services/shared_prefs_service.dart';
import 'package:workmanager/workmanager.dart';

const String scheduleAdhan = "schedule adhan key";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case scheduleAdhan:
        try {
          await SharedPrefService.init();
          await AdhanScheduler.init();
        } catch (_) {}
      default:
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Theme and language are read from prefs on the first frame.
  await SharedPrefService.init();
  Get.put(ThemeService(), permanent: true);
  Get.put(LanguageService(), permanent: true);
  Get.put(LocationService(), permanent: true);

  AppPages.startup = _startup();
  runApp(const MyApp());
}

/// The adhan screen's own engine, started by Android's AdhanActivity when an
/// alarm rings, whatever state the app is in. It registers shared_preferences
/// only: the alarm plugin stays with the app's engine.
@pragma('vm:entry-point')
Future<void> adhanMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SharedPrefService.init();
  runApp(const AdhanApp());
}

/// The rest of startup. The custom splash waits on it, so alarm and background
/// work setup run alongside instead: Alarm.init re-arms every stored alarm.
Future<void> _startup() async {
  unawaited(AdhanScheduler.init());
  // Workmanager's iOS side needs AppDelegate wiring this app does not have;
  // there the alarm plugin's own background fetch tops the window up.
  if (Platform.isAndroid) unawaited(_registerBackgroundSync());

  await Future.wait([
    AdhkarData.init(),
    MushafData.init(),
  ]);
}

Future<void> _registerBackgroundSync() async {
  try {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask("adhan scheduler", scheduleAdhan,
        frequency: const Duration(hours: 12));
  } catch (_) {
    // Best effort: the alarms still re-sync on every launch.
  }
}

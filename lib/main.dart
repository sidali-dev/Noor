import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/duaa/data/adhkar_data.dart';
import 'package:noor/my_app.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
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

  runApp(MyApp(startup: _startup()));
}

/// The rest of startup. The custom splash waits on it, so alarm and background
/// work setup run alongside instead: Alarm.init re-arms every stored alarm.
Future<void> _startup() async {
  unawaited(AdhanScheduler.init());
  // Workmanager's iOS side needs AppDelegate wiring this app does not have;
  // there the alarm plugin's own background fetch tops the window up.
  if (Platform.isAndroid) unawaited(_registerBackgroundSync());

  await AdhkarData.init();
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

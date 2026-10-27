import 'dart:async';

import 'package:alarm/alarm.dart';
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
          await Alarm.init();
          await AdhanScheduler.sync();
        } catch (_) {}
      default:
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Theme and language are read from prefs on the first frame.
  await SharedPrefService.init();

  runApp(MyApp(startup: _startup()));
}

/// The rest of startup, in its original order. The custom splash waits on it.
Future<void> _startup() async {
  await AdhkarData.init();

  await Alarm.init();

  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask("adhan scheduler", scheduleAdhan,
      frequency: const Duration(hours: 12));

  unawaited(AdhanScheduler.sync());
}

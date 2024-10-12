import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/controllers/adhan_line_controller.dart';
import 'package:noor/my_app.dart';

import 'package:noor/utils/helpers/helper_functions.dart';
import 'package:noor/utils/local_storage/services/database_service.dart';
import 'package:workmanager/workmanager.dart';

import 'utils/local_storage/services/sharedpreferences_service.dart';

const String scheduleAdhan = "schedule adhan key";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case scheduleAdhan:
        try {
          await SharedPrefService.init();

          await Alarm.init();

          await AdhanController.scheduleAdhans();
          await AdhanLineController.scheduleAlarms();
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

  await SharedPrefService.init();

  await DatabaseService.init();

  await Alarm.init();

  await SHelperFunctions.saveInitialValues();

  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask("adhan scheduler", scheduleAdhan,
      frequency: const Duration(hours: 12));

  runApp(const MyApp());
}

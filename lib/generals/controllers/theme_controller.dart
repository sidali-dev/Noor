import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_motion.dart';

class ThemeController extends GetxController {
  bool isDarkMode() {
    return AppPrefs.isDark;
  }

  Future<void> switchTheme() async {
    final next = !isDarkMode();
    await AppPrefs.setIsDark(next);
    NoorThemeSwitch.active = true;
    Get.changeThemeMode(next ? ThemeMode.dark : ThemeMode.light);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NoorThemeSwitch.active = false;
    });
  }
}

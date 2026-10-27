import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';

class ThemeController extends GetxController {
  bool isDarkMode() {
    return AppPrefs.isDark;
  }

  Future<void> switchTheme() async {
    final next = !isDarkMode();
    await AppPrefs.setIsDark(next);
    Get.changeThemeMode(next ? ThemeMode.dark : ThemeMode.light);
  }
}

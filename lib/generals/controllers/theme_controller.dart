import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';

class ThemeController extends GetxController {
  final String _isDark = "isDarkTheme";

  _saveThemeMode(bool isDarkMode) async {
    await SharedPrefService.setBool(_isDark, isDarkMode);
  }

  bool isDarkMode() {
    return SharedPrefService.getBool(_isDark) ?? false;
  }

  switchTheme() async {
    Get.changeThemeMode(isDarkMode() ? ThemeMode.light : ThemeMode.dark);

    await _saveThemeMode(!isDarkMode());
  }
}

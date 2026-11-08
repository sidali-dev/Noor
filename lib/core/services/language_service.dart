import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/services/app_prefs.dart';

class LanguageService extends GetxService {
  String getLanguage() {
    return AppPrefs.languageCode;
  }

  Future<void> setLanguage(String language) async {
    await AppPrefs.setLanguage(language);
    await Get.updateLocale(Locale(language));
  }
}

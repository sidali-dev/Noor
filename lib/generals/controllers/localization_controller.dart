import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';

class LocalizationController extends GetxController {
  String getLanguage() {
    return AppPrefs.languageCode;
  }

  Future<void> setLanguage(String language) async {
    await AppPrefs.setLanguage(language);
    await Get.updateLocale(Locale(language));
  }
}

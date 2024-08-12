import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';

class LocalizationController extends GetxController {
  final String _languageKey = "language";

  _saveLanguage(String language) async {
    await SharedPrefService.setString(_languageKey, language);
  }

  String getLanguage() {
    String storedLanguage = SharedPrefService.getString(_languageKey) ?? 'ar';
    return storedLanguage;
  }

  setLanguage(String language) async {
    await _saveLanguage(language);
    await Get.updateLocale(Locale(getLanguage()));
  }
}

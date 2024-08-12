import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../generated/l10n.dart';
import '../../../utils/local_storage/services/sharedpreferences_service.dart';
import 'package:quran/quran.dart' as quran;

class ReadQuranScreenController extends GetxController {
  RxBool isButtonDisplayed = false.obs;

  RxList<String> savedPagesList =
      SharedPrefService.getString("quran_bookmark")!.split("-").obs;

  RxBool isPageSaved = SharedPrefService.getString("quran_bookmark")!
      .split("-")
      .contains(SharedPrefService.getInt("last_read_quran")!.toString())
      .obs;

  displayHideButton() {
    isButtonDisplayed.value = !isButtonDisplayed.value;
  }

  bookmarkPage(int pageNumber) {
    savedPagesList.value =
        SharedPrefService.getString("quran_bookmark")!.split("-");
    if (savedPagesList.contains("$pageNumber")) {
      savedPagesList.remove("$pageNumber");
    } else {
      savedPagesList.add("$pageNumber");
    }
    String savedPages = "";
    for (var element in savedPagesList) {
      if (element != "") {
        savedPages = "$savedPages$element-";
      }
    }
    SharedPrefService.setString("quran_bookmark", savedPages);
  }

  void isPageSave(int pageNum) {
    isPageSaved.value = savedPagesList.contains(pageNum.toString());
  }

  String getLineTitle(int pageNumber, bool isRtl, BuildContext c) {
    String lastReadSurah = isRtl
        ? quran.getSurahNameArabic(quran.getPageData(pageNumber).first["surah"])
        : quran.getSurahName(quran.getPageData(pageNumber).first["surah"]);
    return "$lastReadSurah \u25CF ${S.of(c).page} $pageNumber";
  }

  void removeBookMark(int pageNum) {
    savedPagesList.remove("$pageNum");

    String savedPages = "";
    for (var element in savedPagesList) {
      if (element != "") {
        savedPages = "$savedPages$element-";
      }
    }
    SharedPrefService.setString("quran_bookmark", savedPages);
  }
}

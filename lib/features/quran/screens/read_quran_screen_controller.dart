import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/widgets/bookmarks_sheet.dart' as sheet;
import 'package:noor/utils/local_storage/app_prefs.dart';

class ReadQuranScreenController extends GetxController {
  final RxBool isButtonDisplayed = false.obs;

  RxList<int> get savedPagesList => AppPrefs.bookmarks.obs;

  bool get isPageSaved => AppPrefs.bookmarks.contains(AppPrefs.lastReadPage);

  void displayHideButton() {
    isButtonDisplayed.value = !isButtonDisplayed.value;
  }

  Future<void> bookmarkPage(int pageNumber) async {
    final list = List<int>.from(AppPrefs.bookmarks);
    if (list.contains(pageNumber)) {
      list.remove(pageNumber);
    } else {
      list.add(pageNumber);
      list.sort();
    }
    await AppPrefs.setBookmarks(list);
  }

  bool isPageSave(int pageNum) {
    return AppPrefs.bookmarks.contains(pageNum);
  }

  String getLineTitle(int pageNumber, bool isRtl, BuildContext c) {
    return sheet.getLineTitle(pageNumber, c);
  }

  Future<void> removeBookMark(int pageNum) async {
    final list = List<int>.from(AppPrefs.bookmarks);
    list.remove(pageNum);
    await AppPrefs.setBookmarks(list);
  }
}

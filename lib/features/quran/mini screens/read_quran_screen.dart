import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/mini%20screens/read_quran_screen_controller.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:quran/quran.dart' as quran;

import '../../../utils/helpers/helper_functions.dart';

class ReadQuranScreen extends StatelessWidget {
  final int surahIndex;

  const ReadQuranScreen({super.key, required this.surahIndex});

  @override
  Widget build(BuildContext context) {
    QuranScreenController quranScreenController = Get.find();

    final controller = PageController(initialPage: surahIndex);
    final ReadQuranScreenController readQuranScreenController =
        Get.put(ReadQuranScreenController());
    readQuranScreenController
        .isPageSave(SharedPrefService.getInt("last_read_quran")!);

    final isDark = SHelperFunctions.isDarkMode(context);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark
              ? const Color.fromARGB(255, 15, 15, 15)
              : const Color.fromARGB(255, 253, 255, 201),
          body: GestureDetector(
            onTap: () {
              readQuranScreenController.displayHideButton();
            },
            child: PageView(
              onPageChanged: (value) {
                SharedPrefService.setInt("last_read_quran", value + 1);
                quranScreenController.updateLastSurahRead();
                quranScreenController.updateLastPageRead();
                readQuranScreenController
                    .isPageSave(SharedPrefService.getInt("last_read_quran")!);
              },
              controller: controller,
              children: [
                for (var i = 1; i <= quran.totalPagesCount; i++)
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          children: [
                            Text(
                              getPageVerses(i),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  height: 2,
                                  color: isDark ? Colors.white : Colors.black,
                                  fontFamily: "Quran"),
                            ),
                            Text(i.toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isDark ? Colors.white : Colors.black))
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          floatingActionButton: Obx(
            () => Visibility(
              visible: readQuranScreenController.isButtonDisplayed.value,
              child: FloatingActionButton(
                child: Icon(readQuranScreenController.isPageSaved.value
                    ? Icons.bookmark
                    : Icons.bookmark_outline),
                onPressed: () {
                  readQuranScreenController.bookmarkPage(
                      SharedPrefService.getInt("last_read_quran")!);
                  readQuranScreenController
                      .isPageSave(SharedPrefService.getInt("last_read_quran")!);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getPageVerses(int pageIndex) {
    List<String> verses = [];

    final pageData = quran.getPageData(pageIndex);
    String pageText = "";

    for (var data in pageData) {
      if (data["start"] == 1) {
        if (data["surah"] != 9 && data["surah"] != 1) {
          verses.add(
              "~~~~~~~{ ${quran.getSurahNameArabic(data["surah"])} }~~~~~~~\n${quran.basmala}\n");
        } else {
          verses.add(
              "~~~~~~~{ ${quran.getSurahNameArabic(data["surah"])} }~~~~~~~\n");
        }
      } else {}
      for (int j = data["start"]; j <= data["end"]; j++) {
        if (j == data["end"]) {
          verses.add(
              "${quran.getVerse(data["surah"], j, verseEndSymbol: true)}\n");
        } else {
          verses.add(quran.getVerse(data["surah"], j, verseEndSymbol: true));
        }
      }
    }
    for (String s in verses) {
      pageText = pageText + s;
    }
    return pageText;
  }
}

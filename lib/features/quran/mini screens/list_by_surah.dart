import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/utils/constants/colors.dart';
import 'package:noor/utils/helpers/helper_functions.dart';
import 'package:quran/quran.dart' as quran;

import 'package:noor/features/quran/mini%20screens/read_quran_screen.dart';

import '../../../utils/local_storage/services/sharedpreferences_service.dart';
import '../widgets/surah_line.dart';

class ListBySurah extends StatelessWidget {
  const ListBySurah({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = SHelperFunctions.isDarkMode(context);
    QuranScreenController quranScreenController = Get.find();
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: ListView.builder(
        itemCount: quran.totalSurahCount,
        itemBuilder: (context, index) {
          int surahIndex = index + 1;
          return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                SharedPrefService.setInt(
                    "last_read_quran", (quran.getSurahPages(surahIndex).first));
                quranScreenController.updateLastSurahRead();
                quranScreenController.updateLastPageRead();
                Get.to(() => ReadQuranScreen(
                    surahIndex: (quran.getSurahPages(surahIndex).first) - 1));
              },
              child: Column(
                children: [
                  SurahLine(
                      arabicName: quran.getSurahNameArabic(surahIndex),
                      number: surahIndex,
                      englishName: quran.getSurahName(surahIndex),
                      verses: quran.getVerseCount(surahIndex),
                      revelationPlace: quran.getPlaceOfRevelation(surahIndex)),
                  const Divider(
                      endIndent: 64, indent: 64, color: SColors.softGrey)
                ],
              ));
        },
      ),
    );
  }
}

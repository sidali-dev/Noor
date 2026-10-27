import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/features/quran/widgets/surah_line.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

class ListBySurah extends StatelessWidget {
  const ListBySurah({super.key});

  @override
  Widget build(BuildContext context) {
    final QuranScreenController controller = Get.find();

    return Obx(() {
      controller.progressRevision.value;
      final surahs = controller.filteredSurahs;

      return ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: NoorSpace.xl,
          vertical: NoorSpace.md,
        ),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surahNumber = surahs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: NoorSpace.md),
            child: SurahLine(
              number: surahNumber,
              onTap: () {
                final firstPage = quran.getSurahPages(surahNumber).first;
                AppPrefs.setLastReadPage(firstPage);
                controller.refreshProgress();
                Get.to(() => ReadQuranScreen(pageIndex: firstPage - 1));
              },
            ),
          );
        },
      );
    });
  }
}

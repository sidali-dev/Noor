import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/local_storage/services/sharedpreferences_service.dart';
import '../mini screens/read_quran_screen.dart';
import '../mini screens/read_quran_screen_controller.dart';

class BookmarkLine extends StatelessWidget {
  final String title;
  final int pageNumber;
  const BookmarkLine(
      {super.key, required this.title, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    final isRtl = SHelperFunctions.isRtl(context);
    ReadQuranScreenController controller = Get.put(ReadQuranScreenController());
    QuranScreenController quranScreenController =
        Get.put(QuranScreenController());
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18.0),
        ),
        const Spacer(),
        GestureDetector(
            onTap: () {
              controller.removeBookMark(pageNumber);
            },
            child: const Icon(Icons.bookmark_remove, color: Colors.red)),
        const SizedBox(width: 16),
        GestureDetector(
            onTap: () {
              SharedPrefService.setInt("last_read_quran", (pageNumber));
              quranScreenController.updateLastSurahRead();
              quranScreenController.updateLastPageRead();
              Get.to(() => ReadQuranScreen(surahIndex: (pageNumber - 1)));
            },
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(isRtl ? -1.0 : 1.0, 1.0),
              child: Icon(Iconsax.play,
                  color: isDark ? SColors.secondary : SColors.primary),
            )),
        const SizedBox(width: 8)
      ],
    );
  }
}

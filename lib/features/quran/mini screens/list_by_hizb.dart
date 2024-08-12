import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/mini%20screens/read_quran_screen.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import '../../../utils/local_storage/services/sharedpreferences_service.dart';
import '../../../generated/l10n.dart';
import '../../../utils/constants/colors.dart';
import '../quran_screen_controller.dart';

class ListByHizb extends StatelessWidget {
  const ListByHizb({super.key});

  @override
  Widget build(BuildContext context) {
    QuranScreenController quranScreenController = Get.find();
    final isDark = SHelperFunctions.isDarkMode(context);
    return GridView.builder(
      itemCount: 60,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              SharedPrefService.setInt("last_read_quran",
                  (SHelperFunctions.getHizbStartingPage(index + 1)));
              quranScreenController.updateLastSurahRead();
              quranScreenController.updateLastPageRead();

              Get.to(() => ReadQuranScreen(
                  surahIndex:
                      SHelperFunctions.getHizbStartingPage(index + 1) - 1));
            },
            child: Card(
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                    color: isDark ? SColors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(SImageString.hizbFrame),
                      ),
                      Center(
                        child: Text(
                          "${S.of(context).hizb} ${index + 1}",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: isDark ? SColors.white : SColors.primary,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

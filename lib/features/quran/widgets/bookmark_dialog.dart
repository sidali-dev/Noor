import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/mini%20screens/read_quran_screen_controller.dart';

import '../../../generated/l10n.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';
import 'bookmark_line.dart';

class BookmarksDialog extends StatelessWidget {
  const BookmarksDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    final isRtl = SHelperFunctions.isRtl(context);

    ReadQuranScreenController controller = Get.put(ReadQuranScreenController());
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          padding: const EdgeInsets.only(
              bottom: 8.0, top: 16.0, right: 16.0, left: 16.0),
          decoration: BoxDecoration(
              color: isDark ? SColors.black : Colors.white,
              borderRadius: BorderRadius.circular(24.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark,
                      color: isDark ? SColors.secondary : SColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).bookmarks,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: isDark ? SColors.secondary : SColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: SDeviceUtils.getScreenHeight(context) * 0.4,
                child: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.savedPagesList.map(
                          (element) {
                            if (element == "") {
                              return const SizedBox();
                            }
                            int i = int.parse(element);
                            return Column(
                              children: [
                                BookmarkLine(
                                    pageNumber: i,
                                    title: controller.getLineTitle(
                                        i, isRtl, context)),
                                const SizedBox(height: 12)
                              ],
                            );
                          },
                        ).toList()),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

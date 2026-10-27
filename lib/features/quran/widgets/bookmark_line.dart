import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class BookmarkLine extends StatelessWidget {
  final String title;
  final int pageNumber;

  const BookmarkLine({
    super.key,
    required this.title,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return NoorListRow(
      title: title,
      trailing: IconButton(
        tooltip: S.of(context).remove,
        icon: Icon(
          Icons.delete_outline_rounded,
          color: n.danger,
          size: 22,
        ),
        onPressed: () async {
          final list = List<int>.from(AppPrefs.bookmarks);
          list.remove(pageNumber);
          await AppPrefs.setBookmarks(list);
          if (Get.isRegistered<QuranScreenController>()) {
            Get.find<QuranScreenController>().refreshProgress();
          }
        },
      ),
      onTap: () {
        AppPrefs.setLastReadPage(pageNumber);
        if (Get.isRegistered<QuranScreenController>()) {
          Get.find<QuranScreenController>().refreshProgress();
        }
        Get.to(() => ReadQuranScreen(pageIndex: pageNumber - 1));
      },
    );
  }
}

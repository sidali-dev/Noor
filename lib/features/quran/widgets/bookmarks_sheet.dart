import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

String getLineTitle(int pageNumber, BuildContext context) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final surahId = quran.getPageData(pageNumber).first["surah"] as int;
  final surahName =
      isAr ? quran.getSurahNameArabic(surahId) : quran.getSurahName(surahId);
  return "$surahName \u00B7 ${S.of(context).page} $pageNumber";
}

Future<void> showBookmarksSheet(BuildContext context) {
  return showNoorSheet(
    context,
    title: S.of(context).bookmarks,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final bookmarks = AppPrefs.bookmarks;
          if (bookmarks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: NoorSpace.lg),
              child: EmptyState(
                message: S.of(context).no_bookmarks,
                icon: Icons.bookmark_border_rounded,
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final page in bookmarks)
                Padding(
                  padding: const EdgeInsets.only(bottom: NoorSpace.sm),
                  child: NoorListRow(
                    title: getLineTitle(page, context),
                    trailing: IconButton(
                      tooltip: S.of(context).remove,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: context.noor.danger,
                        size: 22,
                      ),
                      onPressed: () async {
                        final list = List<int>.from(AppPrefs.bookmarks);
                        list.remove(page);
                        await AppPrefs.setBookmarks(list);
                        setSheetState(() {});
                        if (Get.isRegistered<QuranScreenController>()) {
                          Get.find<QuranScreenController>().refreshProgress();
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      AppPrefs.setLastReadPage(page);
                      if (Get.isRegistered<QuranScreenController>()) {
                        Get.find<QuranScreenController>().refreshProgress();
                      }
                      Get.to(() => ReadQuranScreen(pageIndex: page - 1));
                    },
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

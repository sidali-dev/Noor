import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/routes/app_routes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/quran/controllers/quran_controller.dart';
import 'package:noor/core/widgets/empty_state.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_list_row.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/services/app_prefs.dart';
import 'package:noor/core/theme/app_theme.dart';
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
              padding: const EdgeInsets.symmetric(vertical: NoorSpace.s4),
              child: EmptyState(
                message: S.of(context).no_bookmarks,
                icon: NoorGlyph.bookmark,
              ),
            );
          }
          return NoorListGroup(
            children: [
              for (final page in bookmarks)
                NoorListRow(
                  title: getLineTitle(page, context),
                  trailing: NoorCloudButton(
                    tooltip: S.of(context).remove,
                    icon: Icon(Iconsax.trash, color: context.noor.danger),
                    onTap: () async {
                      final list = List<int>.from(AppPrefs.bookmarks);
                      list.remove(page);
                      await AppPrefs.setBookmarks(list);
                      setSheetState(() {});
                      if (Get.isRegistered<QuranController>()) {
                        Get.find<QuranController>().refreshProgress();
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    AppPrefs.setLastReadPage(page);
                    if (Get.isRegistered<QuranController>()) {
                      Get.find<QuranController>().refreshProgress();
                    }
                    Get.toNamed(Routes.READ_QURAN, arguments: page - 1);
                  },
                ),
            ],
          );
        },
      );
    },
  );
}

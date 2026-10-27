import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/hizb_pages.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class ListByHizb extends StatelessWidget {
  const ListByHizb({super.key});

  @override
  Widget build(BuildContext context) {
    final QuranScreenController controller = Get.find();
    final n = context.noor;

    return Obx(() {
      controller.progressRevision.value;
      final hizbs = controller.filteredHizbs;

      return ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: NoorSpace.xl,
          vertical: NoorSpace.md,
        ),
        itemCount: hizbs.length,
        itemBuilder: (context, index) {
          final hizbNumber = hizbs[index];
          final startPage = hizbStartPage(hizbNumber);

          final leading = Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: n.tintBg(NoorTint.sage),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              hizbNumber.toString(),
              style: NoorText.numeral(
                context,
                size: 16,
                color: n.ink,
              ),
            ),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: NoorSpace.md),
            child: NoorListRow(
              leading: leading,
              title: "${S.of(context).hizb} $hizbNumber",
              meta: "${S.of(context).page} $startPage",
              onTap: () {
                AppPrefs.setLastReadPage(startPage);
                controller.refreshProgress();
                Get.to(() => ReadQuranScreen(pageIndex: startPage - 1));
              },
            ),
          );
        },
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/quran/mini%20screens/read_quran_screen.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/widgets/bookmark_dialog.dart';
import 'package:noor/generals/widgets/check_dialog.dart';
import 'package:noor/utils/constants/colors.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import '../../generated/l10n.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/device/device_utility.dart';
import '../../utils/local_storage/services/sharedpreferences_service.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isRtl = SHelperFunctions.isRtl(context);
    bool isDark = SHelperFunctions.isDarkMode(context);
    QuranScreenController screenController = Get.put(QuranScreenController());

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 145, 61, 255),
        child: Column(
          children: [
            Stack(alignment: Alignment.center, children: [
              Image.asset(SImageString.backgroundImage3),
              Positioned(
                child: Column(
                  children: [
                    SizedBox(
                        height: SDeviceUtils.getScreenHeight(context) * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          SImageString.octagon,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                        const SizedBox(width: SSizes.md),
                        const Text(
                          "وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: SSizes.fontSizeLg,
                              fontFamily: "Amiri"),
                        ),
                        const SizedBox(width: SSizes.md),
                        SvgPicture.asset(
                          SImageString.octagon,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ],
                    ),
                    Divider(
                        color: Colors.white.withOpacity(0.7),
                        thickness: 1,
                        indent: 80,
                        endIndent: 80,
                        height: 20),
                    Text(
                      S.of(context).last_read,
                      style: const TextStyle(
                          color: SColors.white, fontWeight: FontWeight.w300),
                    ),
                    Obx(
                      () => Text(
                        "${screenController.lastReadSurah.value} \u25CF ${S.of(context).page} ${screenController.lastReadPageNumber.value}",
                        style: const TextStyle(
                            color: SColors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: SSizes.fontSizeSm),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  SharedPrefService.getString("quran_bookmark")!
                                          .contains("-")
                                      ? const BookmarksDialog()
                                      : CheckDialog(
                                          title: S.of(context).no_bookmarks,
                                          imagePath: SImageString.lottieQuran,
                                          color: Colors.green),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.bookmark,
                                  color: SColors.secondary),
                              const SizedBox(width: 8),
                              Text(S.of(context).bookmarks,
                                  style: const TextStyle(
                                      color: SColors.secondary,
                                      fontSize: SSizes.fontSizeSm))
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('|', style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => ReadQuranScreen(
                                surahIndex:
                                    screenController.lastReadPageNumber.value -
                                        1));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(isRtl ? -1.0 : 1.0, 1.0),
                                  child: const Icon(Iconsax.play,
                                      color: SColors.secondary)),
                              const SizedBox(width: 8),
                              Text(S.of(context).continue_reading,
                                  style: const TextStyle(
                                      color: SColors.secondary,
                                      fontSize: SSizes.fontSizeSm)),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),

            //------------------------------Bottom Part------------------------------\\

            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: Container(
                color: isDark ? Colors.black : Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: SSizes.dividerHeightMd),
                    Obx(
                      () => Row(
                        children: [
                          SizedBox(
                            width: SDeviceUtils.getScreenWidth(context) * 0.5,
                            child: GestureDetector(
                              onTap: () {
                                screenController.changeIndex(1);
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: NameLater(
                                    title: S.of(context).hizb,
                                    isSelected:
                                        screenController.currentIndex.value ==
                                            1),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: SDeviceUtils.getScreenWidth(context) * 0.5,
                            child: GestureDetector(
                              onTap: () {
                                screenController.changeIndex(0);
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: NameLater(
                                    title: S.of(context).surah,
                                    isSelected:
                                        screenController.currentIndex.value ==
                                            0),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Expanded(
                  child: screenController
                      .screens[screenController.currentIndex.value]),
            )
          ],
        ),
      ),
    );
  }
}

class NameLater extends StatelessWidget {
  final String title;
  final bool isSelected;
  const NameLater({
    super.key,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18.0,
              color: isSelected
                  ? SColors.secondary
                  : isDark
                      ? SColors.white
                      : SColors.primary,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Divider(
            color: isSelected ? SColors.secondary : Colors.grey.shade300,
            thickness: 1.0,
            height: 1.0)
      ],
    );
  }
}

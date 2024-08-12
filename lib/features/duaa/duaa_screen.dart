import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:noor/features/duaa/adhkar_display_screen.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/utils/device/device_utility.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import 'package:noor/utils/local_storage/services/database_service.dart';

import '../../generated/l10n.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';

class DuaaScreen extends StatelessWidget {
  DuaaScreen({super.key});

  final Map<String, int> adhkartypeMap = {
    "اذكار الصباح": 1,
    "اذكار المساء": 2,
    "أذكار الصلاة": 3,
    "أذكار المسجد": 4,
    "أذكار الاستيقاظ": 5,
    "أذكار النوم": 6,
    "أذكار بعد الصلاة": 7,
    "تسابيح": 8,
    "أدعية النبي": 9,
    "أدعية قرئانية": 10,
    "أدعية الأنبياء": 11,
    "أذكار متفرقة": 12,
    "أذكار سماع الآذان": 13,
    "جوامع الدعاء": 14,
    "أذكار الوضوء": 15,
    "أذكار دخول وخروج المنزل": 16,
    "أذكار دخول وخروج الخلاء": 17,
    "أذكار الطعام والشراب والضيف": 18,
    "أذكار الحج والعمرة": 19
  };

  @override
  Widget build(BuildContext context) {
    final double screenWidth = SDeviceUtils.getScreenWidth(context);
    final bool isDark = SHelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(alignment: Alignment.center, children: [
              Image.asset(SImageString.backgroundImage4),
              Positioned(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      SImageString.octagon,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(width: SSizes.md),
                    const Text(
                      "وَاذْكُر رَّبَّكَ كَثِيرًا",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: SSizes.fontSizeLg,
                          fontFamily: "Amiri"),
                    ),
                    const SizedBox(width: SSizes.md),
                    SvgPicture.asset(
                      SImageString.octagon,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(SImageString.prayingHands,
                    height: 56,
                    colorFilter: ColorFilter.mode(
                        isDark ? SColors.white : Colors.blue, BlendMode.srcIn)),
                const SizedBox(width: 8),
                Text(
                  S.of(context).adhkar,
                  style: TextStyle(
                      color: isDark ? SColors.white : Colors.blue,
                      fontSize: 32,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['اذكار الصباح']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).morning_adhkar));
                    },
                    title1: S.of(context).morning_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.sunrise, height: 32)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['اذكار المساء']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).evening_adhkar));
                    },
                    title1: S.of(context).evening_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.sunset, height: 32))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار الصلاة']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).prayer_adhkar));
                    },
                    title1: S.of(context).prayer_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon:
                        SvgPicture.asset(SImageString.prayingMan, height: 32)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار المسجد']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).mosque_adhkar));
                    },
                    title1: S.of(context).mosque_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.masjid, height: 32))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار الاستيقاظ']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).wake_up_adhkar));
                    },
                    title1: S.of(context).wake_up_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.alarm, height: 28)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار النوم']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).sleep_adhkar));
                    },
                    title1: S.of(context).sleep_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.night, height: 28))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار بعد الصلاة']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar,
                          title: S.of(context).after_prayer_adhkar));
                    },
                    title1: S.of(context).after_prayer_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon:
                        SvgPicture.asset(SImageString.prayingMan, height: 28)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['تسابيح']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).tasbeeh));
                    },
                    title1: S.of(context).tasbeeh,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.tasbih, height: 28))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أدعية النبي']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).prophet_dua));
                    },
                    title1: S.of(context).prophet_dua,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon:
                        SvgPicture.asset(SImageString.prophetName, height: 28)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أدعية قرئانية']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).quran_dua));
                    },
                    title1: S.of(context).quran_dua,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.quran, height: 28))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أدعية الأنبياء']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).prophets_dua));
                    },
                    title1: S.of(context).prophets_dua,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.group, height: 28)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار متفرقة']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).general_Adhkar));
                    },
                    title1: S.of(context).general_Adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.group, height: 28))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار سماع الآذان']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).adhan_adhkar));
                    },
                    title1: S.of(context).adhan_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.adhan, height: 28)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['جوامع الدعاء']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar,
                          title: S.of(context).comprehensive_duaa));
                    },
                    title1: S.of(context).comprehensive_duaa,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.list, height: 28))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار الوضوء']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).wudu_adhkar));
                    },
                    title1: S.of(context).wudu_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.wudu, height: 28)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار دخول وخروج المنزل']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).home_adhkar));
                    },
                    title1: S.of(context).home_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.home, height: 28))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار دخول وخروج الخلاء']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).wc_adhkar));
                    },
                    title1: S.of(context).wc_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.wc, height: 28)),
                AdhkarBox(
                    callback: () async {
                      List<AdhkarModel> adhkar =
                          await DatabaseService.getAdhkar(
                              adhkartypeMap['أذكار الطعام والشراب والضيف']!);
                      Get.to(() => AdhkarDisplayScreen(
                          adhkar: adhkar, title: S.of(context).meal_adhkar));
                    },
                    title1: S.of(context).meal_adhkar,
                    width: screenWidth * 0.4,
                    isDark: isDark,
                    icon: SvgPicture.asset(SImageString.meal, height: 28))
              ],
            ),
            const SizedBox(height: 24),
            AdhkarBox(
                callback: () async {
                  List<AdhkarModel> adhkar = await DatabaseService.getAdhkar(
                      adhkartypeMap['أذكار الحج والعمرة']!);
                  Get.to(() => AdhkarDisplayScreen(
                      adhkar: adhkar, title: S.of(context).hajj_adhkar));
                },
                title1: S.of(context).hajj_adhkar,
                width: screenWidth * 0.4,
                isDark: isDark,
                icon: SvgPicture.asset(SImageString.kaaba, height: 28)),
          ],
        ),
      ),
    );
  }
}

class AdhkarBox extends StatelessWidget {
  final String title1;
  final Widget icon;
  final Future<void> Function() callback;
  final double width;
  final bool isDark;

  const AdhkarBox({
    super.key,
    required this.title1,
    required this.icon,
    required this.callback,
    required this.width,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await callback();
      },
      child: Card(
        elevation: 6,
        color: isDark ? SColors.dark : Colors.white,
        child: SizedBox(
          height: 80,
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                SizedBox(
                  width: width * 0.7,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        title1,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

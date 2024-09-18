import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';

import 'package:noor/features/adhan/adhan_screen.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/duaa/duaa_screen.dart';
import 'package:noor/features/qibla/qibla_screen.dart';
import 'package:noor/features/quran/quran_screen.dart';
import 'package:noor/utils/constants/colors.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import 'features/adhan/adhan_ring_screen.dart';
import 'generals/controllers/location_controller.dart';
import 'generals/widgets/settings_dialog.dart';

class SBottomNavigation extends StatelessWidget {
  final int? pageIndex;
  const SBottomNavigation({
    super.key,
    this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SBottomNavigationController());

    Get.lazyPut(() => SoundPickerController());

    Get.lazyPut(() => AdhanController());

    Get.lazyPut(() => LocationController());

    final isDark = SHelperFunctions.isDarkMode(context);

    return Scaffold(
        bottomNavigationBar: Obx(
          () => NavigationBar(
              backgroundColor: isDark ? Colors.black : SColors.white,
              indicatorColor: Colors.transparent,
              height: 60.0,
              elevation: 0,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (value) =>
                  controller.selectedIndex.value = value,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(
                    selectedIcon: SvgPicture.asset(
                      SImageString.quran,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                          isDark ? SColors.secondary : SColors.primary,
                          BlendMode.srcIn),
                    ),
                    icon: SvgPicture.asset(SImageString.quran,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn)),
                    label: 'Liked'),
                NavigationDestination(
                    selectedIcon: SvgPicture.asset(
                      SImageString.adhan,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                          isDark ? SColors.secondary : SColors.primary,
                          BlendMode.srcIn),
                    ),
                    icon: SvgPicture.asset(SImageString.adhan,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn)),
                    label: 'Adhan'),
                NavigationDestination(
                    selectedIcon: SvgPicture.asset(
                      SImageString.prayingHands,
                      height: 36,
                      colorFilter: ColorFilter.mode(
                          isDark ? SColors.secondary : SColors.primary,
                          BlendMode.srcIn),
                    ),
                    icon: SvgPicture.asset(SImageString.prayingHands,
                        height: 36,
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn)),
                    label: 'History'),
                NavigationDestination(
                    selectedIcon: SvgPicture.asset(
                      SImageString.kaaba,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                          isDark ? SColors.secondary : SColors.primary,
                          BlendMode.srcIn),
                    ),
                    icon: SvgPicture.asset(SImageString.kaaba,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn)),
                    label: 'Favorites'),
              ]),
        ),
        body: Obx(() => controller.screens[controller.selectedIndex.value]),
        floatingActionButton: FloatingActionButton.small(
          shape: const CircleBorder(),
          onPressed: () {
            showDialog(
                context: context, builder: (context) => const DialogSettings());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Iconsax.setting_4, color: Colors.white),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartTop);
  }
}

class SBottomNavigationController extends GetxController {
  static StreamSubscription<AlarmSettings>? _subscription;

  Rx<int> selectedIndex = 0.obs;

  @override
  onInit() {
    super.onInit();
    if (Alarm.android) {
      SHelperFunctions.checkAndroidNotificationPermission();
      SHelperFunctions.checkAndroidScheduleExactAlarmPermission();
    }

    _subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Get.to(() => AdhanRingScreen(alarmSettings: alarmSettings));
  }

  @override
  onClose() {
    _subscription?.cancel();
  }

  changeIndex(int index) {
    selectedIndex = index.obs;
  }

  final screens = [
    const QuranScreen(),
    const AdhanScreen(),
    DuaaScreen(),
    QiblaScreen(),
  ];
}

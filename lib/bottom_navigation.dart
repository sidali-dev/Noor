import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/adhan_ring_screen.dart';
import 'package:noor/features/adhan/adhan_screen.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/duaa/duaa_screen.dart';
import 'package:noor/features/qibla/qibla_screen.dart';
import 'package:noor/features/quran/quran_screen.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/generals/widgets/noor_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class SBottomNavigation extends StatelessWidget {
  final int? pageIndex;
  const SBottomNavigation({super.key, this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SBottomNavigationController());
    if (pageIndex != null) {
      controller.selectedIndex.value = pageIndex!;
    }

    Get.lazyPut(() => SoundPickerController());
    Get.lazyPut(() => AdhanController());
    Get.lazyPut(() => LocationController());

    return Scaffold(
      extendBody: true,
      body: Obx(() {
        switch (controller.selectedIndex.value) {
          case 0:
            return const QuranScreen();
          case 1:
            return const AdhanScreen();
          case 2:
            return const DuaaScreen();
          case 3:
            return const QiblaScreen();
          default:
            return const QuranScreen();
        }
      }),
      bottomNavigationBar: Obx(
        () => NoorNavBar(
          selectedIndex: controller.selectedIndex.value,
          onItemSelected: controller.changeIndex,
        ),
      ),
    );
  }
}

class SBottomNavigationController extends GetxController {
  static StreamSubscription<AlarmSettings>? _subscription;

  final Rx<int> selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Alarm.android) {
      Permission.notification.request();
      Permission.scheduleExactAlarm.request();
    }
    _subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Get.to(() => AdhanRingScreen(alarmSettings: alarmSettings));
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

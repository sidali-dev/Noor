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
      // Tabs are built on first visit and then kept, so switching is a repaint
      // (the nav circle animates smoothly) and tabs keep their state. Qibla
      // is mounted only while shown, so the compass sensor is not left running.
      body: Obx(() {
        final i = controller.selectedIndex.value;
        controller.visited.add(i);
        const tabs = [
          QuranScreen(),
          AdhanScreen(),
          DuaaScreen(),
          QiblaScreen(),
        ];
        return IndexedStack(
          index: i,
          sizing: StackFit.expand,
          children: [
            for (var k = 0; k < tabs.length; k++)
              controller.visited.contains(k) && (k != 3 || k == i)
                  ? tabs[k]
                  : const SizedBox.shrink(),
          ],
        );
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
  final Set<int> visited = {};

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
    // An offstage tab would otherwise keep the keyboard open.
    FocusManager.instance.primaryFocus?.unfocus();
    selectedIndex.value = index;
  }
}

import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/adhan_ring_screen.dart';
import 'package:noor/features/adhan/adhan_screen.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/duaa/duaa_screen.dart';
import 'package:noor/features/qibla/qibla_screen.dart';
import 'package:noor/features/quran/quran_screen.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/generals/location_drift.dart';
import 'package:noor/generals/widgets/noor_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class SBottomNavigation extends StatelessWidget {
  final int? pageIndex;
  const SBottomNavigation({super.key, this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SBottomNavigationController());
    // Not in build: the Obx below may already be mounted (Get.offAll from the
    // ring screen reuses this controller) and cannot be dirtied mid-build.
    if (pageIndex != null && !controller.initialIndexApplied) {
      controller.initialIndexApplied = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => controller.changeIndex(pageIndex!));
    }

    Get.lazyPut(() => SoundPickerController());
    Get.lazyPut(() => AdhanController());
    Get.lazyPut(() => LocationController());
    // Once per launch; returns at once on later builds.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkLocationDrift(context));

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
                  // IndexedStack keeps hidden tabs alive but still ticking;
                  // only the shown tab may run animations.
                  ? TickerMode(enabled: k == i, child: tabs[k])
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
  StreamSubscription<dynamic>? _subscription;
  final Set<int> _shown = {};

  final Rx<int> selectedIndex = 0.obs;
  final Set<int> visited = {};
  bool initialIndexApplied = false;

  @override
  void onInit() {
    super.onInit();
    if (Alarm.android) _askPermissions();
    // Alarm.ringing replays the current set, so an alarm that began ringing
    // before this controller existed (a cold start from the lock screen) still
    // opens its screen. The old ringStream is a plain broadcast and lost it.
    _subscription = Alarm.ringing.listen((ringing) {
      _shown.retainAll({for (final a in ringing.alarms) a.id});
      for (final alarm in ringing.alarms) {
        if (_shown.add(alarm.id)) navigateToRingScreen(alarm);
      }
    });
  }

  /// One request at a time: permission_handler rejects overlapping ones. The
  /// first launch could not schedule anything before the grant, so sync after.
  Future<void> _askPermissions() async {
    final granted = (await Permission.notification.request()).isGranted;
    if (!await Permission.scheduleExactAlarm.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
    if (granted) await AdhanScheduler.sync();
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

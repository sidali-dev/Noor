import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:noor/core/routes/app_routes.dart';
import 'package:noor/core/services/adhan_channels.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

class MainController extends GetxController {
  StreamSubscription<dynamic>? _subscription;
  final Set<int> _shown = {};

  final Rx<int> selectedIndex = 0.obs;
  final Set<int> visited = {};

  /// Tabs mounted ahead of a visit; see [onReady]. An Rx set, so the body
  /// rebuilds when one is added (adding to [visited] there would be mid-build).
  final RxSet<int> warmed = <int>{}.obs;

  /// The tab being painted under the shown one, for one frame.
  final warming = RxnInt();
  static const _warmOrder = [1, 2];
  static const _warmGap = Duration(milliseconds: 300);
  Timer? _warmTimer;
  bool initialIndexApplied = false;

  @override
  void onInit() {
    super.onInit();
    if (Alarm.android) _askPermissions();
    // The adhan screen's Open Athkar: at launch, or into the running app.
    AppChannel.launchTab().then((tab) {
      if (tab != null) changeIndex(tab);
    });
    AppChannel.onOpenTab((tab) {
      Get.until((route) => route.isFirst);
      changeIndex(tab);
    });
    // Android shows a ringing adhan in its own activity, in every app state.
    // On iOS it is a route here. Alarm.ringing replays the current set, so an
    // alarm that began ringing before this controller existed (a cold start
    // from its notification) still opens its screen.
    if (Alarm.iOS) {
      _subscription = Alarm.ringing.listen((ringing) {
        _shown.retainAll({for (final a in ringing.alarms) a.id});
        for (final alarm in ringing.alarms) {
          if (_shown.add(alarm.id)) navigateToRingScreen(alarm);
        }
      });
    }
  }

  /// After the first frame, builds and paints the tabs the user will most likely
  /// open next, one at a time and never while something animates. The paint is what bakes a tab's blurred wells
  /// ([BakedPaint]) and readies the GPU for its art and text; a first visit
  /// would otherwise do both inside the switch.
  @override
  void onReady() {
    super.onReady();
    _warmTimer = Timer(_warmGap, _warmNext);
  }

  void _warmNext() {
    final next = _warmOrder
        .where((k) => !visited.contains(k) && !warmed.contains(k))
        .firstOrNull;
    if (next == null) return;
    // Not scheduleTask(Priority.idle): while an animation holds such a task
    // back, the scheduler re-queues itself without pause and spins the UI thread.
    if (SchedulerBinding.instance.transientCallbackCount > 0) {
      _warmTimer = Timer(_warmGap, _warmNext);
      return;
    }
    warming.value = next;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      warmed.add(next);
      warming.value = null;
      _warmTimer = Timer(_warmGap, _warmNext);
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
    await Get.toNamed(Routes.ADHAN_RING, arguments: alarmSettings);
  }

  @override
  void onClose() {
    _warmTimer?.cancel();
    _subscription?.cancel();
    super.onClose();
  }

  void changeIndex(int index) {
    // An offstage tab would otherwise keep the keyboard open.
    FocusManager.instance.primaryFocus?.unfocus();
    selectedIndex.value = index;
  }
}

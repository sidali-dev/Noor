import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:noor/utils/theme/noor_motion.dart';
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
      body: _Tabs(controller: controller),
      bottomNavigationBar: Obx(
        () => NoorNavBar(
          selectedIndex: controller.selectedIndex.value,
          onItemSelected: controller.changeIndex,
        ),
      ),
    );
  }
}

/// The tabs: the shown one slides in and the one it replaces out, in step with
/// [NoorNavBar]'s selector.
// shortcut: slides the same way in RTL, pass SlideTransition's textDirection
// before shipping.
class _Tabs extends StatefulWidget {
  final SBottomNavigationController controller;
  const _Tabs({required this.controller});

  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> with SingleTickerProviderStateMixin {
  late final _slide = AnimationController(vsync: this, value: 1);
  late final _curved =
      CurvedAnimation(parent: _slide, curve: Curves.easeOutCubic);
  late final Worker _onIndex;
  late int _shown;
  int? _leaving;

  @override
  void initState() {
    super.initState();
    _shown = widget.controller.selectedIndex.value;
    _slide.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _leaving = null);
      }
    });
    _onIndex = ever(widget.controller.selectedIndex, (int i) {
      _leaving = _shown;
      _shown = i;
      _slide.forward(from: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _slide.duration = noorDuration(context, NoorNavBar.select);
  }

  @override
  void dispose() {
    _onIndex.dispose();
    _curved.dispose();
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tabs are kept once built, so switching is a repaint (the nav circle
    // animates smoothly) and tabs keep their state. Prayers and Athkar are
    // built and painted once early, unseen, in idle time
    // ([SBottomNavigationController.onReady]): a first build and paint cost
    // over 100 ms, which a first visit would otherwise spend inside the
    // switch. Qibla is mounted only while shown, so the compass sensor is not
    // left running.
    return Obx(() {
      final i = widget.controller.selectedIndex.value;
      widget.controller.visited.add(i);
      final controller = widget.controller;
      final warmed = controller.warmed;
      final warming = controller.warming.value;
      final leaving = _leaving;
      final dir = leaving == null ? 0.0 : (i - leaving).sign.toDouble();
      const tabs = [
        QuranScreen(),
        AdhanScreen(),
        DuaaScreen(),
        QiblaScreen(),
      ];
      return Stack(
        fit: StackFit.expand,
        children: [
          // A tab warming up goes first: under the shown tab, which hides it.
          for (final k in [
            if (warming != null) warming,
            for (var k = 0; k < tabs.length; k++)
              if (k != warming) k,
          ])
            KeyedSubtree(
              key: ValueKey(k),
              child: Offstage(
                offstage: k != i && k != warming && k != leaving,
                child: SlideTransition(
                  position: (k == i
                          ? Tween(begin: Offset(dir, 0), end: Offset.zero)
                          : k == leaving
                              ? Tween(begin: Offset.zero, end: Offset(-dir, 0))
                              : Tween(begin: Offset.zero, end: Offset.zero))
                      .animate(_curved),
                  child: ExcludeFocus(
                    excluding: k != i,
                    child: ExcludeSemantics(
                      excluding: k != i,
                      child: IgnorePointer(
                        ignoring: k != i,
                        child: (controller.visited.contains(k) ||
                                    warmed.contains(k) ||
                                    k == warming) &&
                                (k != 3 || k == i || k == leaving)
                            // Kept-alive tabs would otherwise keep ticking;
                            // only the shown tab may run animations.
                            ? TickerMode(enabled: k == i, child: tabs[k])
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class SBottomNavigationController extends GetxController {
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

  /// After the first frame, builds and paints the tabs the user will most likely
  /// open next, one at a time and never while something animates. The paint is what bakes a tab's blurred clouds and wells
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
    await Get.to(() => AdhanRingScreen(alarmSettings: alarmSettings));
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

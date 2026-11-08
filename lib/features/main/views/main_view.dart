
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/main/controllers/main_controller.dart';
import 'package:noor/features/adhan/views/adhan_view.dart';
import 'package:noor/features/duaa/views/duaa_view.dart';
import 'package:noor/features/qibla/views/qibla_view.dart';
import 'package:noor/features/quran/views/quran_view.dart';
import 'package:noor/core/services/location_drift.dart';
import 'package:noor/core/widgets/noor_nav_bar.dart';
import 'package:noor/core/theme/noor_motion.dart';

class MainView extends StatelessWidget {
  final int? pageIndex;
  const MainView({super.key, this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();
    // Not in build: the Obx below may already be mounted (Get.offAll from the
    // ring screen reuses this controller) and cannot be dirtied mid-build.
    if (pageIndex != null && !controller.initialIndexApplied) {
      controller.initialIndexApplied = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => controller.changeIndex(pageIndex!));
    }

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
class _Tabs extends StatefulWidget {
  final MainController controller;
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
    // ([MainController.onReady]): a first build and paint cost
    // over 100 ms, which a first visit would otherwise spend inside the
    // switch. Qibla is mounted only while shown, so the compass sensor is not
    // left running.
    final direction = Directionality.of(context);
    return Obx(() {
      final i = widget.controller.selectedIndex.value;
      widget.controller.visited.add(i);
      final controller = widget.controller;
      final warmed = controller.warmed;
      final warming = controller.warming.value;
      final leaving = _leaving;
      final dir = leaving == null ? 0.0 : (i - leaving).sign.toDouble();
      const tabs = [
        QuranView(),
        AdhanView(),
        DuaaView(),
        QiblaView(),
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
                  textDirection: direction,
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

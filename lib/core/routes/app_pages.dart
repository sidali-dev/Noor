// ignore_for_file: constant_identifier_names
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/routes/app_routes.dart';
import 'package:noor/features/adhan/controllers/adhan_controller.dart';
import 'package:noor/features/adhan/controllers/sound_picker_controller.dart';
import 'package:noor/features/adhan/views/prayer_settings_view.dart';
import 'package:noor/features/adhan/views/widgets/in_app_adhan_ring.dart';
import 'package:noor/features/duaa/models/adhkar_model.dart';
import 'package:noor/features/duaa/views/adhkar_display_view.dart';
import 'package:noor/features/duaa/views/asma_al_husna_view.dart';
import 'package:noor/features/main/controllers/main_controller.dart';
import 'package:noor/features/main/views/main_view.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/features/quran/controllers/quran_controller.dart';
import 'package:noor/features/quran/views/read_quran_view.dart';
import 'package:noor/features/splash/views/splash_view.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  /// App startup, set by main() before runApp. The splash runs it after its
  /// entrance and holds until it ends.
  static Future<void> Function() startup = () async {};

  /// The shell and its four tabs. QiblaView owns its controller: it starts and
  /// stops the compass with the tab. fenix: a tab warmed while another route
  /// is on top ties its controller to that route, and its pop deletes it.
  static final mainBinding = BindingsBuilder(() {
    Get.put(MainController());
    Get.lazyPut(() => SoundPickerController(), fenix: true);
    Get.lazyPut(() => AdhanController(), fenix: true);
    Get.lazyPut(() => QuranController(), fenix: true);
    Get.put(QuranAudioController(), permanent: true);
  });

  static final routes = <GetPage>[
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashView(startup: startup),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainView(),
      binding: mainBinding,
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: _ReduceMotionFade(),
    ),
    GetPage(
      name: Routes.PRAYER_SETTINGS,
      page: () => const PrayerSettingsView(),
    ),
    GetPage(
      name: Routes.ADHKAR_DISPLAY,
      // arguments: (title: String, adhkar: List<AdhkarModel>, initialIndex: int)
      page: () {
        final a = Get.arguments as ({
          String title,
          List<AdhkarModel> adhkar,
          int initialIndex,
        });
        return AdhkarDisplayView(
          title: a.title,
          adhkar: a.adhkar,
          initialIndex: a.initialIndex,
        );
      },
    ),
    GetPage(
      name: Routes.ASMA_AL_HUSNA,
      page: () => const AsmaAlHusnaView(),
    ),
    GetPage(
      name: Routes.READ_QURAN,
      // arguments: either an `int` (0-based pageIndex) or
      // `({int pageIndex, int? surah, int? ayah})`
      page: () {
        final args = Get.arguments;
        if (args is ({int pageIndex, int? surah, int? ayah})) {
          return ReadQuranView(
            pageIndex: args.pageIndex,
            initialSurah: args.surah,
            initialAyah: args.ayah,
          );
        }
        return ReadQuranView(pageIndex: args as int?);
      },
    ),
    GetPage(
      name: Routes.ADHAN_RING,
      // arguments: the ringing AlarmSettings
      page: () => InAppAdhanRing(
        alarm: Get.arguments as AlarmSettings,
        onOpenAthkar: () => Get.find<MainController>().changeIndex(2),
      ),
    ),
  ];
}

/// Splash → shell fade; none under Reduce Motion.
class _ReduceMotionFade extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    );
  }
}

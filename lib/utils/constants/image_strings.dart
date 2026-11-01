import 'package:flutter/widgets.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class SImageString {
  SImageString._();

  static const String sunrise = "assets/images/svg/sunrise.svg";
  static const String sunset = "assets/images/svg/sunset.svg";
  static const String prayingMan = "assets/images/svg/praying_man.svg";
  static const String masjid = "assets/images/svg/masjid.svg";
  static const String alarm = "assets/images/svg/alarm.svg";
  static const String night = "assets/images/svg/night.svg";
  static const String prayingHands = "assets/images/svg/praying_hands.svg";
  static const String adhan = "assets/images/svg/adhan.svg";
  static const String group = "assets/images/svg/group.svg";
  static const String home = "assets/images/svg/home.svg";
  static const String kaaba = "assets/images/svg/kaaba.svg";
  static const String list = "assets/images/svg/list.svg";
  static const String meal = "assets/images/svg/meal.svg";
  static const String prophetName = "assets/images/svg/prophet_name.svg";
  static const String quran = "assets/images/svg/quran.svg";
  static const String tasbih = "assets/images/svg/tasbih.svg";
  static const String wc = "assets/images/svg/wc.svg";
  static const String wudu = "assets/images/svg/wudu.svg";
}

/// Illustrated art. Load only through [of]; never by raw path.
abstract final class NoorArt {
  static const String heroPrayers = 'assets/images/art/hero_prayers';
  static const String heroQuran = 'assets/images/art/hero_quran';
  static const String heroAthkar = 'assets/images/art/hero_athkar';
  static const String qiblaSkyline = 'assets/images/art/qibla_skyline';

  /// The Faith mark alone, rendered from the Hilal SVGs. Use [NoorMark].
  static const String markPaper = 'assets/logo/faith-mark-paper.png';
  static const String markNight = 'assets/logo/faith-mark-night.png';
  static const String surahCartouche =
      'assets/images/ornaments/surah_cartouche.svg';
  static const String pageCorner = 'assets/images/ornaments/page_corner.svg';
  static const String divider = 'assets/images/ornaments/divider.svg';

  /// Pieces that contain writing or must keep their orientation: never
  /// mirrored in RTL (U2). No hero has writing; the skyline is never mirrored.
  static const Set<String> noMirror = {qiblaSkyline};

  /// Bases precached by the custom splash.
  static const List<String> heroes = [
    heroPrayers,
    heroQuran,
    heroAthkar,
    qiblaSkyline,
  ];

  // ponytail: always light until the _dark.webp files exist; then return
  // c.noor.isDark ? '${base}_dark.webp' : '${base}_light.webp'.
  static String of(BuildContext c, String base) => '${base}_light.webp';

  /// The Hilal vector art: sky, moon, stars and the cloud-scroll base, drawn
  /// in the active theme's window and paper colours. Used by [NoorHero].
  static String svgOf(BuildContext c, String base) =>
      '${base}_${c.noor.isDark ? 'night' : 'paper'}.svg';
}

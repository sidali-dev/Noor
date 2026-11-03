import 'package:flutter/widgets.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class SImageString {
  SImageString._();

  static const String kaaba = "assets/images/svg/kaaba.svg";
  // The nav icons: the Kaaba's two navy faces and cream band, in other shapes.
  static const String navQuran = "assets/images/svg/nav_quran.svg";
  static const String navMosque = "assets/images/svg/nav_mosque.svg";
  static const String navTasbih = "assets/images/svg/nav_tasbih.svg";
}

/// Illustrated art. Load the hero art only through [svgOf]; never by raw path.
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

  /// The Kaaba of the Qibla header, drawn over the skyline art. It carries
  /// writing, so it is never mirrored in RTL (U2): [NoorHero] places it at the
  /// end of the band instead.
  static const String qiblaKaaba = 'assets/images/art/qibla_kaaba.svg';

  /// Raster objects laid over the Prayers and Quran heroes by [NoorHero].
  static const String objectMosque = 'assets/images/art/object_mosque.svg';
  static const String objectQuran = 'assets/images/art/object_quran.svg';

  /// Bases precached by the custom splash.
  static const List<String> heroes = [
    heroPrayers,
    heroQuran,
    heroAthkar,
    qiblaSkyline,
  ];

  /// The Hilal vector art: sky, moon, stars and the cloud-scroll base, drawn
  /// in the active theme's window and paper colours. Used by [NoorHero].
  static String svgOf(BuildContext c, String base) =>
      '${base}_${c.noor.isDark ? 'night' : 'paper'}.svg';
}

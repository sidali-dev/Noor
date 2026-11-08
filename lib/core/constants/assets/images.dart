class AppImages {
  AppImages._();

  static const String kaaba = "assets/images/svg/kaaba.svg";
  // The nav icons: the Kaaba's two navy faces and cream band, in other shapes.
  static const String navQuran = "assets/images/svg/nav_quran.svg";
  static const String navMosque = "assets/images/svg/nav_mosque.svg";
  static const String navTasbih = "assets/images/svg/nav_tasbih.svg";
}

/// Illustrated art.
abstract final class NoorArt {
  /// The Faith mark alone, rendered from the Hilal SVGs. Use [NoorMark].
  static const String markPaper = 'assets/logo/faith-mark-paper.png';
  static const String markNight = 'assets/logo/faith-mark-night.png';
  static const String surahCartouche =
      'assets/images/ornaments/surah_cartouche.svg';
  static const String pageCorner = 'assets/images/ornaments/page_corner.svg';
  static const String divider = 'assets/images/ornaments/divider.svg';
  static const String separator = 'assets/images/ornaments/separator.svg';

  /// The tabs' windows for [NoorHero]: pass one to [frame] for the baked image.
  /// Baked by tool/hero_art.py, in the app's exact paper colours.
  static const String heroPrayers = 'prayers';
  static const String heroQuran = 'quran';
  static const String heroAthkar = 'athkar';
  static const String heroQibla = 'qibla';
  static const List<String> heroes = [
    heroPrayers,
    heroQuran,
    heroAthkar,
    heroQibla,
  ];

  static String frame(String hero, String variant) =>
      'assets/images/art/hero_${hero}_$variant.webp';
  /// The ringing adhan's arch, baked by tool/adhan_art.py.
  static String adhanFrame(String variant) =>
      'assets/images/art/adhan_frame_$variant.webp';
  static String clouds(String variant) =>
      'assets/images/art/hero_clouds_$variant.webp';
  static String band(String variant) =>
      'assets/images/art/motif_band_$variant.webp';
  static String ornament(String variant) =>
      'assets/images/art/motif_ornament_$variant.webp';
  static String disc(String variant) =>
      'assets/images/art/motif_disc_$variant.webp';
}

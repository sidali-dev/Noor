class SImageString {
  SImageString._();

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

  /// The Kaaba of the Qibla header, drawn over the sky. It carries
  /// writing, so it is never mirrored in RTL (U2): [NoorHero] places it at the
  /// end of the band instead.
  static const String qiblaKaaba = 'assets/images/art/qibla_kaaba.svg';

  /// The objects laid over the sky by [NoorHero], one per tab.
  static const String objectMosque = 'assets/images/art/object_mosque.svg';
  static const String objectQuran = 'assets/images/art/object_quran.svg';
  static const String objectSabha = 'assets/images/art/object_sabha.svg';
}

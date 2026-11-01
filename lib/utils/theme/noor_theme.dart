import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hilal design tokens and themes: Paper (light) and Night (dark).
/// Every value comes from `hilal-design-system/tokens.json`; see `design.md`.
///
/// Usage: `final n = context.noor;` then `n.paper`, `n.ink`, ...

/// Semantic colour tokens, registered on [ThemeData.extensions].
///
/// Naming: `paper` is the page ground (`surface`), `card` is the lifted
/// paper layer (`surface-raised`), `muted` is `ink-muted`.
@immutable
class NoorColors extends ThemeExtension<NoorColors> {
  const NoorColors({
    required this.isDark,
    required this.paper,
    required this.card,
    required this.surfaceSunken,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.muted,
    required this.window,
    required this.windowRaised,
    required this.onWindow,
    required this.onWindowMuted,
    required this.brass,
    required this.brassSoft,
    required this.onBrass,
    required this.paperShade,
    required this.skyGlow,
    required this.depthShadow,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
  });

  final bool isDark;
  final Color paper;
  final Color card;
  final Color surfaceSunken;
  final Color line;
  final Color lineStrong;
  final Color ink;
  final Color muted;
  final Color window;
  final Color windowRaised;
  final Color onWindow;
  final Color onWindowMuted;
  final Color brass;
  final Color brassSoft;
  final Color onBrass;
  final Color paperShade;
  final Color skyGlow;
  final Color depthShadow;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;

  static const light = NoorColors(
    isDark: false,
    paper: Color(0xFFEEF0F4),
    card: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE3E6EC),
    line: Color(0xFFCFD3DC),
    lineStrong: Color(0xFF7D8391),
    ink: Color(0xFF1A1C22),
    muted: Color(0xFF555A66),
    window: Color(0xFF171A21),
    windowRaised: Color(0xFF262A33),
    onWindow: Color(0xFFF7F7F4),
    onWindowMuted: Color(0xFFA6ABB8),
    brass: Color(0xFF7A6436),
    brassSoft: Color(0xFFEFE8D8),
    onBrass: Color(0xFFFFFFFF),
    paperShade: Color(0xFFE8EAEF),
    skyGlow: Color.fromRGBO(247, 247, 244, 0.16),
    depthShadow: Color.fromRGBO(23, 26, 33, 0.30),
    success: Color(0xFF2E6A4E),
    successSoft: Color(0xFFE3EFE8),
    danger: Color(0xFF9E3A2B),
    dangerSoft: Color(0xFFF6E4E0),
  );

  static const dark = NoorColors(
    isDark: true,
    paper: Color(0xFF101217),
    card: Color(0xFF1C1F27),
    surfaceSunken: Color(0xFF0A0B0F),
    line: Color(0xFF2C303A),
    lineStrong: Color(0xFF6B7180),
    ink: Color(0xFFECEEF2),
    muted: Color(0xFFA3A8B5),
    window: Color(0xFF07080C),
    windowRaised: Color(0xFF1F232C),
    onWindow: Color(0xFFF7F7F4),
    onWindowMuted: Color(0xFFA6ABB8),
    brass: Color(0xFFCDB588),
    brassSoft: Color(0xFF2F2A1F),
    onBrass: Color(0xFF15171C),
    paperShade: Color(0xFF13161C),
    skyGlow: Color.fromRGBO(247, 247, 244, 0.12),
    depthShadow: Color.fromRGBO(0, 0, 0, 0.78),
    success: Color(0xFF7FC4A2),
    successSoft: Color(0xFF1A2A22),
    danger: Color(0xFFF0A493),
    dangerSoft: Color(0xFF331D19),
  );

  // Shadow tokens. Depth is the material: every raised layer gets one.
  static const _shadow1Paper = [
    BoxShadow(
        color: Color.fromRGBO(23, 26, 33, 0.06),
        offset: Offset(0, 1),
        blurRadius: 1),
    BoxShadow(
        color: Color.fromRGBO(23, 26, 33, 0.07),
        offset: Offset(0, 2),
        blurRadius: 5),
  ];
  static const _shadow1Night = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.45),
        offset: Offset(0, 1),
        blurRadius: 1),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.35),
        offset: Offset(0, 2),
        blurRadius: 5),
  ];
  static const _shadow2Paper = [
    BoxShadow(
        color: Color.fromRGBO(23, 26, 33, 0.06),
        offset: Offset(0, 2),
        blurRadius: 4),
    BoxShadow(
        color: Color.fromRGBO(23, 26, 33, 0.09),
        offset: Offset(0, 8),
        blurRadius: 18),
  ];
  static const _shadow2Night = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.5),
        offset: Offset(0, 2),
        blurRadius: 4),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.45),
        offset: Offset(0, 8),
        blurRadius: 18),
  ];
  static const _shadow3Paper = [
    BoxShadow(
        color: Color.fromRGBO(23, 26, 33, 0.08),
        offset: Offset(0, 6),
        blurRadius: 10),
    BoxShadow(
        color: Color.fromRGBO(23, 26, 33, 0.14),
        offset: Offset(0, 20),
        blurRadius: 40),
  ];
  static const _shadow3Night = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.55),
        offset: Offset(0, 6),
        blurRadius: 10),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.55),
        offset: Offset(0, 20),
        blurRadius: 40),
  ];

  /// Flat paper: list groups, inputs on raised paper, the tab bar.
  List<BoxShadow> get shadow1 => isDark ? _shadow1Night : _shadow1Paper;

  /// Cards and buttons: the default lift.
  List<BoxShadow> get shadow2 => isDark ? _shadow2Night : _shadow2Paper;

  /// The front-most layer: hero ArchFrame, sheets, dialogs.
  List<BoxShadow> get shadow3 => isDark ? _shadow3Night : _shadow3Paper;

  /// `shadow-inset` (0 2px 4px, 10% ink in Paper / 60% black in Night) for
  /// surface-sunken wells. [BoxDecoration] only paints shadows outside the
  /// box, so this carries the token values for a painter to draw inside.
  List<BoxShadow> get inset => isDark ? _insetNight : _insetPaper;
  static const _insetPaper = [
    BoxShadow(
        color: Color.fromRGBO(23, 26, 33, 0.10),
        offset: Offset(0, 2),
        blurRadius: 4),
  ];
  static const _insetNight = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.6),
        offset: Offset(0, 2),
        blurRadius: 4),
  ];

  @override
  NoorColors copyWith({
    bool? isDark,
    Color? paper,
    Color? card,
    Color? surfaceSunken,
    Color? line,
    Color? lineStrong,
    Color? ink,
    Color? muted,
    Color? window,
    Color? windowRaised,
    Color? onWindow,
    Color? onWindowMuted,
    Color? brass,
    Color? brassSoft,
    Color? onBrass,
    Color? paperShade,
    Color? skyGlow,
    Color? depthShadow,
    Color? success,
    Color? successSoft,
    Color? danger,
    Color? dangerSoft,
  }) =>
      NoorColors(
        isDark: isDark ?? this.isDark,
        paper: paper ?? this.paper,
        card: card ?? this.card,
        surfaceSunken: surfaceSunken ?? this.surfaceSunken,
        line: line ?? this.line,
        lineStrong: lineStrong ?? this.lineStrong,
        ink: ink ?? this.ink,
        muted: muted ?? this.muted,
        window: window ?? this.window,
        windowRaised: windowRaised ?? this.windowRaised,
        onWindow: onWindow ?? this.onWindow,
        onWindowMuted: onWindowMuted ?? this.onWindowMuted,
        brass: brass ?? this.brass,
        brassSoft: brassSoft ?? this.brassSoft,
        onBrass: onBrass ?? this.onBrass,
        paperShade: paperShade ?? this.paperShade,
        skyGlow: skyGlow ?? this.skyGlow,
        depthShadow: depthShadow ?? this.depthShadow,
        success: success ?? this.success,
        successSoft: successSoft ?? this.successSoft,
        danger: danger ?? this.danger,
        dangerSoft: dangerSoft ?? this.dangerSoft,
      );

  @override
  NoorColors lerp(ThemeExtension<NoorColors>? other, double t) {
    if (other is! NoorColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return NoorColors(
      isDark: t < 0.5 ? isDark : other.isDark,
      paper: l(paper, other.paper),
      card: l(card, other.card),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      line: l(line, other.line),
      lineStrong: l(lineStrong, other.lineStrong),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      window: l(window, other.window),
      windowRaised: l(windowRaised, other.windowRaised),
      onWindow: l(onWindow, other.onWindow),
      onWindowMuted: l(onWindowMuted, other.onWindowMuted),
      brass: l(brass, other.brass),
      brassSoft: l(brassSoft, other.brassSoft),
      onBrass: l(onBrass, other.onBrass),
      paperShade: l(paperShade, other.paperShade),
      skyGlow: l(skyGlow, other.skyGlow),
      depthShadow: l(depthShadow, other.depthShadow),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
    );
  }
}

extension NoorContext on BuildContext {
  NoorColors get noor => Theme.of(this).extension<NoorColors>()!;
}

/// `space-1` … `space-8`.
abstract final class NoorSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;
  static const double s7 = 48;
  static const double s8 = 64;
}

/// `radius-sm` / `-md` / `-lg` / `-pill`.
abstract final class NoorRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 24;
  static const double pill = 999;
}

/// Text styles from tokens.json. Display styles and big numbers use
/// Cormorant Garamond, interface text Jost; every style falls back to Amiri so
/// Arabic never lands on a system font. In locale `ar` the interface ramp is
/// Amiri outright (design.md 3.2): sizes and line heights come from the Arabic
/// ramp, weights map to 400 or 700, and there is no letter-spacing. Colour is
/// `ink`, or `muted` for [bodySm], [eyebrow] and [caption]. [eyebrow] is set
/// uppercase by the caller.
abstract final class NoorText {
  static const _display = 'Cormorant Garamond';
  static const _sans = 'Jost';
  static const _arabic = 'Amiri';
  static const _fallback = [_arabic];

  static bool _isAr(BuildContext c) =>
      Localizations.localeOf(c).languageCode == 'ar';

  /// [ar] is the Arabic size / line height / weight; null keeps the Latin
  /// style in every locale.
  static TextStyle _s(
    BuildContext c,
    String family,
    double size,
    double lineHeight,
    FontWeight weight,
    Color color, {
    double? letterSpacing,
    (double, double, FontWeight)? ar,
  }) {
    if (ar != null && _isAr(c)) {
      return TextStyle(
        fontFamily: _arabic,
        fontSize: ar.$1,
        height: ar.$2 / ar.$1,
        fontWeight: ar.$3,
        color: color,
      );
    }
    return TextStyle(
      fontFamily: family,
      fontFamilyFallback: _fallback,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle displayXl(BuildContext c) =>
      _s(c, _display, 56, 60, FontWeight.w600, c.noor.ink,
          letterSpacing: -0.5, ar: (40, 64, FontWeight.w700));

  static TextStyle displayLg(BuildContext c) =>
      _s(c, _display, 40, 44, FontWeight.w600, c.noor.ink,
          ar: (40, 64, FontWeight.w700));

  static TextStyle title(BuildContext c) =>
      _s(c, _display, 28, 34, FontWeight.w600, c.noor.ink,
          ar: (28, 40, FontWeight.w700));

  static TextStyle heading(BuildContext c) =>
      _s(c, _sans, 18, 24, FontWeight.w500, c.noor.ink,
          ar: (18, 30, FontWeight.w700));

  static TextStyle body(BuildContext c) =>
      _s(c, _sans, 16, 24, FontWeight.w400, c.noor.ink,
          ar: (19, 34, FontWeight.w400));

  static TextStyle bodySm(BuildContext c) =>
      _s(c, _sans, 14, 20, FontWeight.w400, c.noor.muted,
          ar: (15, 22, FontWeight.w400));

  static TextStyle label(BuildContext c) =>
      _s(c, _sans, 15, 20, FontWeight.w500, c.noor.ink,
          letterSpacing: 0.2, ar: (15, 22, FontWeight.w700));

  static TextStyle eyebrow(BuildContext c) =>
      _s(c, _sans, 12, 16, FontWeight.w500, c.noor.muted,
          letterSpacing: 1.6, ar: (12, 18, FontWeight.w400));

  static TextStyle caption(BuildContext c) =>
      _s(c, _sans, 12, 16, FontWeight.w400, c.noor.muted,
          ar: (12, 18, FontWeight.w400));

  /// Dhikr text: Arabic content in every locale, so Amiri whatever the UI
  /// language is.
  static TextStyle dhikr(BuildContext c) =>
      _s(c, _arabic, 24, 52, FontWeight.w400, c.noor.ink);

  static TextStyle arabicDisplay(BuildContext c) =>
      _s(c, _arabic, 40, 64, FontWeight.w700, c.noor.ink);

  static TextStyle arabicBody(BuildContext c) =>
      _s(c, _arabic, 19, 34, FontWeight.w400, c.noor.ink);

  /// Screen greeting: [arabicDisplay] in Arabic, whose generous leading keeps
  /// diacritics clear, [displayLg] otherwise.
  static TextStyle display(BuildContext c) =>
      Localizations.localeOf(c).languageCode == 'ar'
          ? arabicDisplay(c)
          : displayLg(c);

  /// Times and big numbers: the display face with tabular lining figures.
  static TextStyle numeral(BuildContext c, {double size = 22, Color? color}) =>
      TextStyle(
        fontFamily: _display,
        fontFamilyFallback: _fallback,
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontFeatures: const [
          FontFeature.tabularFigures(),
          FontFeature.liningFigures(),
        ],
        color: color ?? c.noor.ink,
      );
}

abstract final class NoorTheme {
  static ThemeData light() => _build(NoorColors.light, Brightness.light);
  static ThemeData dark() => _build(NoorColors.dark, Brightness.dark);

  static ThemeData _build(NoorColors n, Brightness brightness) {
    // tokens.json has no on-danger colour; `card` is the documented ground
    // for danger text and contrasts with the fill in both themes.
    final scheme = ColorScheme(
      brightness: brightness,
      primary: n.brass,
      onPrimary: n.onBrass,
      secondary: n.brass,
      onSecondary: n.onBrass,
      tertiary: n.brass,
      onTertiary: n.onBrass,
      error: n.danger,
      onError: n.card,
      surface: n.card,
      onSurface: n.ink,
      onSurfaceVariant: n.muted,
      outline: n.lineStrong,
      outlineVariant: n.line,
      surfaceTint: Colors.transparent,
      shadow: n.depthShadow,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Jost',
      fontFamilyFallback: const ['Amiri'],
      colorScheme: scheme,
      scaffoldBackgroundColor: n.paper,
      extensions: [n],
    );

    OutlineInputBorder inputBorder(BorderSide side) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoorRadius.md),
          borderSide: side,
        );

    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: n.ink, displayColor: n.ink),
      dividerTheme: DividerThemeData(color: n.line, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: n.card,
        modalBackgroundColor: n.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(NoorRadius.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: n.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoorRadius.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: n.card,
        hintStyle: TextStyle(color: n.muted),
        contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: NoorSpace.s4, vertical: NoorSpace.s3),
        border: inputBorder(BorderSide.none),
        enabledBorder: inputBorder(BorderSide.none),
        focusedBorder: inputBorder(BorderSide(color: n.brass, width: 1.5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? n.onWindow : n.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? n.window : n.surfaceSunken,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : n.lineStrong,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: n.brass,
        selectionColor: n.brassSoft,
        selectionHandleColor: n.brass,
      ),
      iconTheme: IconThemeData(color: n.ink),
    );
  }
}

/// Transparent system bars with icons matching the active theme.
SystemUiOverlayStyle noorSystemOverlay(Brightness themeBrightness) {
  final iconBrightness =
      themeBrightness == Brightness.dark ? Brightness.light : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: themeBrightness,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: iconBrightness,
    systemNavigationBarContrastEnforced: false,
  );
}

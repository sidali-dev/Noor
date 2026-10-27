import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Noor Imene design tokens and themes. See `design.md`.
///
/// Usage: `final n = context.noor;` then `n.paper`, `n.ink`, ...

enum NoorTint { sage, amber, blue, lilac, mint }

/// Semantic colour tokens, registered on [ThemeData.extensions].
@immutable
class NoorColors extends ThemeExtension<NoorColors> {
  const NoorColors({
    required this.isDark,
    required this.paper,
    required this.card,
    required this.line,
    required this.ink,
    required this.body,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.gold,
    required this.danger,
    required this.mushaf,
  });

  final bool isDark;
  final Color paper;
  final Color card;
  final Color line;
  final Color ink;
  final Color body;
  final Color muted;
  final Color primary;
  final Color onPrimary;
  final Color gold;
  final Color danger;
  final Color mushaf;

  static const light = NoorColors(
    isDark: false,
    paper: Color(0xFFF6F3EB),
    card: Color(0xFFFDFCF8),
    line: Color(0xFFECE7DA),
    ink: Color(0xFF14382A),
    body: Color(0xFF2A3B33),
    // design.md #7E8A83 measured 3.5:1 on card; darkened, same hue.
    muted: Color(0xFF6A766E),
    primary: Color(0xFF1F5A41),
    onPrimary: Color(0xFFF6F3EB),
    gold: Color(0xFFC79A3B),
    danger: Color(0xFFB3412F),
    mushaf: Color(0xFFFBF6E8),
  );

  static const dark = NoorColors(
    isDark: true,
    paper: Color(0xFF0E1512),
    card: Color(0xFF16211C),
    line: Color(0xFF223029),
    ink: Color(0xFFEAF1EC),
    body: Color(0xFFCFDBD3),
    muted: Color(0xFF8FA398),
    // design.md #3C8A66 measured 3.6:1 against onPrimary; darkened, same hue.
    primary: Color(0xFF2E7856),
    onPrimary: Color(0xFFEAF1EC),
    gold: Color(0xFFD8B35A),
    danger: Color(0xFFE0705D),
    mushaf: Color(0xFF121A16),
  );

  static const _tintBgLight = {
    NoorTint.sage: Color(0xFFE4EDE4),
    NoorTint.amber: Color(0xFFF8EBD0),
    NoorTint.blue: Color(0xFFE3E8F1),
    NoorTint.lilac: Color(0xFFE9E3F3),
    NoorTint.mint: Color(0xFFDDEBE2),
  };

  static const _tintFg = {
    NoorTint.sage: Color(0xFF2E6B4F),
    NoorTint.amber: Color(0xFFC58A2B),
    NoorTint.blue: Color(0xFF4B607E),
    NoorTint.lilac: Color(0xFF6F5C94),
    NoorTint.mint: Color(0xFF2E7A5A),
  };

  /// Icon-tile background. Dark: 18% of the icon colour over `card`.
  Color tintBg(NoorTint t) => isDark
      ? Color.alphaBlend(_tintFg[t]!.withValues(alpha: 0.18), card)
      : _tintBgLight[t]!;

  /// Icon colour on the matching tile.
  Color tintFg(NoorTint t) => _tintFg[t]!;

  @override
  NoorColors copyWith({
    bool? isDark,
    Color? paper,
    Color? card,
    Color? line,
    Color? ink,
    Color? body,
    Color? muted,
    Color? primary,
    Color? onPrimary,
    Color? gold,
    Color? danger,
    Color? mushaf,
  }) =>
      NoorColors(
        isDark: isDark ?? this.isDark,
        paper: paper ?? this.paper,
        card: card ?? this.card,
        line: line ?? this.line,
        ink: ink ?? this.ink,
        body: body ?? this.body,
        muted: muted ?? this.muted,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        gold: gold ?? this.gold,
        danger: danger ?? this.danger,
        mushaf: mushaf ?? this.mushaf,
      );

  @override
  NoorColors lerp(ThemeExtension<NoorColors>? other, double t) {
    if (other is! NoorColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return NoorColors(
      isDark: t < 0.5 ? isDark : other.isDark,
      paper: l(paper, other.paper),
      card: l(card, other.card),
      line: l(line, other.line),
      ink: l(ink, other.ink),
      body: l(body, other.body),
      muted: l(muted, other.muted),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      gold: l(gold, other.gold),
      danger: l(danger, other.danger),
      mushaf: l(mushaf, other.mushaf),
    );
  }
}

extension NoorContext on BuildContext {
  NoorColors get noor => Theme.of(this).extension<NoorColors>()!;
}

abstract final class NoorSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract final class NoorRadius {
  static const double card = 20;
  static const double tile = 16;
  static const double input = 14;
  static const double sheet = 28;
}

/// The single elevation language: soft, wide, green-tinted. None in dark
/// (components draw a `line` outline instead).
List<BoxShadow> noorShadow(BuildContext c) => c.noor.isDark
    ? const []
    : const [
        BoxShadow(
          color: Color(0x1214382A),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];

abstract final class NoorText {
  static const _plex = 'Plex';
  static const _spectral = 'Spectral';
  static const _amiri = 'Amiri';

  static bool _isArabic(BuildContext c) =>
      Localizations.localeOf(c).languageCode == 'ar';

  static TextStyle display(BuildContext c) => _isArabic(c)
      ? TextStyle(
          fontFamily: _amiri,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: c.noor.ink,
        )
      : TextStyle(
          fontFamily: _spectral,
          fontFamilyFallback: const [_plex, _amiri],
          fontSize: 34,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: c.noor.ink,
        );

  static TextStyle section(BuildContext c) => TextStyle(
        fontFamily: _plex,
        fontFamilyFallback: const [_amiri],
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: c.noor.ink,
      );

  static TextStyle rowTitle(BuildContext c) => TextStyle(
        fontFamily: _plex,
        fontFamilyFallback: const [_amiri],
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: c.noor.ink,
      );

  static TextStyle body(BuildContext c) => TextStyle(
        fontFamily: _plex,
        fontFamilyFallback: const [_amiri],
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: c.noor.body,
      );

  static TextStyle meta(BuildContext c) => TextStyle(
        fontFamily: _plex,
        fontFamilyFallback: const [_amiri],
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: c.noor.muted,
      );

  static TextStyle numeral(BuildContext c,
          {double size = 22, Color? color}) =>
      TextStyle(
        fontFamily: _spectral,
        fontFamilyFallback: const [_plex, _amiri],
        fontSize: size,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color ?? c.noor.ink,
      );

  static TextStyle wordmark(BuildContext c) => TextStyle(
        fontFamily: _spectral,
        fontFamilyFallback: const [_plex, _amiri],
        fontSize: 26,
        fontWeight: FontWeight.w500,
        color: c.noor.ink,
      );

  static TextStyle dhikr(BuildContext c) => TextStyle(
        fontFamily: _amiri,
        fontSize: 24,
        height: 1.9,
        color: c.noor.body,
      );
}

abstract final class NoorTheme {
  static ThemeData light() => _build(NoorColors.light, Brightness.light);
  static ThemeData dark() => _build(NoorColors.dark, Brightness.dark);

  static ThemeData _build(NoorColors n, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: n.primary,
      onPrimary: n.onPrimary,
      secondary: n.primary,
      onSecondary: n.onPrimary,
      tertiary: n.gold,
      onTertiary: n.ink,
      error: n.danger,
      onError: Colors.white,
      surface: n.card,
      onSurface: n.body,
      onSurfaceVariant: n.muted,
      outline: n.line,
      outlineVariant: n.line,
      surfaceTint: Colors.transparent,
      shadow: const Color(0xFF14382A),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Plex',
      fontFamilyFallback: const ['Amiri'],
      colorScheme: scheme,
      scaffoldBackgroundColor: n.paper,
      extensions: [n],
    );

    OutlineInputBorder inputBorder(BorderSide side) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(NoorRadius.input),
          borderSide: side,
        );

    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: n.body, displayColor: n.ink),
      dividerTheme: DividerThemeData(color: n.line, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: n.card,
        modalBackgroundColor: n.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(NoorRadius.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: n.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: n.card,
        hintStyle: TextStyle(color: n.muted),
        contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: NoorSpace.lg, vertical: NoorSpace.md),
        border: inputBorder(BorderSide.none),
        enabledBorder: inputBorder(BorderSide.none),
        focusedBorder: inputBorder(BorderSide(color: n.primary, width: 1.5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? n.onPrimary : n.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? n.primary : n.line,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: n.primary,
        selectionColor: n.primary.withValues(alpha: 0.28),
        selectionHandleColor: n.primary,
      ),
      iconTheme: IconThemeData(color: n.ink),
    );
  }
}

/// Transparent system bars with icons matching the active theme.
SystemUiOverlayStyle noorSystemOverlay(Brightness themeBrightness) {
  final iconBrightness = themeBrightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;
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

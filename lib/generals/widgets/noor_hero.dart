import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_sky.dart';
import 'package:noor/generals/widgets/settings_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The stars of the skies that have them as (cx, cy, arm), in the art's
/// 390 x 240 space, in the order they twinkle. Painted, not baked, because they
/// twinkle; the frame over them hides any that fall outside a tab's window.
@visibleForTesting
const Map<NoorSky, List<(double, double, double)>> noorHeroStars = {
  // Keep in step with STARS in tool/hero_art.py, which checks they show.
  NoorSky.isha: [
    (262, 74, 2.6), (306, 62, 2.2), (252, 108, 2.2), //
    (332, 122, 2.0), (287, 50, 2.0), (244, 140, 2.2), (316, 146, 1.8),
  ],
};

// tool/hero_art.py bakes the art to these rects, in the 390 x 240 space. The
// frame runs past the art so its shadows can fade out, and is symmetric, so
// RTL only moves it.
const Rect _frameRect = Rect.fromLTWH(167, 0, 240, 240);
const Rect _skyRect = Rect.fromLTWH(205, 16, 164, 180);

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.stars, this.scale, this.twinkle) : super(repaint: twinkle);

  final List<(double, double, double)> stars;
  final double scale;
  final Animation<double>? twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(scale)
      ..translate(-_skyRect.left, -_skyRect.top);
    for (var i = 0; i < stars.length; i++) {
      final (x, y, r) = stars[i];
      final t = twinkle;
      canvas.drawPath(
        Path()
          ..moveTo(x, y - r)
          ..quadraticBezierTo(x, y, x + r, y)
          ..quadraticBezierTo(x, y, x, y + r)
          ..quadraticBezierTo(x, y, x - r, y)
          ..quadraticBezierTo(x, y, x, y - r)
          ..close(),
        Paint()
          ..color = const Color(0xFFF7F7F4).withValues(
              alpha: t == null ? 1 : noorTwinkleOpacity(t.value, i)),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) =>
      old.stars != stars || old.scale != scale;
}

/// Hilal screen header: a band of the page's own paper with the tab's onion
/// arch at the end, cut in layers with the sky of the hour behind it, and a bank
/// of paper clouds along the foot, clear above any [overlap], that runs into the
/// page. The title block sits at the start, an
/// optional settings disc at the end, and an optional [overlap] straddles the
/// bottom edge.
///
/// The widget is `height` plus half the overlap tall, so the content that
/// follows is not covered. In RTL the window moves to the other side; the art is
/// symmetric, so nothing mirrors.
///
/// Past a phone the art stops growing at [_maxArtWidth] and sits at the end of
/// the content column. On a short (landscape) window the band collapses to the
/// flat `window` fill and the title block.
class NoorHero extends StatelessWidget {
  /// The tab's [NoorArt] window; null draws the flat `window` fill instead.
  final String? art;
  final String title;

  /// One short verse or line, shown in `on-window-muted`.
  final String? subtitle;

  final Widget? leading;
  final bool settings;
  final double height;

  /// A 48-56 dp child that overlaps the bottom edge by half its height.
  final Widget? overlap;

  /// How much of the content width the title block may take. The window fills
  /// the rest, so a wide one (the Qibla window) needs less than half.
  final double textShare;

  const NoorHero({
    super.key,
    this.art,
    required this.title,
    this.subtitle,
    this.leading,
    this.settings = false,
    this.height = 240,
    this.overlap,
    this.textShare = 0.5,
  });

  static const double _overlapHeight = 56;

  // The art is one 390 dp illustration, not a tile: wider than this it would
  // grow tall rather than reach further.
  static const double _maxArtWidth = 480;

  // The art is 390 x 240; the wave clouds' crest starts around y = 176.
  static const double _artWidth = 390;
  static const double _artHeight = 240;
  static const double _cloudsCrest = 176;

  // The art above the frames' highest point (the Prayers finial) is empty paper.
  static const double _frameTop = 3;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<NoorSky>(
        valueListenable: noorSkyNow,
        builder: (context, sky, _) => _band(context, sky),
      );

  Widget _band(BuildContext context, NoorSky sky) {
    final n = context.noor;
    final short = NoorLayout.isShort(context);
    final hasArt = !short && art != null;
    final margin = NoorLayout.margin(context);
    final gutter = NoorLayout.gutter(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    final reserve = overlap == null ? 0.0 : _overlapHeight / 2;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final stars = noorHeroStars[sky];
    final variant = n.isDark ? 'night' : 'paper';

    final contentTop = safeTop + NoorSpace.s1;

    // The flat band is the dark `window`, whatever the theme; the art is paper.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: noorSystemOverlay(
        !hasArt || n.isDark ? Brightness.dark : Brightness.light,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final artWidth = math.min(width - 2 * margin, _maxArtWidth);
          final scale = artWidth / _artWidth;
          // Room the clouds take at the bottom of the band.
          final base = hasArt ? (_artHeight - _cloudsCrest) * scale : reserve;
          // The clouds run to the foot of their tile, so it stops above the
          // separator and overlap instead of sliding behind them.
          final lift = hasArt ? reserve + (overlap == null ? 0.0 : 8.0) : 0.0;
          final minHeight = short
              ? reserve
              // The frame clears the status bar, whatever a notch adds.
              : math.max(
                    height,
                    hasArt
                        ? (_artHeight - _frameTop) * scale +
                            safeTop +
                            NoorSpace.s1
                        : 0,
                  ) +
                  reserve +
                  lift;

          // The title block sets the band's height (never below `height`), so
          // large text or a tall status bar grows the band instead of being
          // clipped against the clouds. The overlap's shadow falls past the
          // bottom edge.
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: reserve,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: hasArt ? n.paper : n.window,
                    // The art's clouds run into the page. A flat band has no
                    // clouds, and in Night only the shadow frames it.
                    boxShadow: hasArt ? null : n.shadow3,
                  ),
                  child: hasArt
                      ? ExcludeSemantics(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              PositionedDirectional(
                                end: margin,
                                bottom: lift,
                                width: artWidth,
                                height: _artHeight * scale,
                                child: Stack(
                                  key: const ValueKey('noor-hero-art'),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fromRect(
                                      rect: _place(_skyRect, scale, rtl),
                                      child: Image.asset(
                                        key: const ValueKey('noor-hero-sky'),
                                        sky.asset,
                                        fit: BoxFit.fill,
                                        gaplessPlayback: true,
                                      ),
                                    ),
                                    if (stars != null)
                                      Positioned.fromRect(
                                        rect: _place(_skyRect, scale, rtl),
                                        child: NoorTwinkle(
                                          builder: (context, twinkle) =>
                                              CustomPaint(
                                            painter: _StarsPainter(
                                              stars,
                                              scale,
                                              twinkle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned.fromRect(
                                      rect: _place(_frameRect, scale, rtl),
                                      child: Image.asset(
                                        key: const ValueKey('noor-hero-frame'),
                                        NoorArt.frame(art!, variant),
                                        errorBuilder: (_, __, ___) =>
                                            const SizedBox.shrink(),
                                        fit: BoxFit.fill,
                                        gaplessPlayback: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: math.max(0.0, lift - 6 * scale),
                                height: 26 * scale,
                                child: const NoorSeparator(
                                  key: ValueKey('noor-hero-separator'),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: contentTop,
                    start: gutter,
                    bottom:
                        reserve + lift + math.max(base, reserve) + NoorSpace.s2,
                  ),
                  child: Align(
                    // Centred beside the arch, as in the references.
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(
                      width: math.max(0, (width - 2 * gutter) * textShare),
                      child: _titleBlock(context, short, hasArt),
                    ),
                  ),
                ),
              ),
              if (settings)
                PositionedDirectional(
                  top: contentTop + NoorSpace.s1,
                  end: gutter,
                  child: NoorCloudButton(
                    icon: const NoorIcon(NoorGlyph.settings),
                    tooltip: S.of(context).settings,
                    onTap: () => showSettingsSheet(context),
                  ),
                ),
              if (overlap != null)
                PositionedDirectional(
                  start: gutter,
                  end: gutter,
                  bottom: 0,
                  height: _overlapHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // A one-line control in a fixed 56 dp slot: it takes the same
                    // 1.3x ceiling as the sheet title and ellipsizes past it.
                    children: [
                      MediaQuery.withClampedTextScaling(
                        maxScaleFactor: 1.3,
                        child: overlap!,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// [rect] from the art's space to the art box, moved to the other end in RTL.
  static Rect _place(Rect rect, double scale, bool rtl) => Rect.fromLTWH(
        (rtl ? _artWidth - rect.right : rect.left) * scale,
        rect.top * scale,
        rect.width * scale,
        rect.height * scale,
      );

  Widget _titleBlock(BuildContext context, bool short, bool onPaper) {
    final n = context.noor;
    final gap = SizedBox(width: leading == null ? 0 : NoorSpace.s2 + 2);

    final subtitleStyle = NoorText.bodySm(context)
        .copyWith(color: onPaper ? n.muted : n.onWindowMuted);

    return Semantics(
      header: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: NoorSpace.s2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) leading!,
                gap,
                Flexible(
                  // One line that shrinks (text scale, long names) rather
                  // than wrapping into the subtitle.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      title,
                      style: NoorText.display(context)
                          .copyWith(color: onPaper ? n.ink : n.onWindow),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: NoorSpace.s1),
              child: Text(
                subtitle!,
                style: subtitleStyle,
                // A verse with its citation, so it may run to a few lines.
                maxLines: short ? 2 : 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

/// Vector SVG string for the sculpted Islamic arch-cusp separator at the foot
/// of [NoorHero], themed for Paper (`!isDark`) and Night (`isDark`).
String noorSeparatorSvg(bool isDark) {
  final shadow = isDark ? '#000000' : '#252934';
  final op1 = isDark ? '0.14' : '0.04';
  final op2 = isDark ? '0.22' : '0.07';
  final op3 = isDark ? '0.32' : '0.11';
  final op4 = isDark ? '0.44' : '0.16';
  final bodyTop = isDark ? '#2C3038' : '#FFFFFF';
  final bodyMid = isDark ? '#242830' : '#F6F7FA';
  final bodyBot = isDark ? '#1A1D23' : '#DCE0E9';
  final bevelTop = isDark ? '#323741' : '#FFFFFF';
  final bevelBot = isDark ? '#252830' : '#EDEFF4';
  final rimStroke = isDark ? '#3E4451' : '#FFFFFF';
  final creaseStroke = isDark ? '#181B20' : '#D0D5E0';

  const dBody =
      'M4.4 33.5C5.6 31.4 7.8 30.6 11 30.6H154.5C158.8 30.6 161.2 29.2 162.8 26.2C164 24.1 165.2 23.7 168 23.7H169.8C170.8 18.2 174.5 14.5 181.5 12C188.2 9.6 192.4 6.6 195 2.2C197.6 6.6 201.8 9.6 208.5 12C215.5 14.5 219.2 18.2 220.2 23.7H222C224.8 23.7 226 24.1 227.2 26.2C228.8 29.2 231.2 30.6 235.5 30.6H379C382.2 30.6 384.4 31.4 385.6 33.5H232C228.2 33.5 226.2 32.3 224.6 29.5C223.6 27.8 222.6 27.5 220 27.5H216.6C215.4 21 211.8 17.5 205.2 15C199.8 13 196.8 11.2 195 9.2C193.2 11.2 190.2 13 184.8 15C178.2 17.5 174.6 21 173.4 27.5H170C167.4 27.5 166.4 27.8 165.4 29.5C163.8 32.3 161.8 33.5 158 33.5H4.4Z';
  const dBevel =
      'M5.4 32.7C6.5 31.2 8.4 30.6 11 30.6H154.5C158.8 30.6 161.2 29.2 162.8 26.2C164 24.1 165.2 23.7 168 23.7H169.8C170.8 18.2 174.5 14.5 181.5 12C188.2 9.6 192.4 6.6 195 2.2C197.6 6.6 201.8 9.6 208.5 12C215.5 14.5 219.2 18.2 220.2 23.7H222C224.8 23.7 226 24.1 227.2 26.2C228.8 29.2 231.2 30.6 235.5 30.6H379C381.6 30.6 383.5 31.2 384.6 32.7H232.6C228.6 32.7 226.5 31.6 224.9 28.8C223.9 27.1 222.8 26.6 220.2 26.6H217.2C216 20.1 212.3 16.6 205.6 14.1C200.1 12.1 196.9 10.1 195 7.9C193.1 10.1 189.9 12.1 184.4 14.1C177.7 16.6 174 20.1 172.8 26.6H169.8C167.2 26.6 166.1 27.1 165.1 28.8C163.5 31.6 161.4 32.7 157.4 32.7H5.4Z';
  const dRim =
      'M4.8 33.1C6 31.3 8.1 30.6 11 30.6H154.5C158.8 30.6 161.2 29.2 162.8 26.2C164 24.1 165.2 23.7 168 23.7H169.8C170.8 18.2 174.5 14.5 181.5 12C188.2 9.6 192.4 6.6 195 2.2C197.6 6.6 201.8 9.6 208.5 12C215.5 14.5 219.2 18.2 220.2 23.7H222C224.8 23.7 226 24.1 227.2 26.2C228.8 29.2 231.2 30.6 235.5 30.6H379C381.9 30.6 384 31.3 385.2 33.1';

  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 40" fill="none">'
      '<defs>'
      '<linearGradient id="sep-body" x1="195" y1="2" x2="195" y2="34" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="$bodyTop"/>'
      '<stop offset="0.65" stop-color="$bodyMid"/>'
      '<stop offset="1" stop-color="$bodyBot"/>'
      '</linearGradient>'
      '<linearGradient id="sep-bevel" x1="195" y1="2" x2="195" y2="34" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="$bevelTop"/>'
      '<stop offset="1" stop-color="$bevelBot"/>'
      '</linearGradient>'
      '</defs>'
      '<g fill="$shadow">'
      '<path fill-opacity="$op1" transform="translate(0 3.8)" d="$dBody"/>'
      '<path fill-opacity="$op2" transform="translate(0 2.6)" d="$dBody"/>'
      '<path fill-opacity="$op3" transform="translate(0 1.6)" d="$dBody"/>'
      '<path fill-opacity="$op4" transform="translate(0 0.8)" d="$dBody"/>'
      '</g>'
      '<path fill="url(#sep-body)" d="$dBody"/>'
      '<path fill="url(#sep-bevel)" d="$dBevel"/>'
      '<path stroke="$rimStroke" stroke-width="0.9" stroke-linecap="round" stroke-linejoin="round" d="$dRim"/>'
      '<path stroke="$creaseStroke" stroke-width="0.6" stroke-linejoin="round" d="M195 2.2V9.2M169.8 23.7L173.4 27.5M220.2 23.7L216.6 27.5"/>'
      '</svg>';
}

/// Ornamental sculpted separator dividing the [NoorHero] header band from the
/// screen body below, adapting its bevel and shadow to Paper and Night themes.
class NoorSeparator extends StatelessWidget {
  const NoorSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.noor.isDark;
    return SvgPicture.string(
      isDark ? _svgNight : _svgPaper,
      fit: BoxFit.fill,
      excludeFromSemantics: true,
    );
  }

  // Built once, not on every build: svg.cache hashes the whole string.
  static final _svgPaper = noorSeparatorSvg(false);
  static final _svgNight = noorSeparatorSvg(true);
}

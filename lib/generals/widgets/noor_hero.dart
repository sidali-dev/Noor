import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // The art is 390 x 240; the clouds' crest starts at y = 176, and their tile
  // from y = 168 for the shadow above it.
  static const double _artWidth = 390;
  static const double _artHeight = 240;
  static const double _cloudsCrest = 176;
  static const double _cloudsTile = 168;

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
          // overlap instead of sliding behind it.
          final lift = hasArt ? reserve : 0.0;
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
                              // The tile repeats from the centre, so the band
                              // stays symmetric at any width.
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: lift,
                                height: (_artHeight - _cloudsTile) * scale,
                                child: Image.asset(
                                  key: const ValueKey('noor-hero-clouds'),
                                  NoorArt.clouds(variant),
                                  repeat: ImageRepeat.repeatX,
                                  alignment: Alignment.bottomCenter,
                                  fit: BoxFit.fitHeight,
                                  gaplessPlayback: true,
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
                    bottom: reserve + lift + math.max(base, reserve) + NoorSpace.s2,
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

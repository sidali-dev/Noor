import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/generals/widgets/settings_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The stars baked into each hero SVG as (cx, cy, arm), in the SVG's 390 x 240
/// space, in the order they twinkle. `art_assets_test` checks them against the
/// files.
// ponytail: the stars are baked into the SVG, so the twinkle dims a copy of
// each in the `window` colour over it instead of splitting the art into layers.
@visibleForTesting
const Map<String, List<(double, double, double)>> noorHeroStars = {
  NoorArt.heroQuran: [
    (196, 30, 2.6), (230, 96, 2.6), (372, 52, 2.6), (262, 66, 2.6), //
    (352, 24, 4.6), (214, 52, 4.6), (276, 22, 4.6),
  ],
  NoorArt.heroPrayers: [
    (192, 36, 2.6), (222, 100, 2.6), (352, 104, 2.6), (262, 22, 2.6), //
    (340, 30, 4.6), (208, 62, 4.6), (372, 78, 4.6),
  ],
  NoorArt.heroAthkar: [
    (176, 34, 2.6), (226, 22, 2.6), (260, 90, 2.6), (342, 112, 2.6), //
    (272, 26, 4.6), (378, 98, 4.6), (186, 64, 4.6),
  ],
  NoorArt.qiblaSkyline: [
    (150, 20, 2.6), (244, 18, 2.6), (336, 44, 2.6), (60, 54, 2.6), //
    (300, 26, 4.6), (108, 34, 4.6), (372, 24, 4.6),
  ],
};

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.stars, this.scale, this.sky, this.twinkle)
      : super(repaint: twinkle);

  final List<(double, double, double)> stars;
  final double scale;
  final Color sky;
  final Animation<double> twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    for (var i = 0; i < stars.length; i++) {
      final (x, y, r) = stars[i];
      final dim = 1 - noorTwinkleOpacity(twinkle.value, i);
      canvas.drawPath(
        Path()
          ..moveTo(x, y - r)
          ..quadraticBezierTo(x, y, x + r, y)
          ..quadraticBezierTo(x, y, x, y + r)
          ..quadraticBezierTo(x, y, x - r, y)
          ..quadraticBezierTo(x, y, x, y - r)
          ..close(),
        Paint()..color = sky.withValues(alpha: dim),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) =>
      old.stars != stars || old.scale != scale || old.sky != sky;
}

/// Hilal screen header: a night-sky band behind the status bar with the hero
/// art, whose white cloud-scroll base is part of the art. The title block sits
/// at the start, an optional settings disc at the end, and an optional
/// [overlap] straddles the bottom edge. The band is the one shadow-box moment
/// of the screen (`shadow-3`).
///
/// The widget is `height` plus half the overlap tall, so the content that
/// follows is not covered. In RTL the art mirrors with the layout, except the
/// pieces in [NoorArt.noMirror].
///
/// Past a phone the art stops growing at [_maxArtWidth] and sits at the end
/// of the content column, so the sky takes the spare width and the start side
/// is what gets cropped. On a short (landscape) window the band collapses to
/// the flat `window` fill and the title block.
class NoorHero extends StatelessWidget {
  /// A [NoorArt] hero base; null (or a base that has no art) draws the flat
  /// `window` fill instead.
  final String? art;
  final String title;

  /// One short verse or line, shown in `on-window-muted`.
  final String? subtitle;

  final Widget? leading;
  final bool settings;
  final double height;

  /// A 48-56 dp child that overlaps the bottom edge by half its height.
  final Widget? overlap;

  const NoorHero({
    super.key,
    this.art,
    required this.title,
    this.subtitle,
    this.leading,
    this.settings = false,
    this.height = 240,
    this.overlap,
  });

  static const double _overlapHeight = 56;

  // The art is one 390 dp illustration, not a tile: wider than this it would
  // grow tall rather than reach further.
  static const double _maxArtWidth = 480;

  // The hero SVGs are 390 x 240; the cloud-scroll base starts at y = 187.
  static const double _artWidth = 390;
  static const double _artHeight = 240;
  static const double _cloudTop = 187;

  // The art's subject (minaret, book, tasbih) fills the end half of the band,
  // so the text keeps to the start half.
  static const double _textShare = 0.5;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final art = this.art;
    final short = NoorLayout.isShort(context);
    final hasArt = !short && art != null && NoorArt.heroes.contains(art);
    final margin = NoorLayout.margin(context);
    final gutter = NoorLayout.gutter(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    final reserve = overlap == null ? 0.0 : _overlapHeight / 2;
    final flip = hasArt &&
        Directionality.of(context) == TextDirection.rtl &&
        !NoorArt.noMirror.contains(art);

    final contentTop = safeTop + NoorSpace.s1;

    // The band always has a dark top, so the status bar icons are light even
    // in Paper.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: noorSystemOverlay(Brightness.dark),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final artWidth = math.min(width - 2 * margin, _maxArtWidth);
          final scale = artWidth / _artWidth;
          // Room the baked cloud-scroll base takes at the bottom of the band.
          final base = hasArt ? (_artHeight - _cloudTop) * scale : reserve;
          final minHeight = short
              ? reserve
              : math.max(height, hasArt ? _artHeight * scale : 0) + reserve;

          // The title block sets the band's height (never below `height`), so
          // large text or a tall status bar grows the band instead of being
          // clipped against the cloud.
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: reserve,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: n.window,
                    boxShadow: n.shadow3,
                  ),
                  child: hasArt
                      ? Stack(
                          children: [
                            PositionedDirectional(
                              end: margin,
                              top: 0,
                              bottom: 0,
                              width: artWidth,
                              child: ExcludeSemantics(
                                child: Transform.flip(
                                  key: const ValueKey('noor-hero-art'),
                                  flipX: flip,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      SvgPicture.asset(
                                        NoorArt.svgOf(context, art),
                                        // Width-fitted and bottom-aligned: the
                                        // cloud base keeps its place whatever
                                        // the band height.
                                        fit: BoxFit.fitWidth,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: SizedBox(
                                          width: artWidth,
                                          height: _artHeight * scale,
                                          child: NoorTwinkle(
                                            builder: (context, twinkle) =>
                                                twinkle == null
                                                    ? const SizedBox.shrink()
                                                    : CustomPaint(
                                                        painter: _StarsPainter(
                                                          noorHeroStars[art] ??
                                                              const [],
                                                          scale,
                                                          n.window,
                                                          twinkle,
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                    bottom: reserve + math.max(base, reserve) + NoorSpace.s2,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: SizedBox(
                      width: math.max(0, (width - 2 * gutter) * _textShare),
                      child: _titleBlock(context, short),
                    ),
                  ),
                ),
              ),
              if (settings)
                PositionedDirectional(
                  top: contentTop + NoorSpace.s1,
                  end: gutter,
                  child: _settingsDisc(context),
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

  /// White paper disc: `surface-raised` with `shadow-1`, 48 dp target.
  Widget _settingsDisc(BuildContext context) {
    final n = context.noor;
    final label = S.of(context).settings;

    return Tooltip(
      message: label,
      child: NoorPressable(
        onPressed: () => showSettingsSheet(context),
        radius: NoorRadius.pill,
        builder: (context, pressed) => AnimatedContainer(
          duration: kNoorPressDuration,
          curve: Curves.ease,
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: n.card,
            shape: BoxShape.circle,
            boxShadow: pressed ? const [] : n.shadow1,
          ),
          child: NoorIcon(NoorGlyph.settings, color: n.ink, size: 22),
        ),
      ),
    );
  }

  Widget _titleBlock(BuildContext context, bool short) {
    final n = context.noor;
    final gap = SizedBox(width: leading == null ? 0 : NoorSpace.s2 + 2);

    final subtitleStyle =
        NoorText.bodySm(context).copyWith(color: n.onWindowMuted);

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
                      style:
                          NoorText.display(context).copyWith(color: n.onWindow),
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

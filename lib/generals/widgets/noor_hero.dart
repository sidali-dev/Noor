import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
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
    (150, 22, 2.6), (238, 12, 2.6), (126, 38, 2.6), (354, 22, 2.6), //
    (256, 9, 4.6), (10, 62, 4.6), (380, 36, 4.6),
  ],
  NoorArt.heroPrayers: [
    (150, 22, 2.6), (236, 14, 2.6), (128, 40, 2.6), (352, 14, 2.6), //
    (262, 8, 4.6), (8, 58, 4.6), (382, 52, 4.6),
  ],
  NoorArt.heroAthkar: [
    (150, 40, 2.6), (230, 10, 2.6), (132, 96, 2.6), (372, 12, 2.6), //
    (10, 70, 4.6), (160, 150, 4.6), (380, 22, 4.6),
  ],
  NoorArt.qiblaSkyline: [
    (150, 22, 2.6), (236, 16, 2.6), (128, 36, 2.6), (346, 30, 2.6), //
    (262, 10, 4.6), (8, 58, 4.6), (382, 62, 4.6),
  ],
};

/// Art that keeps its orientation: the SVG and its rect in the
/// 390 x 240 space, laid over the mirrored art at the same end of the band.
const Map<String, (String, Rect)> _upright = {
  NoorArt.heroQuran: (
    NoorArt.objectQuran,
    Rect.fromLTWH(216, 84, 140, 117),
  ),
  NoorArt.heroPrayers: (
    NoorArt.objectMosque,
    Rect.fromLTWH(193, 80, 182, 121),
  ),
  NoorArt.qiblaSkyline: (
    NoorArt.qiblaKaaba,
    Rect.fromLTWH(201.5, 66.7, 176.3, 139.8),
  ),
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
/// art and a page-coloured cloud-scroll base painted over its foot. The title
/// block sits at the start, an optional settings disc at the end, and an
/// optional [overlap] straddles the bottom edge. With art the band casts no shadow, so
/// it stays joined to the page; the flat band keeps `shadow-3`.
///
/// The widget is `height` plus half the overlap tall, so the content that
/// follows is not covered. In RTL the art mirrors with the layout; the pieces
/// with writing on them (the Qibla Kaaba) stay upright and move to the other
/// side with it.
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

  /// How much of the content width the title block may take. The art's subject
  /// fills the rest, so a centred subject (the Qibla arch) needs less than half.
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

  // The hero SVGs are 390 x 240; the cloud-scroll base takes the foot from
  // y = 187.
  static const double _artWidth = 390;
  static const double _artHeight = 240;
  static const double _cloudTop = 187;

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
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final flip = hasArt && rtl;
    final upright = hasArt ? _upright[art] : null;

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
          // Room the cloud-scroll base takes at the bottom of the band.
          final base = hasArt ? (_artHeight - _cloudTop) * scale : reserve;
          final minHeight = short
              ? reserve
              : math.max(height, hasArt ? _artHeight * scale : 0) + reserve;

          // The title block sets the band's height (never below `height`), so
          // large text or a tall status bar grows the band instead of being
          // clipped against the cloud. The overlap's shadow falls past the
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
                    color: n.window,
                    // The art's cloud base runs into the page. A flat band has
                    // no base, and in Night only the shadow frames it.
                    boxShadow: hasArt ? null : n.shadow3,
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
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Transform.flip(
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
                                                        ? const SizedBox
                                                            .shrink()
                                                        : CustomPaint(
                                                            painter:
                                                                _StarsPainter(
                                                              noorHeroStars[
                                                                      art] ??
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
                                    if (upright != null)
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: SizedBox(
                                          width: artWidth,
                                          height: _artHeight * scale,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: (rtl
                                                        ? _artWidth -
                                                            upright.$2.right
                                                        : upright.$2.left) *
                                                    scale,
                                                top: upright.$2.top * scale,
                                                width: upright.$2.width * scale,
                                                height:
                                                    upright.$2.height * scale,
                                                child: SvgPicture.asset(
                                                  upright.$1,
                                                  key: const ValueKey(
                                                      'noor-hero-upright'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            // Over the art's foot, which they cover: painted, not
                            // baked in, so they can cast shadows.
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: base + CloudBankPainter.headroom,
                              child: ExcludeSemantics(
                                child: CustomPaint(
                                  painter: CloudBankPainter(
                                    back: n.isDark
                                        ? n.windowRaised
                                        : n.surfaceSunken,
                                    front: n.paper,
                                    lip: n.isDark ? n.depthShadow : null,
                                    shade: n.depthShadow,
                                    pixelRatio:
                                        MediaQuery.devicePixelRatioOf(context),
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
                      width: math.max(0, (width - 2 * gutter) * textShare),
                      child: _titleBlock(context, short),
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

import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// `paper` is raised paper; `night` is a window into the sky, for the one
/// most time-sensitive thing on a screen.
enum NoorCardTone { paper, night }

/// Paper cut like a page of the Mushaf: a `line` panel pressed into it, a star
/// in each top corner, an optional [folio] between them and a bank of clouds
/// along the foot. [child] keeps clear of all of it, so no ornament touches a
/// word. A short window has no room for the clouds, as the hero drops its art.
/// It shrinks to [child], or fills a parent that fixes its size.
class NoorPagePanel extends StatelessWidget {
  final Widget child;
  final String? folio;

  /// How much of the foot the clouds take; 0 for none.
  final double cloudHeight;

  /// Replaces the room kept for the stars, for a child that minds them itself.
  final double? contentTop;

  const NoorPagePanel({
    super.key,
    required this.child,
    this.folio,
    this.cloudHeight = standardCloudHeight,
    this.contentTop,
  });

  static const double standardCloudHeight = 52;

  static const double _inset = NoorSpace.s2;
  static const double _near = _inset + NoorSpace.s2;
  static const double _star = 14;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final clouds = cloudHeight > 0 && !NoorLayout.isShort(context);
    final folio = this.folio;

    Widget corner({double? left, double? right}) => Positioned(
          top: _near,
          left: left,
          right: right,
          child: IgnorePointer(
            child: NoorIcon(NoorGlyph.star, size: _star, color: n.line),
          ),
        );

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(_inset),
            child: IgnorePointer(
              child: NoorWell(
                radius: NoorRadius.md,
                fill: n.card,
                borderColor: n.line,
              ),
            ),
          ),
        ),
        corner(left: _near),
        corner(right: _near),
        if (folio != null)
          Positioned(
            top: _near - 2,
            left: 0,
            right: 0,
            child: Text(
              folio,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: NoorText.numeral(context, size: 15, color: n.muted),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            top: contentTop ??
                (folio == null
                    ? _near + _star + NoorSpace.s1
                    : NoorSpace.s7 - NoorSpace.s1),
            bottom: clouds ? cloudHeight + _inset + 1 : _inset,
          ),
          child: child,
        ),
        // Inside the panel's hairline, which stays drawn around the clouds.
        if (clouds)
          Positioned(
            left: _inset + 1,
            right: _inset + 1,
            bottom: _inset + 1,
            height: cloudHeight,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(NoorRadius.md - 1),
                ),
                child: CustomPaint(
                  painter: CloudBankPainter(
                    back: n.isDark ? n.windowRaised : n.surfaceSunken,
                    front: n.card,
                    lip: n.isDark ? n.depthShadow : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A `line` rule broken by a star, between one part of a text and the next.
class NoorOrnament extends StatelessWidget {
  const NoorOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final rule = Expanded(
      child: SizedBox(height: 1, child: ColoredBox(color: n.line)),
    );
    return Center(
      child: SizedBox(
        width: 160,
        child: Row(
          children: [
            rule,
            const SizedBox(width: NoorSpace.s2),
            NoorIcon(NoorGlyph.star, size: 14, color: n.line),
            const SizedBox(width: NoorSpace.s2),
            rule,
          ],
        ),
      ),
    );
  }
}

/// Hilal PaperCard: `surface-raised`, `shadow-2`, radius 24, no border, cut as a
/// [NoorPagePanel]. With [onTap] it presses 1 dp down and drops to `shadow-1`.
///
/// On the night tone, descendants that read `context.noor` / the text theme
/// below this card get `on-window` colours; styles a caller resolved above the
/// card keep their own colour and must use `onWindow` themselves.
class NoorCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final NoorCardTone tone;

  /// The place in a series, between the top stars. Paper tone only.
  final String? folio;

  /// How much of the foot the clouds take. Paper tone only.
  final double cloudHeight;

  const NoorCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.tone = NoorCardTone.paper,
    this.folio,
    this.cloudHeight = NoorPagePanel.standardCloudHeight,
  });

  /// The `surface-raised` frame around a night window (mock: 4 dp inset).
  static const double _ring = 4;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final night = tone == NoorCardTone.night;
    final radius = BorderRadius.circular(NoorRadius.lg);

    Widget body = Material(
      color: Colors.transparent,
      child: night
          ? Padding(
              padding: padding ?? const EdgeInsets.all(NoorSpace.s4),
              child: child,
            )
          : NoorPagePanel(
              folio: folio,
              cloudHeight: cloudHeight,
              child: Padding(
                padding: padding ??
                    const EdgeInsets.fromLTRB(
                      NoorSpace.s5,
                      0,
                      NoorSpace.s5,
                      NoorSpace.s2,
                    ),
                child: child,
              ),
            ),
    );
    if (night) {
      final theme = Theme.of(context);
      body = Theme(
        data: theme.copyWith(
          extensions: [n.copyWith(ink: n.onWindow, muted: n.onWindowMuted)],
          textTheme: theme.textTheme
              .apply(bodyColor: n.onWindow, displayColor: n.onWindow),
          iconTheme: theme.iconTheme.copyWith(color: n.onWindow),
        ),
        child: body,
      );
      // The window is nearly the Night ground (1.07:1), so in Night only the
      // contract adds a decorative 1 dp `line` seam where it meets the ring:
      // the ring below covers all but that last dp of this border.
      if (n.isDark) {
        body = DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: n.line, width: _ring + 1),
          ),
          child: body,
        );
      }
    }

    return NoorPressable(
      onPressed: onTap,
      radius: NoorRadius.lg,
      builder: (context, pressed) => AnimatedContainer(
        duration: kNoorPressDuration,
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: night ? n.window : n.card,
          borderRadius: radius,
          boxShadow: pressed ? n.shadow1 : n.shadow2,
        ),
        // A window is never bare on the ground: raised paper frames it. Its
        // contents are clipped to the corners, for art at the card's edge.
        clipBehavior: night ? Clip.antiAlias : Clip.none,
        foregroundDecoration: night
            ? BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: n.card, width: _ring),
              )
            : null,
        child: body,
      ),
    );
  }
}

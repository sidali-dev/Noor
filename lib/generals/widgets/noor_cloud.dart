import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/baked_paint.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// A number on a puff of Hilal's cloud scroll: a back row (`surface-sunken`,
/// `line` in Night) under a `surface-raised` front row, whose cut edge is a
/// crisp 1 dp lip. The whole puff casts one `shadow-1`, and the front row
/// shades the back one a little, so the two read as stacked sheets.
class CloudMedallion extends StatelessWidget {
  final double size;
  final Widget child;

  /// Replaces `shadow-1`, for a puff that is a control rather than a marker.
  final List<BoxShadow>? shadows;

  /// 0 to 1: how much the puff glows, for the one that is chosen or pressed.
  /// A soft halo of the window colour (moon-white in Night) round the outside;
  /// the rows keep their own paper, which is what made a filled puff read as a
  /// flower.
  final double glow;

  const CloudMedallion({
    super.key,
    required this.size,
    required this.child,
    this.shadows,
    this.glow = 0,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _CloudPainter(
          back: n.isDark ? n.line : n.surfaceSunken,
          front: n.card,
          lip: n.isDark ? n.depthShadow : n.line,
          shade: n.depthShadow,
          glow: (n.isDark ? n.onWindow : n.window)
              .withValues(alpha: _glowAlpha * glow),
          shadows: shadows ?? n.shadow1,
          pixelRatio: MediaQuery.devicePixelRatioOf(context),
        ),
        child: Center(
          child: SizedBox(
            width: size * 0.62,
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        ),
      ),
    );
  }

  // Strong enough to see on raised paper, soft enough not to contrast with it.
  static const double _glowAlpha = 0.32;
}

/// An icon button on a puff: 48 dp standing free, 40 dp in a row, a well or a
/// pill. The target is 48 dp either way. [icon] takes its size and colour from
/// here unless it sets its own, and is muted with no [onTap].
class NoorCloudButton extends StatelessWidget {
  final Widget icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final double size;

  /// Replaces the puff's `shadow-1`, for one that must stand off the surface
  /// it sits in, such as a well.
  final List<BoxShadow>? shadows;

  const NoorCloudButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 48,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final button = NoorPressable(
      onPressed: onTap,
      radius: NoorRadius.pill,
      builder: (context, pressed) => Container(
        // Transparent, not absent: the corners of the target take taps too.
        color: Colors.transparent,
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: CloudMedallion(
          size: size,
          shadows: shadows,
          glow: pressed ? 1 : 0,
          child: IconTheme.merge(
            data: IconThemeData(
              size: 22,
              color: onTap == null ? n.line : n.ink,
            ),
            child: icon,
          ),
        ),
      ),
    );
    final message = tooltip;
    return message == null ? button : Tooltip(message: message, child: button);
  }
}

/// The leading mark of a list row: [icon] at 24 dp on a 40 dp puff.
class NoorCloudIcon extends StatelessWidget {
  final Widget icon;

  const NoorCloudIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return CloudMedallion(
      size: 40,
      child: IconTheme.merge(
        data: IconThemeData(size: 24, color: context.noor.ink),
        child: icon,
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final Color back;
  final Color front;
  final Color lip;
  final Color shade;
  final Color glow;
  final List<BoxShadow> shadows;
  final double pixelRatio;

  _CloudPainter({
    required this.back,
    required this.front,
    required this.lip,
    required this.shade,
    required this.glow,
    required this.shadows,
    required this.pixelRatio,
  });

  // On a 100-unit box, shared by every marker on the page. Six puffs a row:
  // more turn to fringe at 30 dp.
  static const _step = math.pi / 3;

  static Offset _at(double angle, double orbit) =>
      Offset(50 + orbit * math.cos(angle), 50 + orbit * math.sin(angle));

  static Path _union(Iterable<(Offset, double)> circles) => circles.fold(
        Path(),
        (shape, c) => Path.combine(
          PathOperation.union,
          shape,
          Path()..addOval(Rect.fromCircle(center: c.$1, radius: c.$2)),
        ),
      );

  // A rim all the way round: on a `surface-raised` page the front row is white
  // on white, so its edge has to come from here.
  static final Path _backRow = _union([
    for (var i = 0; i < 6; i++) ...[
      (_at(i * _step, 32), 18.0),
      (_at(i * _step + _step / 2, 37), 13.0),
    ],
  ]);

  static final Path _frontRow = _union([
    (const Offset(50, 50), 33.0),
    for (var i = 0; i < 6; i++) (_at(i * _step, 31), 15.0),
  ]);

  static final Path _outline =
      Path.combine(PathOperation.union, _backRow, _frontRow);

  @override
  void paint(Canvas canvas, Size size) => BakedPaint.shared.paint(
        canvas,
        size,
        key: [back, front, lip, shade, glow, ...shadows],
        ratio: pixelRatio,
        // Shadows and glow spill past the box, to offset + 3 sigma (dp). The
        // glow is 5 dp, and the inner shade (1.5 dp, 3 sigma = 4.5) fits in 5.
        pad: shadows.fold(
          glow.a > 0 ? 15.0 : 5.0,
          (pad, s) => math.max(pad, s.offset.distance + 3 * s.blurSigma),
        ),
        draw: _draw,
      );

  void _draw(Canvas canvas, Size size) {
    final k = size.width / 100;
    canvas.scale(k);
    // The tokens are in dp, the canvas is in units.
    if (glow.a > 0) {
      canvas.drawPath(
        _outline,
        Paint()
          ..color = glow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 / k),
      );
    }
    for (final s in shadows) {
      canvas.drawPath(
        _outline.shift(s.offset / k),
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma / k),
      );
    }
    canvas.drawPath(_backRow, Paint()..color = back);
    canvas.drawPath(
      _frontRow.shift(Offset(0, -0.5 / k)),
      Paint()
        ..color = shade.withValues(alpha: shade.a * 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5 / k),
    );
    canvas.drawPath(_frontRow.shift(Offset(0, 1 / k)), Paint()..color = lip);
    canvas.drawPath(_frontRow, Paint()..color = front);
  }

  @override
  bool shouldRepaint(_CloudPainter old) =>
      old.back != back ||
      old.front != front ||
      old.lip != lip ||
      old.shade != shade ||
      old.glow != glow ||
      old.shadows != shadows ||
      old.pixelRatio != pixelRatio;
}

/// The `cloud-scroll` motif (`hilal-design-system/assets/Motifs`) as two
/// layers of cut paper, each row repeated at its own step across the card. The
/// front row is the card's frame paper, so ring and clouds read as one sheet.
/// The depth is soft shadow, not outline: the back row throws one onto the
/// ground behind it and the front row onto the back row, as stacked sheets do.
/// No curls: at this size they read as a smudge. [lip] is a crisp edge over the
/// back row, for Night, where the two rows are nearly the same colour. [shade]
/// is the shadow colour, `depthShadow`.
class CloudBankPainter extends CustomPainter {
  CloudBankPainter({
    required this.back,
    required this.front,
    required this.lip,
    required this.shade,
    required this.pixelRatio,
  });

  final Color back;
  final Color front;
  final Color? lip;
  final Color shade;
  final double pixelRatio;

  // (x, y, r) in the motif's viewBox, without the end puffs that close the
  // motif at its edges: here the rows run on.
  static const _backRow = [
    (28.0, 40.0, 18.0),
    (64.0, 32.0, 22.0),
    (104.0, 36.0, 20.0),
    (144.0, 30.0, 22.0),
    (184.0, 36.0, 20.0),
  ];
  static const _frontRow = [
    (44.0, 50.0, 18.0),
    (80.0, 52.0, 19.0),
    (118.0, 48.0, 21.0),
    (156.0, 52.0, 19.0),
    (192.0, 50.0, 18.0),
  ];
  static const _backStep = 190.0;
  static const _frontStep = 184.0;
  static const _motifCentre = 118.0;
  static const _top = 8.0; // The back row's highest point.
  static const _bottom = 62.0;
  static const _frontBase = 50.0; // Solid paper below this.

  /// Room above the back row for its shadow: give the painter this much more
  /// height than the clouds need, and the clouds keep their size.
  static const double headroom = 6;

  // Shadow blur in dp, and its strength against [shade]'s own alpha.
  static const _sigma = 3.0;
  static const _strength = 0.7;

  static Path _row(
    List<(double, double, double)> row,
    double step,
    int repeats,
  ) {
    final path = Path();
    for (var i = -repeats; i <= repeats; i++) {
      for (final (x, y, r) in row) {
        path.addOval(
            Rect.fromCircle(center: Offset(x + i * step, y - _top), radius: r));
      }
    }
    return path;
  }

  // Clipped to its box, so nothing spills and there is no padding.
  @override
  void paint(Canvas canvas, Size size) => BakedPaint.shared.paint(
        canvas,
        size,
        key: [CloudBankPainter, back, front, lip, shade],
        ratio: pixelRatio,
        draw: _draw,
      );

  void _draw(Canvas canvas, Size size) {
    final scale = (size.height - headroom) / (_bottom - _top);
    final repeats = (size.width / (_frontStep * scale)).ceil();
    final backRow = _row(_backRow, _backStep, repeats);
    final frontRow = _row(_frontRow, _frontStep, repeats)
      ..addRect(Rect.fromLTRB(
        _motifCentre - size.width / scale,
        _frontBase - _top,
        _motifCentre + size.width / scale,
        _bottom,
      ));
    // The sigma is in dp, the canvas in motif units.
    Paint shadow() => Paint()
      ..color = shade.withValues(alpha: shade.a * _strength)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma / scale);

    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(size.width / 2, headroom)
      ..scale(scale)
      ..translate(-_motifCentre, 0)
      ..drawPath(backRow.shift(const Offset(0, -2)), shadow())
      ..drawPath(backRow, Paint()..color = back)
      ..drawPath(frontRow.shift(const Offset(0, -1)), shadow());
    final lip = this.lip;
    if (lip != null) {
      canvas.drawPath(
          frontRow.shift(Offset(0, -1 / scale)), Paint()..color = lip);
    }
    canvas
      ..drawPath(frontRow, Paint()..color = front)
      ..restore();
  }

  @override
  bool shouldRepaint(CloudBankPainter old) =>
      old.back != back ||
      old.front != front ||
      old.lip != lip ||
      old.shade != shade ||
      old.pixelRatio != pixelRatio;
}

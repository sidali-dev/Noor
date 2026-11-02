import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// A pressed-in `surface-sunken` well: the fill, `shadow-inset` drawn inside
/// the edge, and optionally a 1 dp `line-strong` border (inside the box, so it
/// never changes layout). The segmented trough and sunken tiles share it. [BoxDecoration] cannot paint a shadow inside the box, hence the
/// painter. Pass [NoorRadius.pill] for a trough or a disc. [fill] and
/// [borderColor] replace the fill and edge for a panel pressed into raised
/// paper, such as the Mushaf page.
class NoorWell extends StatelessWidget {
  const NoorWell({
    super.key,
    required this.radius,
    this.border = false,
    this.fill,
    this.borderColor,
    this.child,
  });

  final double radius;
  final bool border;
  final Color? fill;
  final Color? borderColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return CustomPaint(
      painter: _WellPainter(
        radius: radius,
        fill: fill ?? n.surfaceSunken,
        shadows: n.inset,
        border: borderColor ?? (border ? n.lineStrong : null),
      ),
      child: child,
    );
  }
}

class _WellPainter extends CustomPainter {
  _WellPainter({
    required this.radius,
    required this.fill,
    required this.shadows,
    required this.border,
  });

  final double radius;
  final Color fill;
  final List<BoxShadow> shadows;
  final Color? border;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(math.min(radius, size.shortestSide / 2)),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);

    // The shadow is what is left of a big frame once the shifted well is cut
    // out of it, blurred and clipped back to the well.
    canvas.save();
    canvas.clipRRect(rrect);
    for (final s in shadows) {
      final frame = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rrect.outerRect.inflate(s.blurRadius * 3 + s.offset.distance))
        ..addRRect(rrect.shift(s.offset));
      canvas.drawPath(
        frame,
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }
    canvas.restore();

    final b = border;
    if (b != null) {
      canvas.drawRRect(
        rrect.deflate(0.5),
        Paint()
          ..color = b
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_WellPainter old) =>
      radius != old.radius ||
      fill != old.fill ||
      border != old.border ||
      shadows != old.shadows;
}

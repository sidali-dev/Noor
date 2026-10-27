import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

// Sizes below are drawn for a 300 dp dial (radius 150) and scaled by
// radius / 150, so the dial reads the same when it shrinks.
const double _designRadius = 150;

/// A compass with a green pointer on the qibla. The dial turns with the phone
/// so N stays north; the pointer is the one signal. Turn until it meets the
/// gold tick at the top.
///
/// [direction] is the phone's heading and [qiblah] is heading minus the qibla
/// bearing, both in degrees (`flutter_qiblah`), so `-qiblah` is where the
/// qibla lies on screen.
class QiblaCompass extends StatelessWidget {
  final double direction;
  final double qiblah;

  const QiblaCompass({
    super.key,
    required this.direction,
    required this.qiblah,
  });

  static double _rad(double deg) => deg * math.pi / 180.0;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Up to 300 dp, shrinking to whatever width and height are left.
        final double size = math.min(
          math.min(constraints.maxWidth, constraints.maxHeight),
          300.0,
        );
        final double s = size / 2 / _designRadius;

        return RepaintBoundary(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The dial is painted once; turning it only moves the layer.
                Transform.rotate(
                  angle: -_rad(direction),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(size, size),
                      painter: _DialPainter(
                        noor: n,
                        letters: NoorText.numeral(
                          context,
                          size: math.max(12.0, 16.0 * s),
                          color: n.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -_rad(qiblah),
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _PointerPainter(noor: n),
                  ),
                ),
                // Fixed gold tick: the top of the phone.
                Positioned(
                  top: 0,
                  child: Container(
                    width: 2.5,
                    height: 16 * s + 4,
                    decoration: BoxDecoration(
                      color: n.gold,
                      borderRadius: BorderRadius.circular(1.25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A four-point kite star: tips at [long] on the axes, base [half] wide.
Path _star(Offset c, double long, double half, double rot) {
  final p = Path();
  for (int i = 0; i < 4; i++) {
    final a = rot + i * math.pi / 2;
    Offset at(double r, double da) =>
        Offset(c.dx + r * math.sin(a + da), c.dy - r * math.cos(a + da));
    p
      ..moveTo(c.dx, c.dy)
      ..lineTo(at(half, -math.pi / 4).dx, at(half, -math.pi / 4).dy)
      ..lineTo(at(long, 0).dx, at(long, 0).dy)
      ..lineTo(at(half, math.pi / 4).dx, at(half, math.pi / 4).dy)
      ..close();
  }
  return p;
}

class _DialPainter extends CustomPainter {
  final NoorColors noor;
  final TextStyle letters;

  const _DialPainter({required this.noor, required this.letters});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double radius = size.width / 2;
    final double s = radius / _designRadius;
    final double ring = radius * 0.88;

    // Cream face with a hairline edge, then the primary ring.
    canvas.drawCircle(c, radius * 0.98, Paint()..color = noor.card);
    canvas.drawCircle(
      c,
      radius * 0.98,
      Paint()
        ..color = noor.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      c,
      ring,
      Paint()
        ..color = noor.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Short gold ticks every 15 degrees; the cardinals get a marker instead.
    final tick = Paint()
      ..color = noor.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final marker = Paint()..color = noor.gold;
    for (int i = 0; i < 24; i++) {
      final double a = i * math.pi / 12 - math.pi / 2;
      final Offset d = Offset(math.cos(a), math.sin(a));
      if (i % 6 == 0) {
        // Kite straddling the ring, apex inward.
        final Offset perp = Offset(-d.dy, d.dx);
        canvas.drawPath(
          Path()
            ..moveTo(
                c.dx + d.dx * (ring - 14 * s), c.dy + d.dy * (ring - 14 * s))
            ..lineTo(c.dx + d.dx * (ring + 6 * s) + perp.dx * 4 * s,
                c.dy + d.dy * (ring + 6 * s) + perp.dy * 4 * s)
            ..lineTo(c.dx + d.dx * (ring + 6 * s) - perp.dx * 4 * s,
                c.dy + d.dy * (ring + 6 * s) - perp.dy * 4 * s)
            ..close(),
          marker,
        );
      } else {
        canvas.drawLine(c + d * ring, c + d * (ring - 7 * s), tick);
      }
    }

    // N/E/S/W just inside the markers.
    const names = [('N', 0.0), ('E', 90.0), ('S', 180.0), ('W', 270.0)];
    final double letterRadius = ring - 32 * s;
    for (final (letter, deg) in names) {
      final double a = (deg - 90.0) * math.pi / 180.0;
      final tp = TextPainter(
        text: TextSpan(text: letter, style: letters),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        c +
            Offset(math.cos(a), math.sin(a)) * letterRadius -
            Offset(tp.width / 2, tp.height / 2),
      );
    }

    // 8-point rose, kept quiet so the pointer is the signal: soft gold
    // diagonals under pale cardinals.
    canvas.drawPath(
      _star(c, 60 * s, 11 * s, math.pi / 4),
      Paint()..color = noor.gold.withValues(alpha: 0.6),
    );
    canvas.drawPath(
      _star(c, 84 * s, 13 * s, 0),
      Paint()..color = Color.lerp(noor.card, noor.ink, 0.18)!,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.noor != noor || old.letters != letters;
}

/// Two-tone kite pointer and hub, drawn pointing at 12.
class _PointerPainter extends CustomPainter {
  final NoorColors noor;

  const _PointerPainter({required this.noor});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double s = size.width / 2 / _designRadius;

    Path half(double sign) => Path()
      ..moveTo(c.dx, c.dy - 86 * s)
      ..lineTo(c.dx + sign * 21 * s, c.dy)
      ..lineTo(c.dx, c.dy + 18 * s)
      ..close();

    canvas.drawPath(half(-1), Paint()..color = noor.primary);
    canvas.drawPath(
      half(1),
      Paint()..color = Color.lerp(noor.primary, noor.card, 0.4)!,
    );

    canvas.drawCircle(c, 9 * s, Paint()..color = noor.card);
    canvas.drawCircle(
      c,
      9 * s,
      Paint()
        ..color = noor.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(c, 2.5 * s, Paint()..color = noor.primary);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter old) => old.noor != noor;
}

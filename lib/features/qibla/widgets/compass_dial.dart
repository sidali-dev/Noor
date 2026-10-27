import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class CompassDialPainter extends CustomPainter {
  final BuildContext context;
  final NoorColors noor;

  CompassDialPainter({
    required this.context,
    required this.noor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    // Softer outer ring in line
    final double outerRingRadius = radius * 0.98;
    final Paint outerRingPaint = Paint()
      ..color = noor.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, outerRingRadius, outerRingPaint);

    // 1.5dp primary ring
    final double primaryRingRadius = radius * 0.88;
    final Paint primaryRingPaint = Paint()
      ..color = noor.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, primaryRingRadius, primaryRingPaint);

    // 60 ticks (major every 15 degrees, longer)
    final Paint tickMajorPaint = Paint()
      ..color = noor.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final Paint tickMinorPaint = Paint()
      ..color = noor.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final double compassDeg = i * 6.0;
      final double angleRad = (compassDeg - 90.0) * (math.pi / 180.0);
      final bool isMajor = (i * 6) % 15 == 0;

      final double tickLength = isMajor ? 12.0 : 6.0;
      final Paint tickPaint = isMajor ? tickMajorPaint : tickMinorPaint;

      final double outerX =
          center.dx + primaryRingRadius * math.cos(angleRad);
      final double outerY =
          center.dy + primaryRingRadius * math.sin(angleRad);

      final double innerX =
          center.dx + (primaryRingRadius - tickLength) * math.cos(angleRad);
      final double innerY =
          center.dy + (primaryRingRadius - tickLength) * math.sin(angleRad);

      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        tickPaint,
      );
    }

    // N/E/S/W in NoorText.numeral
    final TextStyle textStyle =
        NoorText.numeral(context, size: 16, color: noor.ink);
    const letters = [
      ('N', 0.0),
      ('E', 90.0),
      ('S', 180.0),
      ('W', 270.0),
    ];

    final double letterRadius = primaryRingRadius - 26.0;

    for (final (letter, deg) in letters) {
      final double angleRad = (deg - 90.0) * (math.pi / 180.0);
      final double lx = center.dx + letterRadius * math.cos(angleRad);
      final double ly = center.dy + letterRadius * math.sin(angleRad);

      final textSpan = TextSpan(text: letter, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(lx - textPainter.width / 2, ly - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CompassDialPainter oldDelegate) {
    return oldDelegate.noor != noor;
  }
}

class QiblaArrowPainter extends CustomPainter {
  final Color color;
  final double primaryRingRadius;

  const QiblaArrowPainter({
    required this.color,
    required this.primaryRingRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Arrowhead pointing towards 12 o'clock (north)
    final path = Path()
      ..moveTo(cx, cy - primaryRingRadius + 4)
      ..lineTo(cx + 12, cy - primaryRingRadius + 38)
      ..lineTo(cx, cy - primaryRingRadius + 31)
      ..lineTo(cx - 12, cy - primaryRingRadius + 38)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant QiblaArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.primaryRingRadius != primaryRingRadius;
  }
}

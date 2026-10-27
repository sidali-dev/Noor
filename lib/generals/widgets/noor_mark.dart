import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class NoorMark extends StatelessWidget {
  final double size;
  final Color? color;

  const NoorMark({
    super.key,
    this.size = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final markColor = color ?? context.noor.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NoorSunburstPainter(color: markColor),
      ),
    );
  }
}

class _NoorSunburstPainter extends CustomPainter {
  final Color color;

  _NoorSunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = math.max(1.5, radius * 0.12);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ringPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final innerRadius = radius * 0.35;
    canvas.drawCircle(center, innerRadius, ringPaint);

    const int rayCount = 12;
    const double angleStep = (2 * math.pi) / rayCount;
    final startDistance = innerRadius + strokeWidth * 0.8;

    for (int i = 0; i < rayCount; i++) {
      final angle = i * angleStep;
      final isLong = i % 2 == 0;
      final endDistance = isLong ? radius * 0.95 : radius * 0.68;

      final start = Offset(
        center.dx + math.cos(angle) * startDistance,
        center.dy + math.sin(angle) * startDistance,
      );
      final end = Offset(
        center.dx + math.cos(angle) * endDistance,
        center.dy + math.sin(angle) * endDistance,
      );

      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoorSunburstPainter oldDelegate) =>
      oldDelegate.color != color;
}

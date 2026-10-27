import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Future<void> showQiblaCalibrationSheet(BuildContext context) {
  return showNoorSheet<void>(
    context,
    title: S.of(context).calibrate_title,
    builder: (sheetContext) => const QiblaCalibrationContent(),
  );
}

class QiblaCalibrationContent extends StatefulWidget {
  const QiblaCalibrationContent({super.key});

  @override
  State<QiblaCalibrationContent> createState() =>
      _QiblaCalibrationContentState();
}

class _QiblaCalibrationContentState extends State<QiblaCalibrationContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final bool isReducedMotion = MediaQuery.of(context).disableAnimations;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Animated Figure-8 guide
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: NoorSpace.md),
            child: SizedBox(
              width: 180,
              height: 80,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(180, 80),
                    painter: LemniscatePainter(
                      progress:
                          isReducedMotion ? 0.0 : _animController.value,
                      isReducedMotion: isReducedMotion,
                      primaryColor: n.primary,
                      lineColor: n.line,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: NoorSpace.md),

        // Three calibration steps
        _buildStepRow(context, 1, S.of(context).calibrate_step_1),
        _buildStepRow(context, 2, S.of(context).calibrate_step_2),
        _buildStepRow(context, 3, S.of(context).calibrate_step_3),

        // Hairline divider
        Container(
          height: 1,
          color: n.line,
          margin: const EdgeInsets.symmetric(vertical: NoorSpace.lg),
        ),

        // Three tips with IconTiles
        _buildTipRow(
          context: context,
          icon: Iconsax.mobile,
          tint: NoorTint.sage,
          title: S.of(context).flat_phone_title,
          description: S.of(context).flat_phone_body,
        ),
        _buildTipRow(
          context: context,
          icon: Iconsax.radar,
          tint: NoorTint.amber,
          title: S.of(context).keep_from_magnetic_title,
          description: S.of(context).keep_from_magnetic_body,
        ),
        _buildTipRow(
          context: context,
          icon: Iconsax.location,
          tint: NoorTint.mint,
          title: S.of(context).enable_location_title,
          description: S.of(context).enable_location_body,
        ),

        const SizedBox(height: NoorSpace.sm),

        // Done button
        NoorButton(
          label: S.of(context).done,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildStepRow(BuildContext context, int number, String text) {
    final n = context.noor;
    return Padding(
      padding: const EdgeInsets.only(bottom: NoorSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: n.tintBg(NoorTint.sage),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: NoorText.numeral(context, size: 14, color: n.primary),
            ),
          ),
          const SizedBox(width: NoorSpace.md),
          Expanded(
            child: Text(
              text,
              style: NoorText.body(context).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow({
    required BuildContext context,
    required IconData icon,
    required NoorTint tint,
    required String title,
    required String description,
  }) {
    final n = context.noor;
    return Padding(
      padding: const EdgeInsets.only(bottom: NoorSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, tint: tint, size: 44),
          const SizedBox(width: NoorSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NoorText.rowTitle(context).copyWith(fontSize: 15),
                ),
                const SizedBox(height: NoorSpace.xs),
                Text(
                  description,
                  style: NoorText.meta(context).copyWith(
                    color: n.body.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LemniscatePainter extends CustomPainter {
  final double progress;
  final bool isReducedMotion;
  final Color primaryColor;
  final Color lineColor;

  const LemniscatePainter({
    required this.progress,
    required this.isReducedMotion,
    required this.primaryColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double a = size.width * 0.40;
    final double b = size.height * 0.45;

    // Draw the faint figure-8 path in line
    final path = Path();
    const int segments = 120;
    for (int i = 0; i <= segments; i++) {
      final double t = (i / segments) * 2 * math.pi;
      final double sinT = math.sin(t);
      final double denom = 1.0 + sinT * sinT;
      final double x = cx + a * math.cos(t) / denom;
      final double y = cy + b * (sinT * math.cos(t)) / denom;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final pathPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, pathPaint);

    // Draw tracing dot in primary
    final double currentT = isReducedMotion ? 0.0 : progress * 2 * math.pi;
    final double currentSin = math.sin(currentT);
    final double currentDenom = 1.0 + currentSin * currentSin;
    final double dotX = cx + a * math.cos(currentT) / currentDenom;
    final double dotY =
        cy + b * (currentSin * math.cos(currentT)) / currentDenom;

    // Soft halo
    final haloPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), 10.0, haloPaint);

    // Solid dot
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), 5.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant LemniscatePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isReducedMotion != isReducedMotion ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.lineColor != lineColor;
  }
}

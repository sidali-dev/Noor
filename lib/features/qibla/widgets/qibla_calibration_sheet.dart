import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generals/widgets/noor_well.dart';
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
        // The figure-8 guide, in a sunken well. It only shows the motion to
        // make; nothing here reads the sensor.
        NoorWell(
          radius: NoorRadius.md,
          child: Center(
            child: ExcludeSemantics(
              child: SizedBox(
                width: 144,
                height: 72,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(144, 72),
                      painter: LemniscatePainter(
                        progress: isReducedMotion ? 0.0 : _animController.value,
                        isReducedMotion: isReducedMotion,
                        primaryColor: n.brass,
                        lineColor: n.muted,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: NoorSpace.s4),

        // Three steps
        _buildStepRow(context, 1, S.of(context).calibrate_step_1),
        _buildStepRow(context, 2, S.of(context).calibrate_step_2),
        _buildStepRow(context, 3, S.of(context).calibrate_step_3),

        // Hairline divider
        Container(
          height: 1,
          color: n.line,
          margin: const EdgeInsets.symmetric(vertical: NoorSpace.s4),
        ),

        // Three tips
        _buildTipRow(
          context: context,
          title: S.of(context).flat_phone_title,
          description: S.of(context).flat_phone_body,
        ),
        _buildTipRow(
          context: context,
          title: S.of(context).keep_from_magnetic_title,
          description: S.of(context).keep_from_magnetic_body,
        ),
        _buildTipRow(
          context: context,
          title: S.of(context).enable_location_title,
          description: S.of(context).enable_location_body,
        ),

        const SizedBox(height: NoorSpace.s2),

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
      padding: const EdgeInsets.only(bottom: NoorSpace.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: NoorSpace.s5,
            child: Text(
              '$number',
              textDirection: TextDirection.ltr,
              style: NoorText.numeral(context, size: 16, color: n.muted),
            ),
          ),
          const SizedBox(width: NoorSpace.s3),
          Expanded(
            child: Text(
              text,
              style: NoorText.body(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NoorSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: NoorText.heading(context),
          ),
          const SizedBox(height: NoorSpace.s1),
          Text(
            description,
            style: NoorText.bodySm(context),
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

    // The figure-8 path, faint
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

    // The dot that traces it
    final double currentT = isReducedMotion ? 0.0 : progress * 2 * math.pi;
    final double currentSin = math.sin(currentT);
    final double currentDenom = 1.0 + currentSin * currentSin;
    final double dotX = cx + a * math.cos(currentT) / currentDenom;
    final double dotY =
        cy + b * (currentSin * math.cos(currentT)) / currentDenom;

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

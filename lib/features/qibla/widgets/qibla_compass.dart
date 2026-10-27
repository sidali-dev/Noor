import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/features/qibla/widgets/compass_dial.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class QiblaCompass extends StatefulWidget {
  final double? direction;
  final double? qiblah;
  final ValueChanged<QiblahDirection>? onDirectionChanged;

  const QiblaCompass({
    super.key,
    this.direction,
    this.qiblah,
    this.onDirectionChanged,
  });

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  StreamSubscription<QiblahDirection>? _subscription;
  double? _direction;
  double? _qiblah;

  @override
  void initState() {
    super.initState();
    _direction = widget.direction;
    _qiblah = widget.qiblah;

    // Subscribe to FlutterQiblah.qiblahStream only while mounted
    if (widget.direction == null || widget.qiblah == null) {
      _subscription = FlutterQiblah.qiblahStream.listen((data) {
        if (mounted) {
          setState(() {
            _direction = data.direction;
            _qiblah = data.qiblah;
          });
          widget.onDirectionChanged?.call(data);
        }
      });
    }
  }

  @override
  void didUpdateWidget(QiblaCompass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.direction != null) {
      _direction = widget.direction;
    }
    if (widget.qiblah != null) {
      _qiblah = widget.qiblah;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double direction = _direction ?? 0.0;
    final double qiblah = _qiblah ?? 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        // At least 280dp when space permits, scaling down on small screens (< 280dp).
        final double dialSize =
            (maxW >= 280.0 ? math.min(maxW, 300.0) : maxW).clamp(200.0, 320.0);
        final double primaryRingRadius = dialSize / 2 * 0.88;
        final double outerRingRadius = dialSize / 2 * 0.98;

        return RepaintBoundary(
          child: SizedBox(
            width: dialSize,
            height: dialSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dial with rings, 60 ticks, and N/E/S/W rotated by -direction radians
                Transform.rotate(
                  angle: (direction * (math.pi / 180.0) * -1.0),
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: Size(dialSize, dialSize),
                    painter: CompassDialPainter(
                      context: context,
                      noor: context.noor,
                    ),
                  ),
                ),

                // Primary arrow rotated by -qiblah radians
                Transform.rotate(
                  angle: (qiblah * (math.pi / 180.0) * -1.0),
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: Size(dialSize, dialSize),
                    painter: QiblaArrowPainter(
                      color: context.noor.primary,
                      primaryRingRadius: primaryRingRadius,
                    ),
                  ),
                ),

                // Center Kaaba glyph in a small round card
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.noor.card,
                    shape: BoxShape.circle,
                    boxShadow: noorShadow(context),
                    border: Border.all(
                      color: context.noor.line,
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    SImageString.kaaba,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      context.noor.ink,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                // Fixed gold heading tick at the top (device heading)
                Positioned(
                  top: dialSize / 2 - outerRingRadius - 4,
                  child: Container(
                    width: 2.5,
                    height: 18,
                    decoration: BoxDecoration(
                      color: context.noor.gold,
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

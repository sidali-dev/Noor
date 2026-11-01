import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_star_badge.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

// Hilal draws the dial in a 300 unit box shown at 280 dp. Shapes in box units
// scale by size / 300; the paper layers are in dp and scale by size / 280.
const double _box = 300;
const double _maxSize = 280;

/// A compass cut from paper: a raised disc around a sunken well, the dial
/// (72 ticks, a long one every 15 degrees, N/E/S/W in the display face) and a
/// `window` hub. The dial turns with the phone so N stays north; the brass
/// arrow and star are the one signal. Turn until the arrow meets the fixed
/// heading tick at the top: the rim ring then turns brass with a soft halo and
/// the phone vibrates once.
///
/// [direction] is the phone's heading and [qiblah] is heading minus the qibla
/// bearing, both in degrees (`flutter_qiblah`), so `-qiblah` is where the
/// qibla lies on screen.
class QiblaCompass extends StatefulWidget {
  final double direction;
  final double qiblah;

  const QiblaCompass({
    super.key,
    required this.direction,
    required this.qiblah,
  });

  // Hysteresis so magnetometer jitter can't flicker the glow or re-buzz.
  // ponytail: fixed thresholds; tune on hardware if the sensor is noisier.
  static const double alignOnDeg = 3;
  static const double alignOffDeg = 6;

  /// Degrees between the qibla and the top of the phone, 0..180.
  static double angleError(double qiblah) {
    final d = qiblah % 360;
    return math.min(d, 360 - d);
  }

  static bool nextAligned(bool was, double qiblah) =>
      angleError(qiblah) <= (was ? alignOffDeg : alignOnDeg);

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  bool _aligned = false;

  static double _rad(double deg) => deg * math.pi / 180.0;

  @override
  void initState() {
    super.initState();
    _track();
  }

  @override
  void didUpdateWidget(QiblaCompass old) {
    super.didUpdateWidget(old);
    _track();
  }

  void _track() {
    final next = QiblaCompass.nextAligned(_aligned, widget.qiblah);
    if (next && !_aligned) HapticFeedback.vibrate();
    _aligned = next;
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final direction = widget.direction;
    final qiblah = widget.qiblah;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Up to 280 dp, shrinking to whatever width and height are left.
        final double size = math.min(
          math.min(constraints.maxWidth, constraints.maxHeight),
          _maxSize,
        );
        final double k = size / _maxSize;
        final Size box = Size(size, size);
        final letter = NoorText.numeral(
          context,
          size: math.max(12.0, 16.0 * k),
          color: n.muted,
        );

        return Semantics(
          container: true,
          liveRegion: true,
          label: _aligned ? S.of(context).facing_qibla : null,
          child: RepaintBoundary(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // The disc and the well are circles, so they never turn.
                  SizedBox.square(
                    dimension: size,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: n.card,
                        shape: BoxShape.circle,
                        boxShadow: n.shadow3,
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: box,
                    painter: _WellPainter(
                      fill: n.surfaceSunken,
                      shadow: n.inset.first,
                      inset: 13 * k,
                    ),
                  ),
                  // The dial is painted once; turning it only moves the layer.
                  Transform.rotate(
                    angle: -_rad(direction),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: box,
                        painter: _DialPainter(
                          tick: n.lineStrong,
                          letter: letter,
                          north: letter.copyWith(color: n.danger),
                        ),
                      ),
                    ),
                  ),
                  // The rim ring: a `line` hairline that turns brass with a
                  // soft halo while aligned. A circle looks the same at any
                  // heading, so this layer never rotates.
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: _aligned ? 1.0 : 0.0),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => CustomPaint(
                      size: box,
                      painter: _RingPainter(
                        rest: n.line,
                        brass: n.brass,
                        t: t,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -_rad(qiblah),
                    child: CustomPaint(
                      size: box,
                      painter: _ArrowPainter(color: n.brass),
                    ),
                  ),
                  // Fixed heading tick: the top of the phone.
                  CustomPaint(size: box, painter: _HeadingPainter(n.ink)),
                  SizedBox.square(
                    dimension: 84 * k,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: n.window,
                        shape: BoxShape.circle,
                        boxShadow: n.shadow2,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: n.card, width: 4 * k),
                        ),
                        child: Center(
                          child: ExcludeSemantics(
                            child: NoorIcon(
                              NoorGlyph.moon,
                              color: n.onWindow,
                              size: 30 * k,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The well cut into the disc: `surface-sunken` with `shadow-inset`. A
/// [BoxDecoration] cannot paint a shadow inside its box, so the shadow of a
/// hole the shape of the well is drawn clipped to the well.
class _WellPainter extends CustomPainter {
  final Color fill;
  final BoxShadow shadow;
  final double inset;

  const _WellPainter({
    required this.fill,
    required this.shadow,
    required this.inset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2 - inset;
    canvas.drawCircle(c, r, Paint()..color = fill);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addOval(Rect.fromCircle(center: c + shadow.offset, radius: r)),
      Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WellPainter old) =>
      old.fill != fill || old.shadow != shadow || old.inset != inset;
}

/// 72 ticks with a long one every 15 degrees, and N/E/S/W inside them.
class _DialPainter extends CustomPainter {
  final Color tick;
  final TextStyle letter;
  final TextStyle north;

  const _DialPainter({
    required this.tick,
    required this.letter,
    required this.north,
  });

  static const int _ticks = 72;
  static const int _majorEvery = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double s = size.width / _box;
    final double k = size.width / _maxSize;

    for (int i = 0; i < _ticks; i++) {
      final bool major = i % _majorEvery == 0;
      final double a = i * 2 * math.pi / _ticks - math.pi / 2;
      final Offset d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + d * (major ? 128 : 122) * s,
        c + d * 116 * s,
        Paint()
          ..color = tick
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = (major ? 2 : 1) * k,
      );
    }

    const names = [('N', 0.0), ('E', 90.0), ('S', 180.0), ('W', 270.0)];
    for (final (name, deg) in names) {
      final double a = (deg - 90.0) * math.pi / 180.0;
      final tp = TextPainter(
        text: TextSpan(text: name, style: deg == 0 ? north : letter),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        c +
            Offset(math.cos(a), math.sin(a)) * 92 * s -
            Offset(tp.width / 2, tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.tick != tick || old.letter != letter || old.north != north;
}

/// The ring on the disc's rim. At [t] 0 a `line` hairline; at 1 a brass ring
/// with a soft blurred halo, the only blur on the screen.
class _RingPainter extends CustomPainter {
  final Color rest;
  final Color brass;
  final double t;

  const _RingPainter({
    required this.rest,
    required this.brass,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double k = size.width / _maxSize;
    // Mid-way along the 13 dp paper rim, so the halo stays on the disc.
    final double r = size.width / 2 - 6.5 * k;

    if (t > 0) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = brass.withValues(alpha: 0.5 * t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * k
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * k),
      );
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Color.lerp(rest, brass, t)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1 + t) * k,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.t != t || old.rest != rest || old.brass != brass;
}

/// The brass arrow to the qibla, drawn pointing at 12, with the brass star
/// where it meets the ticks.
class _ArrowPainter extends CustomPainter {
  final Color color;

  const _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double s = size.width / _box;
    final double k = size.width / _maxSize;

    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - 80 * s)
        ..lineTo(c.dx + 12 * s, c.dy)
        ..lineTo(c.dx, c.dy - 8 * s)
        ..lineTo(c.dx - 12 * s, c.dy)
        ..close(),
      Paint()..color = color,
    );
    canvas.drawPath(
      noorStarPath(Offset(c.dx, c.dy - 128 * s), 9 * k),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) => old.color != color;
}

/// The fixed ink tick at the top of the dial: where the phone points.
class _HeadingPainter extends CustomPainter {
  final Color color;

  const _HeadingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / _box;
    final double x = size.width / 2;

    canvas.drawPath(
      Path()
        ..moveTo(x, 6 * s)
        ..lineTo(x + 8 * s, 20 * s)
        ..lineTo(x - 8 * s, 20 * s)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _HeadingPainter old) => old.color != color;
}

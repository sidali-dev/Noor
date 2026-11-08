import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';

// Hilal draws the dial in a 300 unit box shown at 280 dp. Shapes in box units
// scale by size / 300; the paper layers are in dp and scale by size / 280.
const double _box = 300;
const double _maxSize = 280;

/// A compass cut from paper: a raised disc around a sunken well, the dial
/// (72 ticks, a long one every 15 degrees, N/E/S/W in the display face) and a
/// `window` hub holding a prayer rug. The dial turns with the phone so N stays
/// north; the brass arrow and the Kaaba on its tip are the one signal. Turn
/// until the Kaaba meets the fixed heading tick at the top: the rim then turns
/// `success` and the phone vibrates once.
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
                  // Facing the qibla turns the rim `success`: the state is also in
                  // the live-region label, so it is not colour alone.
                  AnimatedContainer(
                    duration: noorDuration(
                      context,
                      const Duration(milliseconds: 250),
                    ),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: _aligned
                          ? Color.lerp(n.card, n.success, 0.22)
                          : n.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _aligned ? n.success : Colors.transparent,
                        width: 4 * k,
                      ),
                      boxShadow: n.shadow3,
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
                  // The arrow turns with the qibla; the Kaaba on its tip is
                  // painted upright at the turned position.
                  CustomPaint(
                    size: box,
                    painter: _ArrowPainter(
                      angle: -_rad(qiblah),
                      brass: n.brass,
                      ground: n.surfaceSunken,
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
                            child: CustomPaint(
                              size: Size(30 * k, 42 * k),
                              painter: _RugPainter(
                                ground: n.windowRaised,
                                edge: n.onWindowMuted,
                                mihrab: n.onWindow,
                              ),
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

/// The Kaaba cut from paper in a 60 x 60 box: front, side and top faces in an
/// oblique view, a band round the top and the door.
List<Offset> _poly(List<(double, double)> p) =>
    [for (final (x, y) in p) Offset(x, y)];

final _kaabaFront = _poly([(0, 10), (38, 10), (38, 60), (0, 60)]);
final _kaabaSide = _poly([(38, 10), (60, 4), (60, 54), (38, 60)]);
final _kaabaTop = _poly([(0, 10), (22, 4), (60, 4), (38, 10)]);
final _kaabaBands = [
  _poly([(0, 18), (38, 18), (38, 24), (0, 24)]),
  _poly([(38, 18), (60, 12), (60, 18), (38, 24)]),
];
final _kaabaDoor = _poly([(24, 34), (32, 34), (32, 52), (24, 52)]);

/// A brass Kaaba of [size] centred on [at]: the faces are brass at three
/// strengths over [ground], and the bands and door are cut out to it.
void _paintKaaba(
  Canvas canvas,
  Offset at,
  double size,
  Color brass,
  Color ground,
) {
  void face(List<Offset> p, Color c) =>
      canvas.drawPath(Path()..addPolygon(p, true), Paint()..color = c);

  canvas
    ..save()
    ..translate(at.dx - size / 2, at.dy - size / 2)
    ..scale(size / 60);
  face(_kaabaFront, brass);
  face(_kaabaSide, Color.lerp(brass, ground, 0.3)!);
  face(_kaabaTop, Color.lerp(brass, ground, 0.5)!);
  for (final band in _kaabaBands) {
    face(band, ground);
  }
  face(_kaabaDoor, ground);
  canvas.restore();
}

/// The brass arrow to the qibla, turned [angle] radians from 12, with the
/// Kaaba on its tip where it meets the ticks. The Kaaba stays upright.
class _ArrowPainter extends CustomPainter {
  final double angle;
  final Color brass;
  final Color ground;

  const _ArrowPainter({
    required this.angle,
    required this.brass,
    required this.ground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double s = size.width / _box;
    final double k = size.width / _maxSize;

    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(angle)
      ..drawPath(
        Path()
          ..moveTo(0, -80 * s)
          ..lineTo(12 * s, 0)
          ..lineTo(0, -8 * s)
          ..lineTo(-12 * s, 0)
          ..close(),
        Paint()..color = brass,
      )
      ..restore();

    // Clear of the N/E/S/W letters inside and the heading tick outside.
    _paintKaaba(
      canvas,
      c + Offset(math.sin(angle), -math.cos(angle)) * 116 * s,
      24 * k,
      brass,
      ground,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.angle != angle || old.brass != brass || old.ground != ground;
}

/// A prayer rug on the hub, in 30 x 42 units: fringed ends, a border and a
/// pointed mihrab arch. `window` colours only, so it never competes with the
/// brass arrow.
class _RugPainter extends CustomPainter {
  final Color ground;
  final Color edge;
  final Color mihrab;

  const _RugPainter({
    required this.ground,
    required this.edge,
    required this.mihrab,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 30);
    final line = Paint()
      ..color = edge
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    for (var i = 0; i < 6; i++) {
      final x = 3 + i * 4.8;
      canvas
        ..drawLine(Offset(x, 0.5), Offset(x, 3), line)
        ..drawLine(Offset(x, 39), Offset(x, 41.5), line);
    }
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTRB(0, 3, 30, 39),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, Paint()..color = ground);
    canvas.drawRRect(body, line);
    line.strokeWidth = 0.8;
    canvas.drawRect(const Rect.fromLTRB(3, 6, 27, 36), line);

    canvas
      ..drawPath(
        Path()
          ..moveTo(8, 36)
          ..lineTo(8, 22)
          ..quadraticBezierTo(8, 14, 15, 9.5)
          ..quadraticBezierTo(22, 14, 22, 22)
          ..lineTo(22, 36)
          ..close(),
        Paint()..color = mihrab,
      )
      ..drawPath(
        Path()
          ..moveTo(11.5, 36)
          ..lineTo(11.5, 23.5)
          ..quadraticBezierTo(11.5, 18.5, 15, 16)
          ..quadraticBezierTo(18.5, 18.5, 18.5, 23.5)
          ..lineTo(18.5, 36)
          ..close(),
        Paint()..color = ground,
      );
  }

  @override
  bool shouldRepaint(covariant _RugPainter old) =>
      old.ground != ground || old.edge != edge || old.mihrab != mihrab;
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

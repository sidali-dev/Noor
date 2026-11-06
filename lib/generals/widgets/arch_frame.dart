import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Hilal ArchFrame: the layered paper shadow box (see
/// `hilal-design-system/components/ArchFrame`). One per screen, as the hero.
///
/// Three nested arches, a night window with stars, the arabesque band and a
/// lace border. [child] is centred in the sky; the moon and skyline are left out so
/// the child owns the window. The paper-shade wash and the shadows are the only
/// gradients, and they stay inside this widget.
class ArchFrame extends StatelessWidget {
  final double width;
  final Widget? child;

  /// Drives the star twinkle (0..1 over 8 s, 4 s each way). Null: still sky.
  final Animation<double>? twinkle;

  const ArchFrame({super.key, required this.width, this.child, this.twinkle});

  // The artwork is 240 wide (viewBox -20..220) by 266 tall.
  static const double aspect = 266 / 240;
  // Where the child's centre sits in the artwork, in viewBox units.
  static const double childY = 108;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return SizedBox(
      width: width,
      height: width * aspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _ArchPainter(n, twinkle),
            ),
          ),
          // In the artwork's units: over the arches' feet, on the ledge.
          Positioned(
            left: width * 20 / 240,
            right: width * 20 / 240,
            top: width * 188 / 240,
            child: NoorMotifBand(height: width * 40 / 240),
          ),
          if (child != null)
            Align(
              alignment: const Alignment(0, 2 * childY / 266 - 1),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  final NoorColors n;
  final Animation<double>? twinkle;

  _ArchPainter(this.n, this.twinkle) : super(repaint: twinkle);

  // Scallop lobes: x, y, radius.
  static const _lobes = [
    [22.0, 88.0, 30.0],
    [52.0, 48.0, 32.0],
    [100.0, 14.0, 34.0],
    [148.0, 48.0, 34.0],
    [178.0, 88.0, 32.0],
    [200.0, 130.0, 30.0],
  ];
  static const _insets = [0.0, 8.0, 15.0, 21.0];
  static const _stars = [
    [46.0, 58.0, 2.6],
    [154.0, 54.0, 2.2],
    [54.0, 156.0, 1.8],
    [148.0, 160.0, 2.2],
    [38.0, 130.0, 1.6],
    [164.0, 134.0, 1.8],
    [78.0, 44.0, 1.4],
    [124.0, 40.0, 1.4],
  ];

  static Path _arch(double d) {
    final sx = (200 - 2 * d) / 200;
    final y0 = 14 + d * 1.15;
    final sy = (240 - y0) / 226;
    double x(double v) => d + v * sx;
    double y(double v) => y0 + (v - 14) * sy;
    final p = Path()
      ..moveTo(x(0), 240)
      ..lineTo(x(0), y(130));
    for (final l in _lobes) {
      p.arcToPoint(Offset(x(l[0]), y(l[1])),
          radius: Radius.circular(l[2] * sx), clockwise: true);
    }
    return p
      ..lineTo(x(200), 240)
      ..close();
  }

  static Path _star(double x, double y, double r) => Path()
    ..moveTo(x, y - r * 2)
    ..lineTo(x + r * .55, y - r * .55)
    ..lineTo(x + r * 2, y)
    ..lineTo(x + r * .55, y + r * .55)
    ..lineTo(x, y + r * 2)
    ..lineTo(x - r * .55, y + r * .55)
    ..lineTo(x - r * 2, y)
    ..lineTo(x - r * .55, y - r * .55)
    ..close();

  static Path _lace() {
    final p = Path()
      ..moveTo(-16, 262)
      ..lineTo(-16, 246);
    var x = -16.0;
    for (; x < 216; x += 16) {
      p.relativeArcToPoint(const Offset(16, 0),
          radius: const Radius.circular(8), clockwise: true);
    }
    p
      ..lineTo(x, 262)
      ..close();
    for (x = -16; x < 216; x += 16) {
      p.addOval(Rect.fromCircle(center: Offset(x + 8, 246.5), radius: 2.4));
      if (x + 16 < 216) {
        p.addOval(Rect.fromCircle(center: Offset(x + 16, 255), radius: 1.2));
      }
    }
    return p..fillType = PathFillType.evenOdd;
  }

  /// A paper layer's shadow: the same shape dropped [dy] and blurred.
  void _cast(Canvas c, Path p, double dy, double sigma) => c.drawPath(
        p.shift(Offset(0, dy)),
        Paint()
          ..color = n.depthShadow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 240;
    canvas
      ..scale(s)
      ..translate(20, 0);

    // The whole box lands on the page with shadow-3.
    final outline = Path.combine(
      PathOperation.union,
      _arch(0),
      Path()..addRect(const Rect.fromLTRB(-16, 200, 216, 262)),
    );
    for (final sh in n.shadow3) {
      canvas.drawPath(
        outline.shift(Offset(sh.offset.dx / s, sh.offset.dy / s)),
        Paint()
          ..color = sh.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sh.blurSigma / s),
      );
    }

    // Night window and the stars seen through it.
    final window = _arch(_insets.last);
    canvas.drawPath(window, Paint()..color = n.window);
    canvas.save();
    canvas.clipPath(window);
    final t = twinkle?.value;
    for (var i = 0; i < _stars.length; i++) {
      canvas.drawPath(
        _star(_stars[i][0], _stars[i][1], _stars[i][2]),
        Paint()
          ..color = n.onWindow
              .withValues(alpha: t == null ? 1.0 : noorTwinkleOpacity(t, i)),
      );
    }
    canvas.restore();

    // Paper frames, furthest back first; each casts onto the one behind.
    final wash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [n.card, n.paperShade],
      ).createShader(const Rect.fromLTWH(0, 10, 200, 240));
    for (var i = _insets.length - 2; i >= 0; i--) {
      final ring = Path.combine(
          PathOperation.difference, _arch(_insets[i]), _arch(_insets[i + 1]));
      i == 0 ? _cast(canvas, ring, 2.6, 2.4) : _cast(canvas, ring, 1.4, 1.3);
      canvas.drawPath(ring, wash);
    }

    // A ledge hiding the base; the arabesque band stands on it, over this paint.
    final ledge = Path()..addRect(const Rect.fromLTWH(-2, 214, 204, 28));
    _cast(canvas, ledge, 1.4, 1.3);
    canvas.drawPath(ledge, Paint()..color = n.card);

    // Lace border, the front-most layer.
    final lace = _lace();
    _cast(canvas, lace, 2.6, 2.4);
    canvas.drawPath(lace, Paint()..color = n.card);
  }

  @override
  bool shouldRepaint(_ArchPainter old) => old.n != n;
}

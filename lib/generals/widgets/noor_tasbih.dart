import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The counter: the ornament holding a tasbih, the count at its centre. Each one
/// said turns a bead from pearl to `ink`; the bead about to be said is the
/// screen's one brass note. The string starts at the large bead at the foot and
/// runs the way the language reads.
class TasbihCloud extends StatelessWidget {
  /// The whole count: a dhikr's repetitions, the pages of the Mushaf.
  final int total;

  /// How many so far.
  final int said;

  /// The centre: the count left, the page, or a word once done.
  final String label;
  final bool done;

  /// Null where it only shows the count, and once done.
  final VoidCallback? onTap;

  final double size;

  /// False where the screen's brass is spent elsewhere, as on the Mushaf page:
  /// the next bead is then `ink`.
  final bool accent;

  const TasbihCloud({
    super.key,
    required this.total,
    required this.said,
    required this.label,
    this.done = false,
    this.onTap,
    this.size = standardSize,
    this.accent = true,
  });

  static const double standardSize = 132;

  // The beads run on the ornament's raised ring, round the disc.
  static const double _face = 0.56;

  // A count of 100 would be a smudge of beads: past a full 33-bead string the
  // said part is a thread instead.
  static const int _maxBeads = 33;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    return NoorPressable(
      onPressed: onTap,
      radius: NoorRadius.pill,
      builder: (context, pressed) => CloudMedallion(
        size: size,
        face: _face,
        glow: pressed ? 1 : 0,
        child: SizedBox.square(
          dimension: size * _face,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: said.toDouble()),
            duration: noorDuration(context, const Duration(milliseconds: 220)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => CustomPaint(
              painter: _BeadsPainter(
                total: total,
                said: value,
                maxBeads: _maxBeads,
                mirrored: Directionality.of(context) == TextDirection.rtl,
                pearl: n.card,
                edge: n.lineStrong,
                thread: n.line,
                ink: n.ink,
                brass: accent ? n.brass : n.ink,
              ),
              child: child,
            ),
            child: Padding(
              padding: EdgeInsets.all(NoorSpace.s3 * size / standardSize),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textDirection: done ? null : TextDirection.ltr,
                    style: NoorText.numeral(
                      context,
                      size: 34 * size / standardSize,
                      color: done ? n.success : n.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The counter between its previous and next buttons, each on the foot of the
/// ornament. Chevrons follow [Directionality]: in the RTL Mushaf, left is next.
class NoorCounterRow extends StatelessWidget {
  final TasbihCloud counter;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const NoorCounterRow({
    super.key,
    required this.counter,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        // Close around the counter, however wide the window.
        constraints: BoxConstraints(
          maxWidth: counter.size + 2 * NoorCloudButton.size + 4 * NoorSpace.s4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NoorCloudButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: previousTooltip,
              onTap: onPrevious,
            ),
            counter,
            NoorCloudButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: nextTooltip,
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _BeadsPainter extends CustomPainter {
  final int total;
  final double said;
  final int maxBeads;
  final bool mirrored;
  final Color pearl;
  final Color edge;
  final Color thread;
  final Color ink;
  final Color brass;

  _BeadsPainter({
    required this.total,
    required this.said,
    required this.maxBeads,
    required this.mirrored,
    required this.pearl,
    required this.edge,
    required this.thread,
    required this.ink,
    required this.brass,
  });

  static const double _startAngle = math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Drawn for the 132 dp ornament; a smaller one keeps the proportions.
    final k = size.width / (TasbihCloud.standardSize * TasbihCloud._face);
    final radius = size.width / 2 - 4 * k;
    final direction = mirrored ? -1.0 : 1.0;
    Offset at(double angle) =>
        c + Offset(math.cos(angle), math.sin(angle)) * radius;

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = thread;
    canvas.drawCircle(c, radius, line);

    if (total > maxBeads) {
      final sweep = direction * 2 * math.pi * said / total;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: radius),
        _startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = ink,
      );
      if (said < total) {
        canvas.drawCircle(
          at(_startAngle + sweep),
          4 * k,
          Paint()..color = brass,
        );
      }
    } else {
      // One slot more than the beads: the large bead at the foot takes it.
      final step = 2 * math.pi / (total + 1);
      final r = (step * radius * 0.34).clamp(2.4, 5.0);
      for (var k = 0; k < total; k++) {
        // 1 or more: said. 0: the bead now. Below: still to say. The fractions
        // are the bead changing hands while the count animates.
        final d = said - k;
        final fill = d >= 1
            ? ink
            : d >= 0
                ? Color.lerp(brass, ink, d)!
                : Color.lerp(pearl, brass, (1 + d).clamp(0.0, 1.0))!;
        final p = at(_startAngle + direction * step * (k + 1));
        canvas.drawCircle(p, r, Paint()..color = fill);
        if (d < 0) {
          canvas.drawCircle(
            p,
            r - 0.5,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = Color.lerp(edge, brass, (1 + d).clamp(0.0, 1.0))!,
          );
        }
      }
    }

    // The large bead and its tassel, which make the ring a tasbih.
    final foot = at(_startAngle);
    final tassel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = edge;
    for (final dx in const [-3.0, 0.0, 3.0]) {
      canvas.drawLine(foot, foot + Offset(dx, 13) * k, tassel);
    }
    canvas.drawCircle(foot, 4.5 * k, Paint()..color = pearl);
    canvas.drawCircle(
      foot,
      4 * k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = edge,
    );
  }

  @override
  bool shouldRepaint(_BeadsPainter old) =>
      old.total != total ||
      old.said != said ||
      old.mirrored != mirrored ||
      old.pearl != pearl ||
      old.edge != edge ||
      old.thread != thread ||
      old.ink != ink ||
      old.brass != brass;
}

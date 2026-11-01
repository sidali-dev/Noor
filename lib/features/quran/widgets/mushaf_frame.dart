import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_star_badge.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

/// The Mushaf page, as one sheet of paper on the ground: `surface-raised`, a
/// thin brass hairline frame with an eight-point star in each corner, and at
/// the foot a hairline rule with a star and the page number. [child] fills the
/// page between the corner stars and the foot. Every ornament lives in the
/// margin, none touches the text.
class MushafFrame extends StatelessWidget {
  final Widget child;
  final int pageNumber;

  const MushafFrame({super.key, required this.child, required this.pageNumber});

  static const double _inset = NoorSpace.s3;
  static const double _cornerStar = 14;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    Widget corner({double? top, double? bottom, double? left, double? right}) =>
        Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: IgnorePointer(
            child: MushafStar(size: _cornerStar, color: n.brass),
          ),
        );

    const near = _inset + NoorSpace.s2;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(NoorRadius.md),
        boxShadow: n.shadow2,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(_inset),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(NoorRadius.sm),
                    border: Border.all(color: n.brass),
                  ),
                ),
              ),
            ),
          ),
          corner(top: near, left: near),
          corner(top: near, right: near),
          corner(bottom: near, left: near),
          corner(bottom: near, right: near),
          Positioned(
            bottom: near,
            left: near + _cornerStar + NoorSpace.s2,
            right: near + _cornerStar + NoorSpace.s2,
            child: IgnorePointer(child: _Foot(pageNumber: pageNumber)),
          ),
          // The text scrolls between the corner stars and the foot, so it
          // never passes under an ornament.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                top: NoorSpace.s7,
                bottom: NoorSpace.s8,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// A hairline `line` rule broken by a brass star, the page number under it.
class _Foot extends StatelessWidget {
  final int pageNumber;

  const _Foot({required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final rule = Expanded(
      child: SizedBox(height: 1, child: ColoredBox(color: n.line)),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            rule,
            const SizedBox(width: NoorSpace.s2),
            MushafStar(size: 14, color: n.brass, filled: true),
            const SizedBox(width: NoorSpace.s2),
            rule,
          ],
        ),
        const SizedBox(height: NoorSpace.s1),
        Text(
          '$pageNumber',
          textDirection: TextDirection.ltr,
          style: NoorText.numeral(context, size: 14, color: n.muted),
        ),
      ],
    );
  }
}

/// The eight-point star ornament, [filled] or a hairline outline.
class MushafStar extends StatelessWidget {
  final double size;
  final Color color;
  final bool filled;

  const MushafStar({
    super.key,
    required this.size,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StarPainter(color, filled),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  final bool filled;

  _StarPainter(this.color, this.filled);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      noorStarPath(size.center(Offset.zero), size.width * 7 / 24),
      Paint()
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.color != color || old.filled != filled;
}

/// A `window` pill in a brass hairline ring, with a small star either side of
/// the surah name, where a surah starts.
class SurahCartouche extends StatelessWidget {
  final String name;

  const SurahCartouche({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final star = MushafStar(size: 12, color: n.brass);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: n.card,
            borderRadius: BorderRadius.circular(NoorRadius.pill),
            border: Border.all(color: n.brass),
            boxShadow: n.shadow2,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: n.window,
                borderRadius: BorderRadius.circular(NoorRadius.pill),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NoorSpace.s4,
                    vertical: NoorSpace.s1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      star,
                      const SizedBox(width: NoorSpace.s3),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            name,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: n.onWindow,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: NoorSpace.s3),
                      star,
                    ],
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

/// The ayah end marker, set inline in the verse text: a brass star outline
/// with the verse number in Arabic-Indic digits. Sized from the text
/// scale so it keeps its place on a 44 dp line at any setting.
class AyahMarker extends StatelessWidget {
  final int number;

  const AyahMarker(this.number, {super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final size = MediaQuery.textScalerOf(context).scale(30);

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StarPainter(n.brass, false),
        child: Center(
          child: SizedBox(
            width: size * 0.6,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                // The package prefixes the end-of-ayah sign; the digits are
                // its own numbering. Amiri, because the Quran font colours
                // its digits.
                quran.getVerseEndSymbol(number).substring(1),
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  color: n.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

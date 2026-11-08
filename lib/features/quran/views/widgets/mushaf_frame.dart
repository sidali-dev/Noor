import 'package:flutter/material.dart';
import 'package:noor/core/widgets/noor_cartouche.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_star_badge.dart';
import 'package:noor/core/widgets/noor_well.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:quran/quran.dart' as quran;

/// The Mushaf page: one sheet of raised paper with a panel pressed into it,
/// edged by a `line` hairline, a star in each corner and at the foot a hairline
/// rule with a star and the page number. [child] fills the page between the
/// corner stars and the foot. Every ornament lives in the margin, none touches
/// the text. Brass is kept for [bookmarked], a ribbon hanging from the top edge.
class MushafFrame extends StatelessWidget {
  final Widget child;
  final int pageNumber;
  final bool bookmarked;

  /// False while the pager is up: it sits where the foot does, and repeats it.
  final bool footVisible;

  const MushafFrame({
    super.key,
    required this.child,
    required this.pageNumber,
    this.bookmarked = false,
    this.footVisible = true,
  });

  static const double _inset = NoorSpace.s2;
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
            child: NoorIcon(NoorGlyph.star, size: _cornerStar, color: n.line),
          ),
        );

    const near = _inset + NoorSpace.s2;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(NoorRadius.lg),
        boxShadow: n.shadow2,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(_inset),
              child: IgnorePointer(
                child: NoorWell(
                  radius: NoorRadius.md,
                  fill: n.card,
                  borderColor: n.line,
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
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: footVisible ? 1 : 0,
                duration:
                    noorDuration(context, const Duration(milliseconds: 200)),
                curve: Curves.easeOutCubic,
                child: _Foot(pageNumber: pageNumber),
              ),
            ),
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
          if (bookmarked)
            PositionedDirectional(
              top: 0,
              end: NoorSpace.s7,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(14, 30),
                  painter: _RibbonPainter(n.brass, n.depthShadow),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A hairline `line` rule broken by a star, the page number under it.
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
            MushafStar(size: 14, color: n.line),
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

/// The eight-point star ornament.
class MushafStar extends StatelessWidget {
  final double size;
  final Color color;

  const MushafStar({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StarPainter(color),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      noorStarPath(size.center(Offset.zero), size.width * 7 / 24),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

/// The bookmark as a strip of brass paper hanging from the page's top edge.
class _RibbonPainter extends CustomPainter {
  final Color color;
  final Color shadow;

  _RibbonPainter(this.color, this.shadow);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - size.width / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0, 1)),
      Paint()
        ..color = shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) =>
      old.color != color || old.shadow != shadow;
}

/// The [NoorCartouche] where a surah starts, its name in Amiri.
class SurahCartouche extends StatelessWidget {
  final String name;

  const SurahCartouche({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return NoorCartouche.title(
      name,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: context.noor.onWindow,
      ),
    );
  }
}

/// The ayah end marker, set inline in the verse text: a [CloudMedallion] with
/// the verse number in Arabic-Indic digits. Sized from the text scale so it
/// keeps its place on a 44 dp line at any setting.
class AyahMarker extends StatelessWidget {
  final int number;

  const AyahMarker(this.number, {super.key});

  @override
  Widget build(BuildContext context) {
    return CloudMedallion(
      plain: true,
      // Wider would rewrap the verses and push a full page past its foot.
      size: MediaQuery.textScalerOf(context).scale(30),
      child: Text(
        // The package prefixes the end-of-ayah sign; the digits are its own
        // numbering. Amiri, because the Quran font colours its digits.
        quran.getVerseEndSymbol(number).substring(1),
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1,
          color: context.noor.ink,
        ),
      ),
    );
  }
}

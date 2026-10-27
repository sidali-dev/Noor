import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The ornamental Mushaf page: gold hairline, radius 16, on the mushaf colour,
/// a corner flourish mirrored into each corner and a divider at the foot.
/// [child] fills the frame; keep its padding clear of the 32dp corners.
class MushafFrame extends StatelessWidget {
  final Widget child;

  const MushafFrame({super.key, required this.child});

  static const double _corner = 32;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final gold = ColorFilter.mode(n.gold, BlendMode.srcIn);

    Widget corner({
      required bool flipX,
      required bool flipY,
    }) =>
        Positioned(
          top: flipY ? null : 0,
          bottom: flipY ? 0 : null,
          left: flipX ? null : 0,
          right: flipX ? 0 : null,
          child: IgnorePointer(
            child: Transform.flip(
              flipX: flipX,
              flipY: flipY,
              child: SvgPicture.asset(
                NoorArt.pageCorner,
                width: _corner,
                height: _corner,
                colorFilter: gold,
              ),
            ),
          ),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: n.mushaf,
        borderRadius: BorderRadius.circular(NoorRadius.tile),
        border: Border.all(color: n.gold.withValues(alpha: 0.7)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          corner(flipX: false, flipY: false),
          corner(flipX: true, flipY: false),
          corner(flipX: false, flipY: true),
          corner(flipX: true, flipY: true),
          Positioned(
            bottom: NoorSpace.sm,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: SvgPicture.asset(
                  NoorArt.divider,
                  width: 96,
                  height: 16,
                  colorFilter: gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gold cartouche carrying the surah name where a surah starts.
class SurahCartouche extends StatelessWidget {
  final String name;

  const SurahCartouche({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: AspectRatio(
          aspectRatio: 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: SvgPicture(
                  SvgAssetLoader(
                    NoorArt.surahCartouche,
                    colorMapper: _Recolor(n.mushaf, n.gold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: n.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cartouche SVG has a cream fill and a gold stroke; map both to tokens.
class _Recolor implements ColorMapper {
  final Color fill;
  final Color stroke;

  const _Recolor(this.fill, this.stroke);

  static const _cream = 0xFFFBF6E8;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) =>
      color.toARGB32() == _cream ? fill : stroke;

  // Equal mappers share one cached parse of the SVG.
  @override
  bool operator ==(Object other) =>
      other is _Recolor && other.fill == fill && other.stroke == stroke;

  @override
  int get hashCode => Object.hash(fill, stroke);
}

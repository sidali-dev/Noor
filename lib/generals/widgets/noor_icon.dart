import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The 12 line icons Hilal ships (plus [bellOff]) (`hilal-design-system/components/bundle.js`).
/// Anything else in the app is iconsax Linear, used only where Hilal has no
/// equivalent; never a filled icon.
enum NoorGlyph {
  home(['M4 11.5 12 5l8 6.5', 'M6 10v9h12v-9', 'M10 19v-5h4v5']),
  compass([
    'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18z',
    'M15.5 8.5 13.4 13.4 8.5 15.5 10.6 10.6z',
  ]),
  calendar(['M5 6h14v14H5z', 'M5 10h14', 'M9 3.5v4M15 3.5v4']),
  bookmark(['M7 4h10v16l-5-3.5L7 20z']),
  settings([
    'M12 9a3 3 0 1 0 0 6a3 3 0 1 0 0-6z',
    'M12 3v2.5M12 18.5V21M3 12h2.5M18.5 12H21M5.6 5.6l1.8 1.8M16.6 16.6l1.8 1.8M5.6 18.4l1.8-1.8M16.6 7.4l1.8-1.8',
  ]),
  moon(['M15.5 4.2a8 8 0 1 0 4.3 11.3A6.5 6.5 0 0 1 15.5 4.2z']),
  star(['M12 3l2 5.2 5.2 2-5.2 2L12 17.5l-2-5.3-5.2-2 5.2-2z']),
  search(
      ['M10.5 4a6.5 6.5 0 1 0 0 13a6.5 6.5 0 1 0 0-13z', 'M15.5 15.5 20 20']),
  bell(['M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15z', 'M10 20.5a2 2 0 0 0 4 0']),
  // Hilal has no off state for the bell: the bell with a stroke through it.
  bellOff([
    'M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15z',
    'M10 20.5a2 2 0 0 0 4 0',
    'M4 4l16 16'
  ]),
  check(['M5 12.5 10 17 19 7']),
  alert(['M12 4 21 19.5H3z', 'M12 10v4.5', 'M12 17h.01']),
  plus(['M12 5v14M5 12h14']);

  const NoorGlyph(this.paths);

  final List<String> paths;
}

/// A Hilal line icon: 24 px grid, 1.6 stroke, round caps and joins. Colour and
/// size come from the ambient [IconTheme] (so it works inside `NoorButton`)
/// unless given; the default colour is `ink`.
///
/// Decorative unless [semanticLabel] is set; an icon-only button labels itself
/// with its tooltip.
class NoorIcon extends StatelessWidget {
  final NoorGlyph glyph;
  final double? size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  const NoorIcon(
    this.glyph, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 1.6,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    final fg = color ?? theme.color ?? context.noor.ink;

    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'fill="none" stroke="#000" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">'
        '${[for (final d in glyph.paths) '<path d="$d"/>'].join()}</svg>';

    // Like [Icon]: a square that centres the glyph, so a tight parent (a disc,
    // a 56 dp box) cannot stretch it.
    return SizedBox.square(
      dimension: side,
      child: Center(
        child: SvgPicture.string(
          svg,
          width: side,
          height: side,
          colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
          semanticsLabel: semanticLabel,
          excludeFromSemantics: semanticLabel == null,
        ),
      ),
    );
  }
}

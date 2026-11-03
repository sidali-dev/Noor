import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The line icons Hilal ships (`hilal-design-system/components/bundle.js`, plus
/// [sun] and [location] from the Prayer times mock's bundle, and [bellOff] and
/// [minus]). Anything else in the app is iconsax Linear, used only where Hilal
/// has no equivalent; never a filled icon.
enum NoorGlyph {
  home(['M4 11.5 12 5l8 6.5', 'M6 10v9h12v-9', 'M10 19v-5h4v5']),
  compass([
    'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18z',
    'M15.5 8.5 13.4 13.4 8.5 15.5 10.6 10.6z',
  ]),
  calendar(['M5 6h14v14H5z', 'M5 10h14', 'M9 3.5v4M15 3.5v4']),
  bookmark(['M7 4h10v16l-5-3.5L7 20z']),
  reset(['M4 12a8 8 0 1 0 2.3-5.6L4 8.5', 'M4 4v4.5h4.5']),
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
  plus(['M12 5v14M5 12h14']),
  minus(['M5 12h14']),
  sun([
    'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8z',
    'M12 2.5v2M12 19.5v2M4.5 12h-2M21.5 12h-2M5.6 5.6l1.4 1.4M17 17l1.4 1.4M5.6 18.4 7 17M17 7l1.4-1.4',
  ]),
  location([
    'M12 21s-6.5-6-6.5-11a6.5 6.5 0 0 1 13 0c0 5-6.5 11-6.5 11z',
    'M12 7.5a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5z',
  ]),
  // The Athkar categories, drawn to the same grid and stroke.
  sunrise([
    'M3.5 19h17',
    'M7.5 19a4.5 4.5 0 0 1 9 0',
    'M12 3v6M9.5 5.5 12 3l2.5 2.5',
    'M4.8 12.8l1.6 1.6M19.2 12.8l-1.6 1.6',
  ]),
  sunset([
    'M3.5 19h17',
    'M7.5 19a4.5 4.5 0 0 1 9 0',
    'M12 3v6M9.5 6.5 12 9l2.5-2.5',
    'M4.8 12.8l1.6 1.6M19.2 12.8l-1.6 1.6',
  ]),
  prayerRug([
    'M6.5 5.5h11v13h-11z',
    'M9.5 14.5V11a2.5 2.5 0 0 1 5 0v3.5',
    'M8.5 3v2.5M12 3v2.5M15.5 3v2.5M8.5 18.5V21M12 18.5V21M15.5 18.5V21',
  ]),
  prayerDone([
    'M6.5 5.5h11v13h-11z',
    'M9.5 12l2 2 3-3.8',
    'M8.5 3v2.5M12 3v2.5M15.5 3v2.5M8.5 18.5V21M12 18.5V21M15.5 18.5V21',
  ]),
  mosque([
    'M3.5 20.5h17',
    'M6 20.5V13.5a6 6 0 0 1 12 0v7',
    'M12 7.5V4',
    'M10 20.5V17a2 2 0 0 1 4 0v3.5',
  ]),
  alarm([
    'M12 6.5a7 7 0 1 0 0 14a7 7 0 1 0 0-14z',
    'M12 10v3.7l2.2 1.5',
    'M4.5 6.5 7 4M19.5 6.5 17 4',
  ]),
  tasbih([
    'M17.00 10.50a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0zM15.10 15.10a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0zM10.50 17.00a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0zM5.90 15.10a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0zM4.00 10.50a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0zM5.90 5.90a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0zM10.50 4.00a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0zM15.10 5.90a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0-3 0z',
    'M12 18.5v3M10.2 21.5 12 18.5l1.8 3',
  ]),
  saying([
    'M4.5 5h15v11H10.5l-3.5 3.5V16H4.5z',
    'M12 7.6l.9 2 2 .9-2 .9-.9 2-.9-2-2-.9 2-.9z',
  ]),
  book([
    'M12 7C10 5.5 7.5 5 4 5v13.5c3.5 0 6 .5 8 2 2-1.5 4.5-2 8-2V5c-3.5 0-6 .5-8 2z',
    'M12 7v13.5',
  ]),
  scroll([
    'M8 3.5h10a2.5 2.5 0 0 1 2.5 2.5v1.5H16',
    'M8 3.5A2.5 2.5 0 0 0 5.5 6v11',
    'M16 6v12a2.5 2.5 0 0 1-2.5 2.5H6A2.5 2.5 0 0 1 3.5 18v-1h9.5v1a2.5 2.5 0 0 0 2.5 2.5',
    'M9 8.5h4M9 12h4',
  ]),
  minaret([
    'M9 20.5V10l3-6 3 6v10.5',
    'M6.5 20.5h11',
    'M9 13h6',
    'M18 7.5a5 5 0 0 1 0 6M6 7.5a5 5 0 0 0 0 6',
  ]),
  list(['M9 6h11M9 12h11M9 18h11', 'M4.5 6h.01M4.5 12h.01M4.5 18h.01']),
  drop([
    'M12 3.5s6.5 6.4 6.5 11a6.5 6.5 0 0 1-13 0c0-4.6 6.5-11 6.5-11z',
    'M9 15a3 3 0 0 0 2.6 2.8',
  ]),
  door([
    'M7 20.5V3.5h10v17',
    'M4 20.5h16',
    'M14 12.5h.01',
  ]),
  meal([
    'M5.5 3.5V8a2.75 2.75 0 0 0 5.5 0V3.5',
    'M8.25 3.5v17',
    'M18 3.5c-2.2 1.3-3.5 4-3.5 7.5v2.5H18',
    'M18 3.5v17',
  ]),
  kaaba([
    'M12 3.5l8 3.5v10l-8 3.5-8-3.5V7z',
    'M4 7l8 3.5L20 7',
    'M12 10.5v10',
    'M4 10.5l8 3.5 8-3.5',
  ]);

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

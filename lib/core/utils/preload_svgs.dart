import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/core/widgets/noor_hero.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_sky.dart';
import 'package:noor/core/constants/assets/images.dart';

/// Warms [svg.cache] with every SVG the shell draws, so a tab's first frame is
/// not blank: flutter_svg answers a cached load with a SynchronousFuture, but
/// only under the key the widget itself uses (same loader, same bundle).
///
/// A failed load is swallowed; that SVG just loads late, like before.
Future<void> preloadSvgs(BuildContext context) {
  final loaders = <BytesLoader>[
    for (final path in const [
      AppImages.kaaba,
      AppImages.navQuran,
      AppImages.navMosque,
      AppImages.navTasbih,
      NoorArt.separator,
    ])
      SvgAssetLoader(path),
    for (final glyph in NoorGlyph.values)
      SvgStringLoader(noorIconSvg(glyph, noorIconStroke)),
    SvgStringLoader(noorSeparatorSvg(false)),
    SvgStringLoader(noorSeparatorSvg(true)),
  ];
  // The cache is LRU: past its size the oldest entries would silently go.
  assert(loaders.length < svg.cache.maximumSize,
      '${loaders.length} SVGs do not fit in svg.cache');

  return Future.wait([
    for (final l in loaders) _warm(l, context),
    _warmHeroArt(context),
  ]);
}

// A baked image not yet decoded paints blank, which a tab's first frame would
// show. Both themes are decoded, so a theme switch finds its art ready instead
// of decoding it in the switch's frame. shortcut: decodes at the full 4 px per
// unit; size them to the screen if memory bites.
Future<void> _warmHeroArt(BuildContext context) {
  return Future.wait([
    for (final path in [
      noorSkyNow.value.asset,
      for (final variant in const ['paper', 'night']) ...[
        NoorArt.band(variant),
        NoorArt.ornament(variant),
        NoorArt.disc(variant),
        for (final hero in NoorArt.heroes) NoorArt.frame(hero, variant),
      ],
    ])
      precacheImage(AssetImage(path), context, onError: (_, __) {}),
  ]);
}

// async: a cache hit is a SynchronousFuture and, in debug, a bad SVG throws
// right here instead of failing the future; this turns both into a real Future.
Future<void> _warm(BytesLoader loader, BuildContext context) async {
  try {
    await loader.loadBytes(context);
  } catch (_) {}
}

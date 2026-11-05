import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_sky.dart';
import 'package:noor/utils/constants/image_strings.dart';

/// Warms [svg.cache] with every SVG the shell draws, so a tab's first frame is
/// not blank: flutter_svg answers a cached load with a SynchronousFuture, but
/// only under the key the widget itself uses (same loader, same bundle).
///
/// A failed load is swallowed; that SVG just loads late, like before.
Future<void> preloadSvgs(BuildContext context) {
  final loaders = <BytesLoader>[
    SvgAssetLoader(noorSkyNow.value.asset),
    for (final path in const [
      NoorArt.objectMosque,
      NoorArt.objectQuran,
      NoorArt.objectSabha,
      NoorArt.qiblaKaaba,
      SImageString.kaaba,
      SImageString.navQuran,
      SImageString.navMosque,
      SImageString.navTasbih,
    ])
      SvgAssetLoader(path),
    for (final glyph in NoorGlyph.values)
      SvgStringLoader(noorIconSvg(glyph, noorIconStroke)),
  ];
  // The cache is LRU: past its size the oldest entries would silently go.
  assert(loaders.length < svg.cache.maximumSize,
      '${loaders.length} SVGs do not fit in svg.cache');

  return Future.wait([for (final l in loaders) _warm(l, context)]);
}

// async: a cache hit is a SynchronousFuture and, in debug, a bad SVG throws
// right here instead of failing the future; this turns both into a real Future.
Future<void> _warm(BytesLoader loader, BuildContext context) async {
  try {
    await loader.loadBytes(context);
  } catch (_) {}
}

import 'package:flutter/material.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/theme/app_theme.dart';

/// The Faith mark alone (never the lockup), Paper on light and Night on dark.
///
/// The emblem of the owner's logo renders, cut out of its app-icon tile and
/// baked with its depth shadow by `tool/splash_art.py`: the arch shield with
/// its night window, the bolt, the crescent and the two wings. [size] is the
/// height of the raster, whose canvas already holds the clear space and the
/// shadow below; the aspect ratio is fixed. Never recoloured, stretched or
/// outlined, and below 32 the shadow and stars turn to noise.
class NoorMark extends StatelessWidget {
  final double size;

  const NoorMark({super.key, this.size = 40});

  /// Raster width over height (544 x 660 at 3x).
  static const double aspect = 544 / 660;

  @override
  Widget build(BuildContext context) {
    final dark = context.noor.isDark;
    return Image.asset(
      dark ? NoorArt.markNight : NoorArt.markPaper,
      height: size,
      width: size * aspect,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

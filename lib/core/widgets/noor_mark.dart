import 'package:flutter/material.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/theme/app_theme.dart';

/// The Faith mark alone (never the lockup), Paper on light and Night on dark.
///
/// Rasters rendered from `docs/design-system/assets/Logos/faith-mark-*.svg`
/// (flutter_svg drops the SVG drop-shadow filters). [size] is the artwork's
/// height; the aspect ratio is fixed and the clear space the brand asks for
/// (the crescent's width) is added around it, so the footprint is larger.
/// Never recoloured, stretched or outlined, and below 32 the shadows and
/// stars turn to noise.
class NoorMark extends StatelessWidget {
  final double size;

  const NoorMark({super.key, this.size = 40});

  // Artwork viewBox is 540 x 660; the crescent is 68 wide. The viewBox already
  // keeps 35 of clear space around the artwork, so 33 more reaches 68.
  static const double _aspect = 540 / 660;
  static const double _pad = 33 / 660;

  @override
  Widget build(BuildContext context) {
    final dark = context.noor.isDark;
    final pad = size * _pad;
    return Padding(
      padding: EdgeInsets.all(pad),
      child: Image.asset(
        dark ? NoorArt.markNight : NoorArt.markPaper,
        height: size,
        width: size * _aspect,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}

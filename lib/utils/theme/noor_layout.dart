import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Size classes for the Hilal screens. Hilal's mobile margins are `s4`; past a
/// phone the content stays in one centred column instead of stretching, and on
/// a short (landscape) screen the hero collapses. Driven by the window, never
/// by the device model, so a foldable, a split screen and a tablet all fit.
///
/// The column width and the short-height cut-off are layout limits, not
/// tokens; tokens.json has no entry for either.
abstract final class NoorLayout {
  /// The widest the content column grows: a comfortable reading width.
  static const double columnWidth = 600;

  /// Below this window height (a landscape phone) the hero drops its art.
  static const double shortHeight = 480;

  /// Space between the window edge and the column: 0 on a phone, half the
  /// spare width on a wide window, and never less than a notch or a cutout.
  static double margin(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final spare = (MediaQuery.sizeOf(context).width - columnWidth) / 2;
    return math.max(math.max(0.0, spare), math.max(pad.left, pad.right));
  }

  /// [margin] plus the `s4` page margin: the inset of cards and lists.
  static double gutter(BuildContext context) => margin(context) + NoorSpace.s4;

  static bool isShort(BuildContext context) =>
      MediaQuery.sizeOf(context).height < shortHeight;
}

/// Holds [child] to the content column, margins included. It keeps the
/// child's constraints tight, so it is safe around a full-height page.
class NoorColumn extends StatelessWidget {
  final Widget child;

  const NoorColumn({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: NoorLayout.margin(context)),
        child: child,
      );
}

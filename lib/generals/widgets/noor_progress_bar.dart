import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// A 4 dp `line` track with a `brass` fill that grows from the start, and a
/// small numeral percentage after it unless [showPercent] is false. Brass is
/// the one warm note, so keep to a single bar per region. [onWindow] is for a
/// bar on a `window` ground: a moon-white track and a brass-tinted fill that
/// stay readable on it in both themes.
class NoorProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final bool showPercent;

  /// The percentage under the bar, at its end, instead of after it: for a bar
  /// in a narrow slot such as a list row's trailing edge.
  final bool percentBelow;

  final bool onWindow;

  const NoorProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.showPercent = true,
    this.percentBelow = false,
    this.onWindow = false,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final clamped = value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(height / 2);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final pct = '${(clamped * 100).round()}%';
    final track = onWindow ? n.onWindow.withValues(alpha: 0.2) : n.line;
    final fill = onWindow ? (n.isDark ? n.brass : n.brassSoft) : n.brass;

    final bar = ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        width: double.infinity,
        color: track,
        child: TweenAnimationBuilder<double>(
          duration: duration,
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: clamped),
          builder: (context, animatedValue, child) {
            // Any progress at all shows as at least a round dot, so the first
            // pages of 604 are not a sliver.
            return LayoutBuilder(
              builder: (context, track) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  width: animatedValue <= 0
                      ? 0
                      : math.max(height, track.maxWidth * animatedValue),
                  height: height,
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(color: fill, borderRadius: radius),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    return Semantics(
      value: pct,
      excludeSemantics: true,
      child: showPercent && percentBelow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                bar,
                const SizedBox(height: NoorSpace.s1),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    pct,
                    style: NoorText.numeral(context, size: 12, color: n.muted),
                  ),
                ),
              ],
            )
          : showPercent
              ? Row(
                  children: [
                    Expanded(child: bar),
                    const SizedBox(width: NoorSpace.s2),
                    // A fixed slot keeps every bar the same length, whether it
                    // reads 0% or 100%.
                    SizedBox(
                      width: 40,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            pct,
                            style: NoorText.numeral(
                              context,
                              size: 12,
                              color: n.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : bar,
    );
  }
}

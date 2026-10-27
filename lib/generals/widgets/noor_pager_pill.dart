import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Previous / centre / next control. Chevrons follow the ambient
/// [Directionality]: previous sits at the start, next at the end.
class NoorPagerPill extends StatelessWidget {
  final String label;
  final VoidCallback? onCenterTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;

  /// false: one primary pill with the chevrons inside. true: a primary centre
  /// pill between two gold-tint circles.
  final bool split;

  const NoorPagerPill({
    super.key,
    required this.label,
    this.onCenterTap,
    this.onPrevious,
    this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    this.split = false,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final onFill = split
        ? Color.lerp(n.gold, n.ink, 0.5)! // gold on its tint is only ~2:1
        : n.onPrimary;

    Widget chevron({
      required bool isPrevious,
      required VoidCallback? onTap,
      required String tooltip,
    }) {
      final left = isPrevious != rtl;
      return IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Icon(
          left ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          size: 26,
        ),
        color: onFill,
        disabledColor: onFill.withValues(alpha: 0.4),
      );
    }

    final prev = chevron(
        isPrevious: true, onTap: onPrevious, tooltip: previousTooltip);
    final next =
        chevron(isPrevious: false, onTap: onNext, tooltip: nextTooltip);

    final centre = InkWell(
      onTap: onCenterTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: split ? 72 : 0, minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NoorSpace.lg),
          // Shrink-wraps in the split pill, fills the Expanded in the other.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: NoorText.numeral(context, size: 20, color: n.onPrimary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );

    if (!split) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 296),
          child: Material(
            color: n.primary,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [prev, Expanded(child: centre), next],
            ),
          ),
        ),
      );
    }

    Widget circle(Widget button) => Material(
          color: n.tintBg(NoorTint.amber),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: button,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        circle(prev),
        const SizedBox(width: NoorSpace.md),
        Flexible(
          child: Material(
            color: n.primary,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: centre,
          ),
        ),
        const SizedBox(width: NoorSpace.md),
        circle(next),
      ],
    );
  }
}

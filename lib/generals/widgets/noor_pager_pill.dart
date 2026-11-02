import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Previous / centre / next control. Chevrons follow the ambient
/// [Directionality]: previous sits at the start, next at the end (so in the
/// RTL Mushaf, left is the next page).
class NoorPagerPill extends StatelessWidget {
  final String label;
  final VoidCallback? onCenterTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;

  /// false: one `window` pill with the chevrons inside. true: a `window`
  /// centre pill between two raised paper circles.
  final bool split;

  /// Size of the display-face [label]: a page number reads at 20, a count
  /// that is tapped all evening reads bigger.
  final double labelSize;

  const NoorPagerPill({
    super.key,
    required this.label,
    this.onCenterTap,
    this.onPrevious,
    this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    this.split = false,
    this.labelSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final enabledColor = split ? n.ink : n.onWindow;
    final disabledColor = split ? n.muted : n.onWindowMuted;

    Widget chevron({
      required bool isPrevious,
      required VoidCallback? onTap,
      required String tooltip,
    }) {
      return Tooltip(
        message: tooltip,
        child: NoorPressable(
          onPressed: onTap,
          radius: 24,
          builder: (context, pressed) => DecoratedBox(
            decoration: BoxDecoration(
              color: split ? n.card : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: split ? (pressed ? n.shadow1 : n.shadow2) : const [],
            ),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                // Both mirror themselves in RTL (matchTextDirection).
                isPrevious
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 26,
                color: onTap == null ? disabledColor : enabledColor,
              ),
            ),
          ),
        ),
      );
    }

    final prev =
        chevron(isPrevious: true, onTap: onPrevious, tooltip: previousTooltip);
    final next =
        chevron(isPrevious: false, onTap: onNext, tooltip: nextTooltip);

    // Shrink-wraps in the split pill, fills the Expanded in the other.
    final labelText = ConstrainedBox(
      constraints: BoxConstraints(minWidth: split ? 72 : 0, minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NoorSpace.s4),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style:
                  NoorText.numeral(context, size: labelSize, color: n.onWindow),
            ),
          ),
        ),
      ),
    );
    final centre = onCenterTap == null
        ? labelText
        : NoorPressable(
            onPressed: onCenterTap,
            radius: NoorRadius.pill,
            builder: (context, pressed) => labelText,
          );

    const pill = BorderRadius.all(Radius.circular(NoorRadius.pill));

    if (!split) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 296),
          child: DecoratedBox(
            decoration: BoxDecoration(color: n.window, borderRadius: pill),
            child: Row(
              children: [prev, Expanded(child: centre), next],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        prev,
        const SizedBox(width: NoorSpace.s3),
        Flexible(
          // A window is never bare: a paper ring lifts it (a `line` seam too in
          // Night, where the window's own edge cannot be seen).
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: n.card,
              borderRadius: pill,
              border: n.isDark ? Border.all(color: n.line) : null,
              boxShadow: n.shadow3,
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(color: n.window, borderRadius: pill),
                child: centre,
              ),
            ),
          ),
        ),
        const SizedBox(width: NoorSpace.s3),
        next,
      ],
    );
  }
}

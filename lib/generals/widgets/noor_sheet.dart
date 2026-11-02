import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

// The front-most paper layer is `surface-raised` with `shadow-3` and no border.
// Sheets round the top corners to `radius-lg` ([NoorSheet]); dialogs round all
// four ([NoorDialogCard]). Neither clips, so the shadow is never cut.

/// Shows a bottom sheet: a handle, an optional [title] in the display face
/// (`titleOf` is re-evaluated when the locale changes), then [builder]'s
/// content. It drags down to dismiss.
Future<T?> showNoorSheet<T>(
  BuildContext context, {
  String? title,
  String Function(BuildContext)? titleOf,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Centred on a wide window rather than stretched across it.
    constraints: const BoxConstraints(maxWidth: NoorLayout.columnWidth),
    backgroundColor: Colors.transparent,
    elevation: 0,
    // The sheet rises onto the page: ease-out, no overshoot, instant under
    // Reduce Motion.
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: kNoorSettleDuration,
            reverseDuration: kNoorSettleDuration,
            curve: kNoorSettleCurve,
            reverseCurve: Curves.easeIn,
          ),
    builder: (sheetContext) => NoorSheet(
      title: titleOf?.call(sheetContext) ?? title,
      child: builder(sheetContext),
    ),
  );
}

/// Cut as a [NoorPagePanel]: the clouds stay below the scrolling content, and
/// give way to the keyboard.
class NoorSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  const NoorSheet({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final mq = MediaQuery.of(context);
    final keyboard = mq.viewInsets.bottom > 0;

    final titleStyle = NoorText.title(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(NoorRadius.lg),
        ),
        boxShadow: n.shadow3,
      ),
      // Ink (ripples, tile fills) paints on the nearest Material, which is
      // transparent here, so give the card its own above the paper.
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.only(bottom: mq.padding.bottom),
          child: NoorPagePanel(
            cloudHeight: keyboard ? 0 : NoorPagePanel.standardCloudHeight,
            contentTop: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: NoorSpace.s3),
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: n.lineStrong,
                      borderRadius: BorderRadius.circular(NoorRadius.pill),
                    ),
                    child: const SizedBox(width: 36, height: 4),
                  ),
                ),
                // Past the corner stars, title or not.
                SizedBox(height: title == null ? NoorSpace.s4 : NoorSpace.s3),
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: NoorSpace.s6,
                      vertical: NoorSpace.s2,
                    ),
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.3,
                      child: Text(
                        title!,
                        style: titleStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: NoorSpace.s1),
                ],
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsetsDirectional.only(
                      start: NoorSpace.s5,
                      end: NoorSpace.s5,
                      top: NoorSpace.s1,
                      bottom: mq.viewInsets.bottom + NoorSpace.s4,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The paper card a dialog sits on: `surface-raised`, `shadow-3`, `radius-lg`.
/// Put it inside a transparent, zero-elevation [Dialog].
class NoorDialogCard extends StatelessWidget {
  final Widget child;

  const NoorDialogCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(NoorRadius.lg),
        boxShadow: n.shadow3,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.all(NoorSpace.s5),
          child: child,
        ),
      ),
    );
  }
}

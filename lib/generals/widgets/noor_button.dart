import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// `primary` is a piece of night sky (moon-white in Night), `tonal` is raised
/// paper, `outline` is paper-less with a visible control edge, `danger` is the
/// destructive fill. [onWindow] and [ghostOnWindow] are for a `window` ground
/// (moon-white fill, or bare moon-white label) in both themes.
enum NoorButtonVariant {
  primary,
  tonal,
  outline,
  danger,
  onWindow,
  ghostOnWindow,
}

/// Hilal Button. Pressing moves it 1 dp down and drops it to `shadow-1`;
/// disabled is 45% opacity with no shadow; keyboard focus draws a 2 dp brass
/// ring (see [NoorPressable]). At least 48 dp tall, the label wraps rather
/// than clips at large text scales.
class NoorButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final NoorButtonVariant variant;

  /// [NoorRadius.md]; [NoorRadius.pill] for the adhan screen's buttons.
  final double radius;

  const NoorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = NoorButtonVariant.primary,
    this.radius = NoorRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final borderRadius = BorderRadius.circular(radius);

    Color bg;
    Color fg;
    BoxBorder? border;
    var raised = true;

    switch (variant) {
      case NoorButtonVariant.primary:
        // Night inverts so the primary stays the strongest shape on screen.
        bg = n.isDark ? n.onWindow : n.window;
        fg = n.isDark ? n.window : n.onWindow;
        break;
      case NoorButtonVariant.tonal:
        bg = n.card;
        fg = n.ink;
        break;
      case NoorButtonVariant.danger:
        bg = n.danger;
        fg = n.isDark ? n.paper : n.card;
        break;
      case NoorButtonVariant.onWindow:
        bg = n.onWindow;
        fg = n.window;
        break;
      case NoorButtonVariant.ghostOnWindow:
        bg = Colors.transparent;
        fg = n.onWindow;
        raised = false;
        break;
      case NoorButtonVariant.outline:
        bg = Colors.transparent;
        fg = n.ink;
        border = Border.all(color: n.lineStrong);
        raised = false;
        break;
    }

    final isEnabled = onPressed != null;

    final labelStyle = NoorText.label(context);

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: 20),
            child: icon!,
          ),
          const SizedBox(width: NoorSpace.s2),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle.copyWith(color: fg),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: NoorPressable(
        onPressed: onPressed,
        radius: radius,
        builder: (context, pressed) => AnimatedContainer(
          duration: noorDuration(context, kNoorPressDuration),
          curve: Curves.ease,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: NoorSpace.s4,
            vertical: NoorSpace.s3,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: borderRadius,
            border: border,
            boxShadow: !isEnabled || !raised
                ? const []
                : pressed
                    ? n.shadow1
                    : n.shadow2,
          ),
          child: content,
        ),
      ),
    );
  }
}

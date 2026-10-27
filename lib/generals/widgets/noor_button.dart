import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

enum NoorButtonVariant {
  primary,
  tonal,
  outline,
  danger,
}

class NoorButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final NoorButtonVariant variant;

  const NoorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = NoorButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final borderRadius = BorderRadius.circular(NoorRadius.tile);

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case NoorButtonVariant.primary:
        bg = n.primary;
        fg = n.onPrimary;
        border = null;
        break;
      case NoorButtonVariant.tonal:
        bg = n.tintBg(NoorTint.sage);
        fg = n.isDark ? n.ink : n.primary;
        border = null;
        break;
      case NoorButtonVariant.danger:
        bg = n.danger;
        fg = Colors.white;
        border = null;
        break;
      case NoorButtonVariant.outline:
        bg = Colors.transparent;
        fg = n.ink;
        border = Border.all(color: n.line, width: 1.5);
        break;
    }

    final isEnabled = onPressed != null;

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: fg, size: 20),
            child: icon!,
          ),
          const SizedBox(width: NoorSpace.sm),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plex',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
          border: border,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}

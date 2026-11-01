import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// A raised paper chip: `surface-raised`, `radius-md`, `shadow-2` (`shadow-1`
/// while pressed). The optional [icon] sits at the start, the label fills the
/// middle and [trailing] (a chevron that mirrors in RTL by default) ends it.
/// At least 48 dp tall; it fills the width it is given.
class NoorPill extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NoorPill({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    // chevron_right is declared matchTextDirection, so it flips in RTL.
    final defaultTrailing = Icon(
      Icons.chevron_right_rounded,
      color: n.muted,
      size: 22,
    );

    final labelStyle = NoorText.label(context);

    return NoorPressable(
      onPressed: onTap,
      radius: NoorRadius.md,
      builder: (context, pressed) => AnimatedContainer(
        duration: kNoorPressDuration,
        curve: Curves.ease,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: NoorSpace.s4,
          vertical: NoorSpace.s2,
        ),
        decoration: BoxDecoration(
          color: n.card,
          borderRadius: BorderRadius.circular(NoorRadius.md),
          boxShadow: pressed ? n.shadow1 : n.shadow2,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: n.ink, size: 20),
                child: icon!,
              ),
              const SizedBox(width: NoorSpace.s3),
            ],
            Expanded(
              child: Text(
                label,
                style: labelStyle.copyWith(color: n.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: NoorSpace.s2),
            trailing ?? defaultTrailing,
          ],
        ),
      ),
    );
  }
}

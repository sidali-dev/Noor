import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

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
    final borderRadius = BorderRadius.circular(NoorRadius.tile);

    final defaultTrailing = Icon(
      Icons.chevron_right_rounded, // mirrors in RTL
      color: n.muted,
      size: 20,
    );

    return Container(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: borderRadius,
        boxShadow: noorShadow(context),
        border: n.isDark ? Border.all(color: n.line, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NoorSpace.lg,
                vertical: NoorSpace.sm + 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: NoorSpace.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: NoorText.body(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: n.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: NoorSpace.sm),
                  trailing ?? defaultTrailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

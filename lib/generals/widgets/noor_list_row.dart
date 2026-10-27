import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class NoorListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? meta;
  final Widget? trailing;
  final VoidCallback? onTap;

  const NoorListRow({
    super.key,
    this.leading,
    required this.title,
    this.meta,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final borderRadius = BorderRadius.circular(NoorRadius.tile);

    final defaultTrailing = Icon(
      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      color: n.muted,
      size: 22,
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
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NoorSpace.lg,
                vertical: NoorSpace.md,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: NoorSpace.lg),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: NoorText.rowTitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (meta != null && meta!.isNotEmpty) ...[
                          const SizedBox(height: NoorSpace.xs),
                          Text(
                            meta!,
                            style: NoorText.meta(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: NoorSpace.md),
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

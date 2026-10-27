import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class NoorCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const NoorCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final borderRadius = BorderRadius.circular(NoorRadius.card);

    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : Padding(padding: const EdgeInsets.all(NoorSpace.lg), child: child);

    return Container(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: borderRadius,
        boxShadow: noorShadow(context),
        border: n.isDark ? Border.all(color: n.line, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                borderRadius: borderRadius,
                onTap: onTap,
                child: content,
              )
            : content,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final dynamic icon;

  const EmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    Widget? visual;
    if (icon != null) {
      if (icon is Widget) {
        visual = icon as Widget;
      } else if (icon is IconData) {
        visual = Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: n.tintBg(NoorTint.sage),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon as IconData,
            size: 32,
            color: n.tintFg(NoorTint.sage),
          ),
        );
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NoorSpace.xxl,
          vertical: NoorSpace.xxxl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (visual != null) ...[
              visual,
              const SizedBox(height: NoorSpace.xl),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: NoorText.body(context).copyWith(
                color: n.muted,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: NoorSpace.xxl),
              NoorButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: NoorButtonVariant.tonal,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

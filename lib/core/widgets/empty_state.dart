import 'package:flutter/material.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';

/// One icon or motif, one sentence, and at most one button. The icon is a bare
/// `ink-muted` line glyph, so an empty state never adds a brass note to a
/// screen. An error sets [danger]: the glyph turns `danger`, and the sentence
/// always says what went wrong, so colour never stands alone.
class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool danger;

  /// A [NoorGlyph] or [IconData] (drawn at 32 dp) or any widget (shown as is).
  final dynamic icon;

  const EmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.danger = false,
    this.icon,
  });

  /// A search or filter that matched nothing.
  factory EmptyState.noResults(BuildContext context) => EmptyState(
        message: S.of(context).no_results,
        icon: NoorGlyph.search,
      );

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final color = danger ? n.danger : n.muted;
    final Widget? visual = switch (icon) {
      final Widget w => w,
      final NoorGlyph g =>
        ExcludeSemantics(child: NoorIcon(g, size: NoorSpace.s6, color: color)),
      final IconData d =>
        ExcludeSemantics(child: Icon(d, size: NoorSpace.s6, color: color)),
      _ => null,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NoorSpace.s5,
          vertical: NoorSpace.s6,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (visual != null) ...[
                visual,
                const SizedBox(height: NoorSpace.s4),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: NoorText.body(context),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: NoorSpace.s5),
                NoorButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

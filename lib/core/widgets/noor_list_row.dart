import 'package:flutter/material.dart';
import 'package:noor/core/widgets/noor_pressable.dart';
import 'package:noor/core/theme/app_theme.dart';

/// One row of a [NoorListGroup]: [leading], a `heading` title with an optional
/// `body-sm` meta line, then [trailing] (a chevron that mirrors in RTL by
/// default). The row itself is bare, so it only ever sits on a paper layer.
class NoorListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? meta;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Replaces the `heading` title style, for a name set in another script.
  final TextStyle? titleStyle;

  /// Lines the title may take before it is cut: one, unless the names are long
  /// and the list must stay readable at a large text scale.
  final int titleMaxLines;

  const NoorListRow({
    super.key,
    this.leading,
    required this.title,
    this.meta,
    this.trailing,
    this.onTap,
    this.titleStyle,
    this.titleMaxLines = 1,
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

    return NoorPressable(
      onPressed: onTap,
      radius: 0,
      builder: (context, pressed) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: NoorSpace.s4,
            vertical: NoorSpace.s3,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: NoorSpace.s4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: titleStyle ?? NoorText.heading(context),
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meta != null && meta!.isNotEmpty) ...[
                      const SizedBox(height: NoorSpace.s1),
                      Text(
                        meta!,
                        style: NoorText.bodySm(context),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: NoorSpace.s3),
              trailing ?? defaultTrailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// One grouped paper list: `surface-raised`, `radius-md`, `shadow-1`, with a
/// hairline `line` between rows unless [divided] is off, for rows that carry
/// their own wells. Not clipped, so a row's focus ring is not cut at the
/// group's edge.
class NoorListGroup extends StatelessWidget {
  final List<Widget> children;
  final bool divided;

  const NoorListGroup({super.key, required this.children, this.divided = true});

  static BoxDecoration _decoration(NoorColors n) => BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(NoorRadius.md),
        boxShadow: n.shadow1,
      );

  /// The same group as a lazy sliver, for a long list: the decoration wraps
  /// the list and the hairlines are its separators.
  static Widget sliver(
    BuildContext context, {
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    final n = context.noor;
    return DecoratedSliver(
      decoration: _decoration(n),
      sliver: SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (context, _) =>
            SizedBox(height: 1, child: ColoredBox(color: n.line)),
        itemBuilder: itemBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    return DecoratedBox(
      decoration: _decoration(n),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (divided && i > 0)
              SizedBox(height: 1, child: ColoredBox(color: n.line)),
            children[i],
          ],
        ],
      ),
    );
  }
}

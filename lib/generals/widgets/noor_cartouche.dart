import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// A small piece of night sky: a `window` pill framed by a raised paper ring
/// (with a `line` seam in Night), 56 dp tall, a moon-white star either side of
/// [child] unless [leading] or [trailing] replace them. Screen titles, search
/// and the location use it; put `on-window` colours on whatever goes inside.
class NoorCartouche extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Drops it to `shadow-1`, for a field holding focus.
  final bool settled;

  /// Space after [trailing]; a button already carries its own.
  final double endInset;

  /// Null fills the width given, as a control does. A title is held to this
  /// and centred.
  final double? maxWidth;

  const NoorCartouche({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.settled = false,
    this.endInset = NoorSpace.s4,
    this.maxWidth,
  });

  /// One line of title: [style] replaces the `heading` in `on-window`, for a
  /// name set in another script.
  factory NoorCartouche.title(String name, {Key? key, TextStyle? style}) =>
      NoorCartouche(
        key: key,
        maxWidth: 280,
        child: _Title(name, style),
      );

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final star = NoorIcon(NoorGlyph.star, size: 14, color: n.onWindowMuted);
    final title = maxWidth != null;
    final pill = BorderRadius.circular(NoorRadius.pill);

    Widget frame(bool down) => AnimatedContainer(
          duration: kNoorPressDuration,
          curve: Curves.ease,
          // The Night seam takes its dp out of the ring: 56 dp in both themes.
          padding: EdgeInsets.all(n.isDark ? NoorSpace.s1 - 1 : NoorSpace.s1),
          decoration: BoxDecoration(
            color: n.card,
            borderRadius: pill,
            border: n.isDark ? Border.all(color: n.line) : null,
            boxShadow: down ? n.shadow1 : n.shadow2,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: n.window, borderRadius: pill),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                // A control keeps the whole height, for its 48 dp button.
                padding: EdgeInsetsDirectional.only(
                  start: NoorSpace.s4,
                  end: endInset,
                  top: title ? NoorSpace.s1 : 0,
                  bottom: title ? NoorSpace.s1 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    leading ?? star,
                    const SizedBox(width: NoorSpace.s3),
                    Flexible(
                      fit: title ? FlexFit.loose : FlexFit.tight,
                      child: child,
                    ),
                    const SizedBox(width: NoorSpace.s3),
                    trailing ?? star,
                  ],
                ),
              ),
            ),
          ),
        );

    final body = onTap == null
        ? frame(settled)
        : NoorPressable(
            onPressed: onTap,
            radius: NoorRadius.pill,
            builder: (context, pressed) => frame(pressed || settled),
          );

    final width = maxWidth;
    return width == null
        ? body
        : Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: body,
            ),
          );
  }
}

class _Title extends StatelessWidget {
  final String name;
  final TextStyle? style;

  const _Title(this.name, this.style);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        name,
        maxLines: 1,
        style: style ??
            NoorText.heading(context).copyWith(
              color: context.noor.onWindow,
              fontSize: 20,
            ),
      ),
    );
  }
}

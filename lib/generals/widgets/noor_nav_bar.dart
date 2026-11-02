import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Hilal TabBar: a flat `surface-raised` strip with `shadow-1`, floating
/// `s4` above the bottom safe area and `s4` in from the sides of the content
/// column ([NoorLayout]). The active item
/// is a `window` pill (moon-white in Night) that slides between items; the
/// others are `ink-muted`.
///
/// The widget's own height includes the safe area and the floating gap, so
/// `Scaffold` reserves exactly the room the bar covers. Items are laid out in
/// source order and mirror with the ambient [Directionality].
class NoorNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NoorNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const _select = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);

    final items = [
      (svg: SImageString.quran, label: s.nav_quran),
      (svg: SImageString.adhan, label: s.nav_prayers),
      (svg: SImageString.prayingHands, label: s.nav_adhkar),
      (svg: SImageString.kaaba, label: s.nav_qibla),
    ];

    final duration = noorDuration(context, _select);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: NoorLayout.gutter(context),
        end: NoorLayout.gutter(context),
        bottom: MediaQuery.paddingOf(context).bottom + NoorSpace.s4,
      ),
      // No height here: the bar grows with the label's text scale.
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: n.card,
          borderRadius: BorderRadius.circular(NoorRadius.lg),
          boxShadow: n.shadow1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(NoorSpace.s1),
          // Labels only: the icon and the tap target keep their size.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: NoorSpace.s1),
                    Expanded(
                      child: _Item(
                        svg: items[i].svg,
                        label: items[i].label,
                        selected: i == selectedIndex,
                        duration: duration,
                        onTap: () => onItemSelected(i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String svg;
  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  const _Item({
    required this.svg,
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    // Night inverts the active puff so it stays the strongest shape.
    final puff = n.isDark ? n.onWindow : n.window;
    final onPuff = n.isDark ? n.window : n.onWindow;

    final labelStyle = NoorText.caption(context);

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: NoorPressable(
        onPressed: onTap,
        radius: NoorRadius.pill,
        builder: (context, pressed) => Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            vertical: NoorSpace.s1,
            horizontal: NoorSpace.s1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: selected ? 1 : 0),
                duration: duration,
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => CloudMedallion(
                  size: 40,
                  front: Color.lerp(n.card, puff, t),
                  shadows: selected ? n.shadow2 : n.shadow1,
                  child: SvgPicture.asset(
                    svg,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      Color.lerp(n.muted, onPuff, t)!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: Curves.easeOutCubic,
                style: labelStyle.copyWith(
                  color: selected ? n.ink : n.muted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

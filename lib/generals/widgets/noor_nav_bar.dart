import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Hilal TabBar, cut like the text field ([NoorCartouche]): a capsule of raised
/// `surface-raised` paper with `shadow-2`, floating `s4` above the bottom safe
/// area and `s4` in from the sides of the content column ([NoorLayout]), holding
/// a pressed-in capsule trough ([NoorWell]). The selector is one window raised
/// out of the trough, a capsule of night sky (`window`; moon-white `onWindow` in
/// Night) on `shadow-1`, that slides to the chosen tab; its icon and label take
/// the opposite colour as it arrives. The others lie in the trough as
/// `ink-muted`. Every icon is in the Kaaba's navy and cream on a round plate.
///
/// The widget's own height includes the safe area and the floating gap, so
/// `Scaffold` reserves exactly the room the bar covers. Items are laid out in
/// source order and mirror with the ambient [Directionality], and the selector
/// slides the same way round.
class NoorNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NoorNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const select = Duration(milliseconds: 300);
  static const _pill = BorderRadius.all(Radius.circular(NoorRadius.pill));

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);

    final items = [
      (svg: SImageString.navQuran, label: s.nav_quran),
      (svg: SImageString.navMosque, label: s.nav_prayers),
      (svg: SImageString.navTasbih, label: s.nav_adhkar),
      (svg: SImageString.kaaba, label: s.nav_qibla),
    ];

    final duration = noorDuration(context, select);

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
          borderRadius: _pill,
          boxShadow: n.shadow2,
        ),
        child: Padding(
          padding: const EdgeInsets.all(NoorSpace.s1),
          // Labels only: the icon and the tap target keep their size.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Material(
              type: MaterialType.transparency,
              child: NoorWell(
                radius: NoorRadius.pill,
                child: Padding(
                  padding: const EdgeInsets.all(NoorSpace.s1),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final count = items.length;
                      const gap = NoorSpace.s1;
                      final itemWidth =
                          (box.maxWidth - (count - 1) * gap) / count;
                      return Stack(
                        children: [
                          // The selector: one capsule that travels, so the
                          // choice is a movement and not a swap.
                          Positioned.fill(
                            child: AnimatedAlign(
                              duration: duration,
                              curve: Curves.easeOutCubic,
                              alignment: AlignmentDirectional(
                                -1 + 2 * selectedIndex / (count - 1),
                                0,
                              ),
                              child: FractionallySizedBox(
                                widthFactor: itemWidth / box.maxWidth,
                                heightFactor: 1,
                                child: DecoratedBox(
                                  key: const ValueKey('nav-selector'),
                                  decoration: BoxDecoration(
                                    color: n.isDark ? n.onWindow : n.window,
                                    borderRadius: _pill,
                                    boxShadow: n.shadow1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (var i = 0; i < count; i++) ...[
                                if (i > 0) const SizedBox(width: gap),
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
                        ],
                      );
                    },
                  ),
                ),
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

  // Every icon is drawn in its own colours on a round plate, the Kaaba's way;
  // it is contained in the 22 x 18 the Kaaba takes.
  static const double _icon = 22;
  static const double _iconHeight = 18;
  static const double _slot = 28;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final labelStyle = NoorText.caption(context);
    // The window and what is drawn on it swap in Night, as every window does.
    final onPill = n.isDark ? n.window : n.onWindow;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: NoorPressable(
        onPressed: onTap,
        radius: NoorRadius.pill,
        builder: (context, pressed) => TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1 : 0),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            final color = Color.lerp(n.muted, onPill, t)!;
            return Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(
                vertical: NoorSpace.s1,
                horizontal: NoorSpace.s1,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: _slot,
                    child: Center(
                      child: _Plate(
                        // Dark on dark otherwise: the art stands on paper,
                        // light enough to read on every state.
                        color: Color.lerp(
                          n.isDark ? n.onWindowMuted : n.card,
                          n.onWindow,
                          t,
                        )!,
                        child: SvgPicture.asset(
                          svg,
                          width: _icon,
                          height: _iconHeight,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: labelStyle.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  final Color color;
  final Widget child;

  const _Plate({required this.color, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: SizedBox.square(
          dimension: _Item._slot,
          child: Center(child: child),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Floating card bar. The selected item is a primary circle raised above the
/// bar; it slides between items.
///
/// The widget's own height includes the raise, so the circle is inside its
/// hit-test bounds and `Scaffold` reserves room for it.
class NoorNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NoorNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const double _raise = 14;
  static const double _barHeight = 68;
  static const double _bottomMargin = 16;
  static const double _circle = 56;
  static const _slide = Duration(milliseconds: 250);

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

    return SizedBox(
      height: _raise + _barHeight + _bottomMargin,
      child: Stack(
        children: [
          PositionedDirectional(
            start: NoorSpace.lg,
            end: NoorSpace.lg,
            bottom: _bottomMargin,
            height: _barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: n.card,
                borderRadius: BorderRadius.circular(NoorRadius.sheet),
                boxShadow: noorShadow(context),
                border: n.isDark ? Border.all(color: n.line, width: 1) : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                NoorSpace.lg, 0, NoorSpace.lg, _bottomMargin),
            child: LayoutBuilder(
              builder: (context, box) {
                final slot = box.maxWidth / items.length;
                return Stack(
                  children: [
                    AnimatedPositionedDirectional(
                      duration: _slide,
                      curve: Curves.easeOutCubic,
                      top: 0,
                      start: slot * selectedIndex + (slot - _circle) / 2,
                      width: _circle,
                      height: _circle,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: n.primary,
                          shape: BoxShape.circle,
                          boxShadow: noorShadow(context),
                        ),
                      ),
                    ),
                    // Label text only; the 12 sp labels stay inside the bar.
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.2,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _Item(
                                  svg: items[i].svg,
                                  label: items[i].label,
                                  selected: i == selectedIndex,
                                  onTap: () => onItemSelected(i),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String svg;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Item({
    required this.svg,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final color = selected ? n.primary : n.muted;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedPositioned(
              duration: NoorNavBar._slide,
              curve: Curves.easeOutCubic,
              top: selected ? 16 : 28,
              child: SvgPicture.asset(
                svg,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  selected ? n.onPrimary : n.muted,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plex',
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

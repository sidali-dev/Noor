import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class NoorNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NoorNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 68,
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: noorShadow(context),
        border: n.isDark ? Border.all(color: n.line, width: 1) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          final item = items[index];
          final color = isSelected ? n.primary : n.muted;

          return Expanded(
            child: Semantics(
              selected: isSelected,
              button: true,
              label: item.label,
              child: InkResponse(
                onTap: () => onItemSelected(index),
                highlightShape: BoxShape.rectangle,
                splashFactory: InkRipple.splashFactory,
                radius: 36,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        item.svg,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Plex',
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        height: 2,
                        width: isSelected ? 24 : 0,
                        decoration: BoxDecoration(
                          color: isSelected ? n.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

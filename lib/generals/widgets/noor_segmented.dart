import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class NoorSegmented<T> extends StatelessWidget {
  final List<({T value, String label})> items;
  final T value;
  final ValueChanged<T> onChanged;

  const NoorSegmented({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    const trackRadius = BorderRadius.all(Radius.circular(999));

    return Container(
      padding: const EdgeInsets.all(NoorSpace.xs),
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: trackRadius,
        boxShadow: noorShadow(context),
        border: n.isDark ? Border.all(color: n.line, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: items.map((item) {
          final isSelected = item.value == value;
          return Expanded(
            child: Semantics(
              selected: isSelected,
              button: true,
              label: item.label,
              child: InkWell(
                borderRadius: trackRadius,
                onTap: () => onChanged(item.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    vertical: NoorSpace.md,
                    horizontal: NoorSpace.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? n.primary : Colors.transparent,
                    borderRadius: trackRadius,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.label,
                    style: NoorText.body(context).copyWith(
                      color: isSelected ? n.onPrimary : n.muted,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

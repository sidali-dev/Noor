import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// A sunken trough with the selected segment raised on it as paper
/// (`surface-raised`, `shadow-1`). Segments share the width and mirror with the
/// ambient [Directionality]; each is at least 48 dp tall.
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
    final duration = noorDuration(context, kNoorPressDuration);

    // Arabic script: Amiri, no letter-spacing (it breaks joining) and a taller
    // line. Chosen per label, so a language picker can mix scripts.
    final base = NoorText.label(context);
    final arabicStyle =
        base.copyWith(fontFamily: 'Amiri', letterSpacing: 0, height: 24 / 15);

    return NoorWell(
      radius: NoorRadius.pill,
      child: Padding(
        padding: const EdgeInsets.all(NoorSpace.s1),
        // Labels only: the targets keep their size.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Row(
            children: [
              for (final item in items)
                Expanded(
                  child: Semantics(
                    selected: item.value == value,
                    button: true,
                    label: item.label,
                    excludeSemantics: true,
                    child: NoorPressable(
                      onPressed: () => onChanged(item.value),
                      radius: NoorRadius.pill,
                      builder: (context, pressed) {
                        final selected = item.value == value;
                        return AnimatedContainer(
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: NoorSpace.s2,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? n.card : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(NoorRadius.pill),
                            boxShadow:
                                selected && !pressed ? n.shadow1 : const [],
                          ),
                          child: Text(
                            item.label,
                            style: (item.label.runes
                                        .any((r) => r >= 0x0600 && r <= 0x06FF)
                                    ? arabicStyle
                                    : base)
                                .copyWith(
                              color: selected ? n.ink : n.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

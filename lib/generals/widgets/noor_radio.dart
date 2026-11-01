import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The mark of a radio row: a 24 dp `line-strong` ring, and when [selected] a
/// brass ring with a brass dot. Visual only; the row owns the tap and the
/// semantics (`checked`, `inMutuallyExclusiveGroup`).
class NoorRadioMark extends StatelessWidget {
  final bool selected;

  const NoorRadioMark({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? n.brass : n.lineStrong,
            width: 2,
          ),
        ),
        child: SizedBox(
          width: 24,
          height: 24,
          child: selected
              ? Center(
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(color: n.brass, shape: BoxShape.circle),
                    child: const SizedBox(width: 12, height: 12),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Future<T?> showNoorSheet<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
}) {
  final n = context.noor;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: n.card,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(NoorRadius.sheet)),
    ),
    builder: (sheetContext) {
      final mq = MediaQuery.of(sheetContext);
      final bottomInset = mq.viewInsets.bottom + mq.padding.bottom + NoorSpace.xl;

      return Container(
        decoration: BoxDecoration(
          color: n.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(NoorRadius.sheet),
          ),
          border: n.isDark
              ? Border(top: BorderSide(color: n.line, width: 1))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: NoorSpace.sm + 4),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: n.muted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: NoorSpace.sm),
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NoorSpace.xl,
                  vertical: NoorSpace.sm,
                ),
                child: Text(
                  title,
                  style: NoorText.section(sheetContext),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: NoorSpace.xs),
            ],
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: NoorSpace.xl,
                  right: NoorSpace.xl,
                  bottom: bottomInset,
                  top: NoorSpace.xs,
                ),
                child: builder(sheetContext),
              ),
            ),
          ],
        ),
      );
    },
  );
}

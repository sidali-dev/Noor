import 'package:flutter/material.dart';
import 'package:noor/core/widgets/loading_state.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';

/// A paper card with a spinner and one sentence. It has no action: the work
/// behind it cannot be cancelled.
class WaitDialog extends StatelessWidget {
  const WaitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final message = S.of(context).wait_please;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: NoorSpace.s5,
        vertical: NoorSpace.s6,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: NoorDialogCard(
          child: Semantics(
            liveRegion: true,
            label: message,
            child: ExcludeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingDots(),
                  const SizedBox(height: NoorSpace.s4),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: NoorText.body(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

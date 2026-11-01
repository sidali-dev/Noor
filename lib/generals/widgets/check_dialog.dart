import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// A brief notice: a state icon in [color] (success or danger, always with the
/// [title] words), one `Done` button, and it still dismisses itself.
class CheckDialog extends StatefulWidget {
  final String title;
  final IconData? icon;
  final NoorGlyph? glyph;
  final Color color;

  const CheckDialog({
    super.key,
    required this.title,
    this.icon,
    this.glyph,
    required this.color,
  }) : assert(icon != null || glyph != null);

  @override
  State<CheckDialog> createState() => _CheckDialogState();
}

class _CheckDialogState extends State<CheckDialog> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      // Not while it is already leaving: that pop would take the page below.
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: n.surfaceSunken,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: widget.glyph != null
                        ? NoorIcon(widget.glyph!, size: 28, color: widget.color)
                        : Icon(widget.icon, size: 28, color: widget.color),
                  ),
                ),
              ),
              const SizedBox(height: NoorSpace.s4),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: NoorText.heading(context),
              ),
              const SizedBox(height: NoorSpace.s5),
              NoorButton(
                label: S.of(context).done,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

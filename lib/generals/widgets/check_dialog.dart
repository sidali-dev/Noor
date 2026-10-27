import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Brief notice that dismisses itself.
class CheckDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CheckDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<CheckDialog> createState() => _CheckDialogState();
}

class _CheckDialogState extends State<CheckDialog> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
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
      backgroundColor: n.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: n.isDark ? BorderSide(color: n.line, width: 1) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 40, color: widget.color),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: NoorText.rowTitle(context).copyWith(color: n.ink),
            ),
          ],
        ),
      ),
    );
  }
}

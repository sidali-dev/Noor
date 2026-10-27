import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class CheckDialog extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color color;

  const CheckDialog({
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
  });

  @override
  State<CheckDialog> createState() => _CheckDialogState();
}

class _CheckDialogState extends State<CheckDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
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
            SizedBox(
              height: 120,
              child: Lottie.asset(
                widget.imagePath,
                fit: BoxFit.contain,
                repeat: false,
                controller: _lottieController,
                onLoaded: (comp) {
                  _lottieController.duration = comp.duration;
                  _lottieController.forward();
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: NoorText.rowTitle(context).copyWith(
                color:
                    widget.color == Colors.transparent ? n.ink : widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

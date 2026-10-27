import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class NoorProgressBar extends StatelessWidget {
  final double value;
  final double height;

  const NoorProgressBar({
    super.key,
    required this.value,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final clamped = value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(height / 2);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: n.line,
          borderRadius: radius,
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: clamped),
          builder: (context, animatedValue, child) {
            return FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: animatedValue,
              child: Container(
                decoration: BoxDecoration(
                  color: n.primary,
                  borderRadius: radius,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

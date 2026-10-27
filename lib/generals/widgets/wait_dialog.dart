import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class WaitDialog extends StatelessWidget {
  const WaitDialog({
    super.key,
    required this.isDark,
    required this.isRtl,
  });

  final bool isDark;
  final bool isRtl;

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitThreeBounce(
              color: n.primary,
              size: 28,
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).wait_please,
              textAlign: TextAlign.center,
              style: NoorText.body(context).copyWith(
                fontWeight: FontWeight.w500,
                color: n.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

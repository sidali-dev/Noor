import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:noor/generated/l10n.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitThreeBounce(color: isDark ? SColors.secondary : SColors.primary),
        const SizedBox(height: 32),
        Material(
          color: Colors.transparent,
          child: Text(
            S.of(context).wait_please,
            style: TextStyle(
                color: isDark ? SColors.white : SColors.primary,
                fontSize: isRtl ? SSizes.fontSizeMdAr : SSizes.fontSizeMd),
          ),
        )
      ],
    );
  }
}

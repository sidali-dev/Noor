import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:noor/utils/device/device_utility.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import '../../../generated/l10n.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class QiblaCompassTipsDialog extends StatelessWidget {
  const QiblaCompassTipsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isRtl = SHelperFunctions.isRtl(context);
    final bool isDark = SHelperFunctions.isDarkMode(context);
    return Dialog(
      child: SizedBox(
        height: SDeviceUtils.getScreenHeight(context) * 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.information,
                      color: isDark ? SColors.secondary : SColors.primary),
                  const SizedBox(width: 8),
                  Text(S.of(context).tips,
                      style: TextStyle(
                          fontSize:
                              isRtl ? SSizes.fontSizeLgAr : SSizes.fontSizeLg,
                          color: isDark ? SColors.secondary : SColors.primary)),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 16),
              TipsLine(
                  title: S.of(context).flat_phone_title,
                  description: S.of(context).flat_phone_body,
                  isRtl: isRtl),
              TipsLine(
                  title: S.of(context).keep_from_magnetic_title,
                  description: S.of(context).keep_from_magnetic_body,
                  isRtl: isRtl),
              TipsLine(
                  title: S.of(context).enable_location_title,
                  description: S.of(context).enable_location_body,
                  isRtl: isRtl),
            ],
          ),
        ),
      ),
    );
  }
}

class TipsLine extends StatelessWidget {
  const TipsLine({
    super.key,
    required this.title,
    required this.description,
    required this.isRtl,
  });

  final String title;
  final String description;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: isRtl ? SSizes.fontSizeSmAr : SSizes.fontSizeSm),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 4.0, bottom: 16.0),
          child: Text(
              textAlign: TextAlign.center,
              description,
              style: TextStyle(
                  fontSize: isRtl ? SSizes.fontSizeSmAr : SSizes.fontSizeSm)),
        ),
      ],
    );
  }
}

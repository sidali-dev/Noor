// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:noor/utils/constants/colors.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/constants/sizes.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import '../../generated/l10n.dart';

class PickSearchOptionDialog extends StatelessWidget {
  const PickSearchOptionDialog({
    super.key,
    required this.onManualCallBack,
    required this.onGPSCallBack,
  });

  final Future<void> Function() onManualCallBack;
  final Future<void> Function() onGPSCallBack;

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    final isRtl = SHelperFunctions.isRtl(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).enter_location,
                  style: TextStyle(
                      fontSize:
                          isRtl ? SSizes.fontSizeXlgAr : SSizes.fontSizeLg),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    await onGPSCallBack();
                    Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? SColors.darkerGrey : SColors.grey),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Image.asset(SImageString.location, height: 90),
                          const SizedBox(height: 8),
                          Text(
                            S.of(context).gps,
                            style: TextStyle(
                                fontSize: isRtl
                                    ? SSizes.fontSizeMdAr
                                    : SSizes.fontSizeMd),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await onManualCallBack();
                    Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? SColors.darkerGrey : SColors.softGrey),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Image.asset(SImageString.manual, height: 90),
                          const SizedBox(height: 8),
                          Text(
                            S.of(context).manually,
                            style: TextStyle(
                                fontSize: isRtl
                                    ? SSizes.fontSizeMdAr
                                    : SSizes.fontSizeMd),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

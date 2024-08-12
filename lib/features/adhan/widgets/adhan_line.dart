import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class AdhanLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String adhanKey;

  const AdhanLine({
    super.key,
    required this.icon,
    required this.time,
    required this.title,
    required this.adhanKey,
  });

  @override
  Widget build(BuildContext context) {
    AdhanController controller = Get.find();

    bool isDark = SHelperFunctions.isDarkMode(context);
    bool isRtl = SHelperFunctions.isRtl(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: SSizes.lg),
        Icon(icon, color: SColors.secondary, size: SSizes.iconLg),
        const SizedBox(width: SSizes.sm),
        Text(
          title,
          style: TextStyle(
              color: isDark ? SColors.white : SColors.primary,
              fontSize: isRtl ? SSizes.fontSizeMdAr : SSizes.fontSizeMd),
        ),
        const Expanded(child: SizedBox()),
        GestureDetector(
          child: Obx(
            () {
              bool isActive = false;
              int id = 0;
              switch (adhanKey) {
                case "fajr":
                  isActive = controller.adhanFajr.value;
                  id = 1;
                  break;
                case "chourouk":
                  isActive = controller.adhanChourouk.value;
                  id = 2;
                  break;
                case "dhuhr":
                  isActive = controller.adhanDhuhr.value;
                  id = 3;
                  break;
                case "asr":
                  isActive = controller.adhanAsr.value;
                  id = 4;
                  break;
                case "maghrib":
                  isActive = controller.adhanMaghrib.value;
                  id = 5;
                  break;
                case "isha":
                  isActive = controller.adhanIsha.value;
                  id = 6;
                  break;
                default:
                  break;
              }

              return IconButton(
                icon: Icon(
                    isActive ? Iconsax.volume_high : Iconsax.volume_cross,
                    size: SSizes.iconLg,
                    color: isDark ? SColors.white : SColors.primary),
                onPressed: () async {
                  await controller.switchAdhan(adhanKey);
                  if (!SharedPrefService.getBool(adhanKey)!) {
                    await SHelperFunctions.cancelAlarm(id);
                  } else {
                    AdhanController.scheduleAdhans();
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(width: SSizes.sm),
        Text(time,
            style: TextStyle(
                color: isDark ? SColors.white : SColors.primary,
                fontSize: isRtl ? SSizes.fontSizeMdAr : SSizes.fontSizeMd)),
        const SizedBox(width: SSizes.lg),
      ],
    );
  }
}

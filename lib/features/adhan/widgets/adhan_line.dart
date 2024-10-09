import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/controllers/adhan_line_controller.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class AdhanLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String adhanKey;
  final AdhanLineController adhanLineController;

  AdhanLine({
    super.key,
    required this.icon,
    required this.time,
    required this.title,
    required this.adhanKey,
    required this.adhanLineController,
  });

  late String alarmActivationKey1;
  late String alarmActivationKey2;
  late String alarmDurationKey1;
  late String alarmDurationKey2;

  @override
  Widget build(BuildContext context) {
    AdhanController controller = Get.find();

    bool isDark = SHelperFunctions.isDarkMode(context);
    bool isRtl = SHelperFunctions.isRtl(context);

    return InkWell(
      onTap: () {
        adhanLineController.isExpanded.value =
            !adhanLineController.isExpanded.value;
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Obx(
        () => Column(
          children: [
            Row(
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
                      fontSize:
                          isRtl ? SSizes.fontSizeMdAr : SSizes.fontSizeMd),
                ),
                // IconButton(onPressed: () {}, icon: const Icon(Iconsax.timer_1)),
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
                          alarmActivationKey1 = "101";
                          alarmActivationKey2 = "102";
                          alarmDurationKey1 = "fajr_alarm_1_duration";
                          alarmDurationKey2 = "fajr_alarm_2_duration";
                          break;
                        case "chourouk":
                          isActive = controller.adhanChourouk.value;
                          id = 2;
                          alarmActivationKey1 = "201";
                          alarmActivationKey2 = "202";
                          alarmDurationKey1 = "chourouk_alarm_1_duration";
                          alarmDurationKey2 = "chourouk_alarm_2_duration";
                          break;
                        case "dhuhr":
                          isActive = controller.adhanDhuhr.value;
                          id = 3;
                          alarmActivationKey1 = "301";
                          alarmActivationKey2 = "302";
                          alarmDurationKey1 = "dhuhr_alarm_1_duration";
                          alarmDurationKey2 = "dhuhr_alarm_2_duration";
                          break;
                        case "asr":
                          isActive = controller.adhanAsr.value;
                          id = 4;
                          alarmActivationKey1 = "401";
                          alarmActivationKey2 = "402";
                          alarmDurationKey1 = "asr_alarm_1_duration";
                          alarmDurationKey2 = "asr_alarm_2_duration";
                          break;
                        case "maghrib":
                          isActive = controller.adhanMaghrib.value;
                          id = 5;

                          alarmActivationKey1 = "501";
                          alarmActivationKey2 = "502";
                          alarmDurationKey1 = "maghrib_alarm_1_duration";
                          alarmDurationKey2 = "maghrib_alarm_2_duration";
                          break;
                        case "isha":
                          isActive = controller.adhanIsha.value;
                          id = 6;
                          alarmActivationKey1 = "601";
                          alarmActivationKey2 = "602";
                          alarmDurationKey1 = "isha_alarm_1_duration";
                          alarmDurationKey2 = "isha_alarm_2_duration";
                          break;
                        default:
                          break;
                      }

                      return IconButton(
                        icon: Icon(
                            isActive
                                ? Iconsax.volume_high
                                : Iconsax.volume_cross,
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
                        fontSize:
                            isRtl ? SSizes.fontSizeMdAr : SSizes.fontSizeMd)),
                const SizedBox(width: SSizes.md),
                Icon(
                    adhanLineController.isExpanded.value
                        ? Iconsax.arrow_up_2
                        : Iconsax.arrow_down_1,
                    color: isDark ? SColors.secondary : SColors.primary),
                const SizedBox(width: SSizes.md),
              ],
            ),
            Visibility(
              visible: adhanLineController.isExpanded.value,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (adhanLineController.time.value == 0) {
                              return;
                            }

                            adhanLineController.addAlarm(
                                alarmActivationKey1,
                                alarmActivationKey2,
                                alarmDurationKey1,
                                alarmDurationKey2,
                                time);
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(12.0),
                            elevation: 10.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                  color: isDark
                                      ? SColors.secondary
                                      : SColors.primary,
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: const Row(
                                children: [
                                  Icon(Icons.add_alarm, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "set new alarm",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                            onPressed: () {
                              adhanLineController.decrementTime();
                            },
                            icon: const Icon(Iconsax.minus)),
                        Obx(() => Text("${adhanLineController.time} min")),
                        IconButton(
                            onPressed: () {
                              adhanLineController.incrementTime();
                            },
                            icon: const Icon(Iconsax.add))
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

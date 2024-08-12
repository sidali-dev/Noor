import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/generals/widgets/pick_search_option.dart';

import '../../features/adhan/adhan_controller.dart';
import '../../features/adhan/widgets/location_picker_dialog.dart';
import '../../generated/l10n.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_functions.dart';
import 'check_dialog.dart';
import 'wait_dialog.dart';

class GetLocationWidget extends StatelessWidget {
  const GetLocationWidget({
    super.key,
    required this.isDark,
    required this.isRtl,
    required this.controller,
  });

  final bool isDark;
  final bool isRtl;
  final AdhanController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        showDialog(
            barrierDismissible: false,
            context: Get.context!,
            builder: (context) => WaitDialog(isDark: isDark, isRtl: isRtl));

        if (await SHelperFunctions.isInternetConnected()) {
          Get.back();
          await showDialog(
            context: Get.context!,
            builder: (context) {
              return PickSearchOptionDialog(
                onManualCallBack: () async {
                  Map response = await showDialog(
                      barrierDismissible: false,
                      context: Get.context!,
                      builder: (context) => const LocationPicker());
                  if (response.isNotEmpty) {
                    showDialog(
                        barrierDismissible: false,
                        context: Get.context!,
                        builder: (context) =>
                            WaitDialog(isDark: isDark, isRtl: isRtl));
                    await controller.refreshAdhanData(
                        response["country"],
                        response["state"],
                        response["city"],
                        DateTime.now().year);
                    await AdhanController.scheduleAdhans();
                    Get.back();
                  }
                },
                onGPSCallBack: () async {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          WaitDialog(isDark: isDark, isRtl: isRtl));

                  Placemark placemark = await SHelperFunctions.getLocation();

                  if (placemark.country != null) {
                    await controller.refreshAdhanData(
                        placemark.country!,
                        placemark.administrativeArea!,
                        placemark.locality!,
                        DateTime.now().year);
                    await AdhanController.scheduleAdhans();
                    Get.back();
                  } else {
                    Get.back();
                  }
                },
              );
            },
          );
        } else {
          await showDialog(
            context: Get.context!,
            builder: (context) => CheckDialog(
                title: S.of(context).no_internet,
                imagePath: SImageString.lottieNoInternet,
                color: Colors.lightBlue),
          );
          Get.back();
        }
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.location, color: SColors.white),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                controller.locationController.country.value == ""
                    ? S.of(context).enter_location
                    : "${controller.locationController.country.value}, ${controller.locationController.city.value}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: SColors.white,
                    fontSize: controller.locationController.country.value != ""
                        ? SSizes.fontSizeMd
                        : isRtl
                            ? SSizes.fontSizeMdAr
                            : SSizes.fontSizeMd),
              ),
            )
          ],
        ),
      ),
    );
  }
}

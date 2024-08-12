// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/utils/constants/sizes.dart';

import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/utils/constants/colors.dart';

import '../../generated/l10n.dart';
import '../../utils/constants/enums.dart';
import '../../utils/helpers/helper_functions.dart';
import '../controllers/theme_controller.dart';

class DialogSettings extends StatelessWidget {
  const DialogSettings({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.find();
    SoundPickerController soundController = Get.find();
    LocalizationController localizationController = Get.find();

    return Dialog(
      backgroundColor:
          SHelperFunctions.isDarkMode(context) ? Colors.black : Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            S.of(context).settings,
            style: TextStyle(
                fontSize: SHelperFunctions.isRtl(context)
                    ? SSizes.fontSizeLgAr
                    : SSizes.fontSizeLg,
                fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  S.of(context).dark_mode,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: SHelperFunctions.isRtl(context)
                          ? SSizes.fontSizeMdAr
                          : SSizes.fontSizeMd),
                ),
              ),
              const Expanded(child: SizedBox()),
              Switch(
                trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => Colors.transparent),
                trackColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) =>
                        SHelperFunctions.isDarkMode(context)
                            ? SColors.primary
                            : Colors.grey.shade300),
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => Colors.transparent),
                activeColor: Colors.lightBlue.shade500,
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    (Set<WidgetState> states) {
                  if (SHelperFunctions.isDarkMode(context)) {
                    return const Icon(Iconsax.moon);
                  } else {
                    return Icon(Iconsax.sun_15, color: Colors.yellow.shade900);
                  }
                }),
                activeTrackColor: Colors.lightBlue.shade200,
                value: SHelperFunctions.isDarkMode(context),
                onChanged: (value) async {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const Center(
                          child: SpinKitThreeBounce(color: Colors.lightBlue)));
                  Future.delayed(const Duration(seconds: 1))
                      .then((value) async {
                    await themeController.switchTheme();

                    Get.back();
                  });
                },
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    S.of(context).language,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: SHelperFunctions.isRtl(context)
                            ? SSizes.fontSizeMdAr
                            : SSizes.fontSizeMd),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField(
                    autofocus: true,
                    alignment: Alignment.center,
                    value: SHelperFunctions.getLangluageCode(),
                    onChanged: (value) async {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => const Center(
                              child:
                                  SpinKitThreeBounce(color: Colors.lightBlue)));
                      localizationController.setLanguage(value!);
                      await AdhanController.scheduleAdhans();
                      soundController.updateAdhanName();
                      Future.delayed(const Duration(seconds: 1)).then(
                        (value) => Get.back(),
                      );
                    },
                    items: Languages.values
                        .map((e) => DropdownMenuItem(
                              value: e.name,
                              child: SHelperFunctions.getLanguage(e.name),
                            ))
                        .toList(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

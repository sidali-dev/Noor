// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';

import 'package:noor/features/adhan/widgets/divider.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:noor/utils/constants/sound_string.dart';
import 'package:noor/utils/device/device_utility.dart';

import '../../../generated/l10n.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class AdhanSoundPicker extends StatelessWidget {
  const AdhanSoundPicker({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = SHelperFunctions.isDarkMode(context);
    bool isRtl = SHelperFunctions.isRtl(context);
    return Dialog(
      backgroundColor:
          isDark ? const Color.fromARGB(255, 20, 20, 20) : Colors.white,
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: SSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.volume_high,
                    color: SColors.primary, size: 32),
                const SizedBox(width: SSizes.sm),
                Text(S.of(context).pick_adhan,
                    style: TextStyle(
                      fontSize: isRtl ? SSizes.fontSizeMdAr : SSizes.fontSizeMd,
                    ))
              ],
            ),
            const SizedBox(height: SSizes.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AdhanSoundLine(
                      adhanSoundPath: SSoundString.adhanAhmadAlNafees,
                      controller: SoundPickerController(),
                      isRtl: isRtl,
                      title: S.of(Get.context!).chikh_nafees,
                    ),
                    const SDivider(
                        color: SColors.primary,
                        endIndent: 20,
                        indent: 20,
                        space: 2),
                    AdhanSoundLine(
                      adhanSoundPath: SSoundString.adhanAlafasy1,
                      isRtl: isRtl,
                      controller: SoundPickerController(),
                      title: S.of(Get.context!).chikh_afassy_1,
                    ),
                    const SDivider(
                        color: SColors.primary,
                        endIndent: 20,
                        indent: 20,
                        space: 2),
                    AdhanSoundLine(
                      adhanSoundPath: SSoundString.adhanAlafasy2,
                      controller: SoundPickerController(),
                      isRtl: isRtl,
                      title: S.of(Get.context!).chilh_afassy_2,
                    ),
                    const SDivider(
                        color: SColors.primary,
                        endIndent: 20,
                        indent: 20,
                        space: 2),
                    AdhanSoundLine(
                      controller: SoundPickerController(),
                      adhanSoundPath: SSoundString.adhanSalahMansoor,
                      isRtl: isRtl,
                      title: S.of(Get.context!).chikh_mansoor,
                    ),
                    const SizedBox(height: 32)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdhanSoundLine extends StatefulWidget {
  const AdhanSoundLine(
      {super.key,
      required this.title,
      required this.controller,
      required this.isRtl,
      required this.adhanSoundPath});

  final String title;
  final String adhanSoundPath;
  final bool isRtl;
  final SoundPickerController controller;

  @override
  State<AdhanSoundLine> createState() => _AdhanSoundLineState();
}

class _AdhanSoundLineState extends State<AdhanSoundLine> {
  @override
  void dispose() {
    widget.controller.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SoundPickerController generalController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: SDeviceUtils.getScreenWidth(context) * 0.4,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(widget.title,
                style: TextStyle(
                    fontSize: widget.isRtl
                        ? SSizes.fontSizeSmAr
                        : SSizes.fontSizeSm)),
          ),
        ),
        Row(
          children: [
            Obx(() => IconButton(
                onPressed: () async {
                  widget.controller.playOrPause();

                  widget.controller.playOrPauseSound(widget.adhanSoundPath);
                },
                icon: Icon(
                    widget.controller.isPlaying.value
                        ? Iconsax.pause_circle
                        : Iconsax.play_circle,
                    size: 24,
                    color: SColors.secondary))),
            IconButton(
                onPressed: () async {
                  await SharedPrefService.setString(
                      "adhan_sound_path", widget.adhanSoundPath);
                  await SharedPrefService.setString(
                      "adhan_sound_name", widget.title);
                  generalController.updateAdhanName();
                  AdhanController.scheduleAdhans();
                  Get.back();
                },
                icon: Icon(
                    SharedPrefService.getString("adhan_sound_path")! ==
                            widget.adhanSoundPath
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 24,
                    color: SColors.primary)),
          ],
        ),
      ],
    );
  }
}

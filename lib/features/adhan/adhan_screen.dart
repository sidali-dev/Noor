import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/controllers/adhan_line_controller.dart';
import 'package:noor/features/adhan/widgets/location_picker_dialog.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/adhan/widgets/sound_picker_dialog.dart';
import 'package:noor/generals/widgets/check_dialog.dart';
import 'package:noor/utils/constants/colors.dart';
import 'package:noor/utils/device/device_utility.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import '../../generals/widgets/get_locatiol_widget.dart';
import '../../generals/widgets/pick_search_option.dart';
import '../../generals/widgets/wait_dialog.dart';
import '../../generated/l10n.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import 'models/sub_models.dart/date.dart';
import 'widgets/adhan_line.dart';
import 'widgets/divider.dart';

class AdhanScreen extends StatelessWidget {
  const AdhanScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AdhanController controller = Get.find();

    SoundPickerController soundController = Get.find();
    bool isRtl = SHelperFunctions.isRtl(context);
    bool isDark = SHelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(alignment: Alignment.center, children: [
              Image.asset(SImageString.backgroundImage1),
              Positioned(
                child: Column(
                  children: [
                    SizedBox(
                        height: SDeviceUtils.getScreenHeight(context) * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          SImageString.octagon,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                        const SizedBox(width: SSizes.md),
                        const Text(
                          "وَأَقِيمُواْ الصَّلاَةَ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: SSizes.fontSizeLgAr,
                              fontFamily: "Amiri"),
                        ),
                        const SizedBox(width: SSizes.md),
                        SvgPicture.asset(
                          SImageString.octagon,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ],
                    ),
                    Divider(
                        color: Colors.white.withOpacity(0.7),
                        thickness: 1,
                        indent: 80,
                        endIndent: 80,
                        height: 20),
                    GetLocationWidget(
                        isDark: isDark, isRtl: isRtl, controller: controller),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => const AdhanSoundPicker());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.volume_high,
                              color: SColors.secondary),
                          const SizedBox(width: 8),
                          Obx(
                            () => Text(
                              soundController.adhanSoundName.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: SColors.secondary,
                                  fontSize: isRtl
                                      ? SSizes.fontSizeSmAr
                                      : SSizes.fontSizeSm),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ]),
            const SizedBox(height: SSizes.dividerHeightMd),
            FutureBuilder(
              future: controller.initController(DateTime.now().year),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      height: SDeviceUtils.getScreenHeight(context) * 0.7,
                      child: WaitDialog(isDark: isDark, isRtl: isRtl));
                }
                return Obx(
                  () => Visibility(
                    visible: controller.prayerTime.value!.code == 200,
                    replacement: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Lottie.asset(
                            height: SDeviceUtils.getScreenWidth(context) * 0.65,
                            SImageString.lottieAddLocation),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () async {
                            showDialog(
                                barrierDismissible: false,
                                context: Get.context!,
                                builder: (context) =>
                                    WaitDialog(isDark: true, isRtl: isRtl));
                            if (await SHelperFunctions.isInternetConnected()) {
                              Get.back();
                              Map response;

                              try {
                                response = await showDialog(
                                    barrierDismissible: false,
                                    context: Get.context!,
                                    builder: (context) =>
                                        PickSearchOptionDialog(
                                          onManualCallBack: () async {
                                            Map response = await showDialog(
                                                barrierDismissible: false,
                                                context: Get.context!,
                                                builder: (context) =>
                                                    const LocationPicker());
                                            if (response.isNotEmpty) {
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: Get.context!,
                                                  builder: (context) =>
                                                      WaitDialog(
                                                          isDark: true,
                                                          isRtl: isRtl));
                                              await controller.refreshAdhanData(
                                                  response["country"],
                                                  response["state"],
                                                  response["city"],
                                                  DateTime.now().year);
                                              await AdhanController
                                                  .scheduleAdhans();
                                              Get.back();
                                            }
                                          },
                                          onGPSCallBack: () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    WaitDialog(
                                                        isDark: true,
                                                        isRtl: isRtl));

                                            Placemark placemark =
                                                await SHelperFunctions
                                                    .getLocation();

                                            if (placemark.country != null) {
                                              await controller.refreshAdhanData(
                                                  placemark.country!,
                                                  placemark.administrativeArea!,
                                                  placemark.locality!,
                                                  DateTime.now().year);
                                              await AdhanController
                                                  .scheduleAdhans();
                                              Get.back();
                                            } else {
                                              Get.back();
                                            }
                                          },
                                        ));
                              } catch (_) {
                                response = {};
                              }

                              if (response.isNotEmpty) {
                                showDialog(
                                  barrierDismissible: false,
                                  context: Get.context!,
                                  builder: (context) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SpinKitThreeBounce(
                                          color: SColors.secondary),
                                      const SizedBox(height: 32),
                                      Material(
                                        color: Colors.transparent,
                                        child: Text(
                                          S.of(context).wait_please,
                                          style: TextStyle(
                                              color: isDark
                                                  ? SColors.white
                                                  : SColors.white,
                                              fontSize: isRtl
                                                  ? SSizes.fontSizeMdAr
                                                  : SSizes.fontSizeMd),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                                await controller.refreshAdhanData(
                                    response["country"],
                                    response["state"],
                                    response["city"],
                                    DateTime.now().year);
                                await AdhanController.scheduleAdhans();

                                Get.back();
                              }
                            } else {
                              Get.back();
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
                          child: Material(
                            borderRadius: BorderRadius.circular(24),
                            elevation: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: SColors.primary),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16),
                                child: Text(
                                  S.of(context).add_location,
                                  style: TextStyle(
                                      color: SColors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isRtl
                                          ? SSizes.fontSizeMdAr
                                          : SSizes.fontSizeMd),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                if (controller.date.value ==
                                    DateTime(
                                        controller.date.value.year, 1, 1)) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => CheckDialog(
                                          title: S.of(context).year_ended,
                                          imagePath:
                                              SImageString.lottieCalendarOut,
                                          color: Colors.red));
                                } else {
                                  controller.decrementDay();
                                }
                              },
                              icon: Icon(
                                  isRtl
                                      ? Iconsax.arrow_right_3
                                      : Iconsax.arrow_left_2,
                                  color:
                                      isDark ? SColors.white : SColors.primary,
                                  size: SSizes.iconXlg)),
                          SizedBox(
                            width: SDeviceUtils.getScreenWidth(context) * 0.6,
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Obx(
                                  () {
                                    Date date = controller
                                        .prayerTime
                                        .value!
                                        .data[controller.date.value.month
                                                .toString()]![
                                            controller.date.value.day - 1]
                                        .date;
                                    return Text(
                                        SHelperFunctions.isSameDay(
                                                controller.date.value,
                                                DateTime.now())
                                            ? S.of(context).today
                                            : isRtl
                                                ? "${date.hijri.weekday.ar} ${SHelperFunctions.formatDate(date.timestamp)}"
                                                : "${date.gregorian.weekday.en} ${SHelperFunctions.formatDate(date.timestamp)}",
                                        style: TextStyle(
                                            fontSize: isRtl
                                                ? SSizes.fontSizeLgAr
                                                : SSizes.fontSizeLg,
                                            color: isDark
                                                ? SColors.white
                                                : SColors.primary));
                                  },
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if (controller.date.value ==
                                    DateTime(
                                        controller.date.value.year, 12, 31)) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => CheckDialog(
                                          title: S.of(context).year_ended,
                                          imagePath:
                                              SImageString.lottieCalendarOut,
                                          color: Colors.red));
                                } else {
                                  controller.incrementDay();
                                }
                              },
                              icon: Icon(
                                  isRtl
                                      ? Iconsax.arrow_left_2
                                      : Iconsax.arrow_right_3,
                                  color:
                                      isDark ? SColors.white : SColors.primary,
                                  size: SSizes.iconXlg))
                        ],
                      ),
                      const SizedBox(height: SSizes.lg),
                      Obx(
                        () => AdhanLine(
                          title: S.of(context).fajr,
                          icon: Iconsax.sun_fog,
                          adhanLineController: AdhanLineController(),
                          time: SHelperFunctions.removeTimeZone(controller
                              .prayerTime
                              .value!
                              .data[controller.date.value.month.toString()]![
                                  controller.date.value.day - 1]
                              .timings
                              .fajr),
                          adhanKey: "fajr",
                        ),
                      ),
                      const SDivider(),
                      Obx(
                        () => AdhanLine(
                          title: S.of(context).sun_rise,
                          icon: Iconsax.sun_fog,
                          adhanLineController: AdhanLineController(),
                          time: SHelperFunctions.removeTimeZone(controller
                              .prayerTime
                              .value!
                              .data[controller.date.value.month.toString()]![
                                  controller.date.value.day - 1]
                              .timings
                              .sunrise),
                          adhanKey: "chourouk",
                        ),
                      ),
                      const SDivider(),
                      Obx(
                        () => AdhanLine(
                          title: S.of(context).dhuhr,
                          icon: Iconsax.sun_1,
                          adhanLineController: AdhanLineController(),
                          time: SHelperFunctions.removeTimeZone(controller
                              .prayerTime
                              .value!
                              .data[controller.date.value.month.toString()]![
                                  controller.date.value.day - 1]
                              .timings
                              .dhuhr),
                          adhanKey: "dhuhr",
                        ),
                      ),
                      const SDivider(),
                      Obx(
                        () => AdhanLine(
                          title: S.of(context).asr,
                          icon: Iconsax.cloud_sunny,
                          adhanLineController: AdhanLineController(),
                          time: SHelperFunctions.removeTimeZone(controller
                              .prayerTime
                              .value!
                              .data[controller.date.value.month.toString()]![
                                  controller.date.value.day - 1]
                              .timings
                              .asr),
                          adhanKey: "asr",
                        ),
                      ),
                      const SDivider(),
                      Obx(
                        () => AdhanLine(
                          title: S.of(context).maghrib,
                          icon: Iconsax.sun_fog,
                          adhanLineController: AdhanLineController(),
                          time: SHelperFunctions.removeTimeZone(controller
                              .prayerTime
                              .value!
                              .data[controller.date.value.month.toString()]![
                                  controller.date.value.day - 1]
                              .timings
                              .maghrib),
                          adhanKey: "maghrib",
                        ),
                      ),
                      const SDivider(),
                      Obx(
                        () => AdhanLine(
                          title: S.of(context).isha,
                          icon: Iconsax.moon,
                          adhanLineController: AdhanLineController(),
                          time: SHelperFunctions.removeTimeZone(controller
                              .prayerTime
                              .value!
                              .data[controller.date.value.month.toString()]![
                                  controller.date.value.day - 1]
                              .timings
                              .isha),
                          adhanKey: "isha",
                        ),
                      ),
                    ]),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}


//Remove israel from countries list.

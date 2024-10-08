import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/qibla/qibla_controller.dart';
import 'package:noor/features/qibla/widgets/qibla_tips_dialog.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/utils/helpers/helper_functions.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generals/widgets/get_locatiol_widget.dart';
import '../../generals/widgets/wait_dialog.dart';
import '../../generated/l10n.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/device/device_utility.dart';
import 'widgets/qibla_compass.dart';

class QiblaScreen extends StatelessWidget {
  QiblaScreen({super.key});

  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  final AdhanController _adhanController = Get.put(AdhanController());
  final LocationController _locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    final isRtl = SHelperFunctions.isRtl(context);

    _locationController.getLocation();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(alignment: Alignment.center, children: [
              Image.asset(SImageString.backgroundImage2),
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
                        "فَوَلِّ وَجْهَكَ شَطْرَ الْمَسْجِدِ الْحَرَامِ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SSizes.fontSizeMd,
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
                      isDark: isDark,
                      isRtl: isRtl,
                      controller: _adhanController),
                  const SizedBox(height: 10),
                ],
              )),
            ]),

            // ==================THE LOWER PART OF SCREEN BELOW==================

            const SizedBox(height: SSizes.dividerHeightMd),
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.send_2,
                        color: isDark ? SColors.white : SColors.primary,
                        size: 32),
                    const SizedBox(width: 16.0),
                    Text(
                      S.of(context).qiblah,
                      style: TextStyle(
                          color: isDark ? SColors.white : SColors.primary,
                          fontSize:
                              isRtl ? SSizes.fontSizeXlgAr : SSizes.fontSizeXlg,
                          fontWeight: FontWeight.w800),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (context) => const QiblaCompassTipsDialog());
                    },
                    icon: CircleAvatar(
                      radius: 22.0,
                      backgroundColor: isDark ? SColors.dark : SColors.grey,
                      child: Icon(Iconsax.information,
                          size: 26,
                          color: isDark ? SColors.secondary : SColors.primary),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: SDeviceUtils.getScreenHeight(context) * 0.04),
            FutureBuilder(
              future: _deviceSupport,
              builder: (_, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      const SizedBox(height: 56),
                      WaitDialog(isDark: true, isRtl: isRtl),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Column(
                    children: [
                      SizedBox(
                        height: SDeviceUtils.getScreenHeight(context) * 0.1,
                      ),
                      Lottie.asset(SImageString.lottieError),
                      Text(
                        "Error: ${snapshot.error.toString()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: SColors.warning,
                            fontSize: isRtl
                                ? SSizes.fontSizeMdAr
                                : SSizes.fontSizeMd),
                      ),
                    ],
                  );
                } else if (snapshot.data) {
                  //====================================================================================================
                  return GetBuilder<QiblaController>(
                    init: QiblaController(),
                    builder: (controller) {
                      return StreamBuilder(
                        stream: controller.stream,
                        builder:
                            (context, AsyncSnapshot<LocationStatus> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          } else if (snapshot.data!.enabled) {
                            //this means that the gps signal is on, but not necessiraly that the permission is granted.

                            switch (snapshot.data!.status) {
                              case LocationPermission.always:
                              case LocationPermission.whileInUse:
                                //this means that the gps signal is on, and the permission is granted.

                                return QiblaCompass();

                              case LocationPermission.denied:
                              case LocationPermission.deniedForever:
                                //this means that the gps signal is on, and the permission is not granted.

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Lottie.asset(SImageString.lottieAddLocation,
                                        height: SDeviceUtils.getScreenHeight(
                                                context) *
                                            0.3),
                                    GestureDetector(
                                      onTap: () async {
                                        requestPermission();
                                        controller.restartCheckLocationStatus();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              color: SColors.primary),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 10.0),
                                            child: Text(
                                              S
                                                  .of(context)
                                                  .enable_location_permission,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: SColors.white,
                                                  fontSize: isRtl
                                                      ? SSizes.fontSizeMdAr
                                                      : SSizes.fontSizeMd),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );

                              default:
                                return const SizedBox();
                            }
                          } else {
                            //this means that the gps signal is off, but not necessiraly that the permission is not granted.

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(SImageString.lottieAddLocation,
                                    height:
                                        SDeviceUtils.getScreenHeight(context) *
                                            0.3),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: () async {
                                    await requestPermission();
                                    try {
                                      await Geolocator.getCurrentPosition();
                                      controller.restartCheckLocationStatus();
                                    } catch (_) {}
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          color: SColors.primary),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 16.0),
                                        child: Text(
                                          S.of(context).enable_location,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: SColors.white,
                                              fontSize: isRtl
                                                  ? SSizes.fontSizeMdAr
                                                  : SSizes.fontSizeMd),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    },
                  );
                } else {
                  // Device does not support the sensor, Display Maps widget
                  return Column(
                    children: [
                      SizedBox(
                        height: SDeviceUtils.getScreenHeight(context) * 0.1,
                      ),
                      Lottie.asset(SImageString.lottieError),
                      Text(
                        S.of(context).sensor_not_supported,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: SColors.warning,
                            fontSize: isRtl
                                ? SSizes.fontSizeMdAr
                                : SSizes.fontSizeMd),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermission() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
    if (await Permission.location.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}
//handle when the user turn down the location permission
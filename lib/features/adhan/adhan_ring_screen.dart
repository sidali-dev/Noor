import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noor/bottom_navigation.dart';
import 'package:noor/utils/constants/image_strings.dart';

import 'package:noor/utils/device/device_utility.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

import '../../generated/l10n.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';

class AdhanRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AdhanRingScreen({super.key, required this.alarmSettings});

  @override
  State<AdhanRingScreen> createState() => _AdhanRingScreenState();
}

class _AdhanRingScreenState extends State<AdhanRingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
    ]).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  dispose() {
    Alarm.stop(widget.alarmSettings.id);

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = SHelperFunctions.isRtl(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Container(
            height: SDeviceUtils.getScreenHeight(context),
            width: SDeviceUtils.getScreenWidth(context),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    SHelperFunctions.getAlarmColor(widget.alarmSettings.id),
                    SHelperFunctions.isDarkMode(context)
                        ? SColors.dark
                        : Colors.grey
                  ],
                  begin: _topAlignmentAnimation.value,
                  end: _bottomAlignmentAnimation.value),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      SvgPicture.asset(SImageString.logo, height: 48.0),
                      const SizedBox(width: 10),
                      Text(S.of(context).noor,
                          style: TextStyle(
                              fontSize: isRtl
                                  ? SSizes.fontSizeLgAr
                                  : SSizes.fontSizeLg,
                              color: Colors.white))
                    ],
                  ),
                  const SizedBox(height: 100),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      SizedBox(
                        width: SDeviceUtils.getScreenWidth(context) * 0.9,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            widget.alarmSettings.notificationTitle,
                            style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        '${S.of(context).its} ${DateFormat('HH:mm').format(widget.alarmSettings.dateTime)}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        widget.alarmSettings.notificationBody,
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 200),
                  ElevatedButton(
                    onPressed: () {
                      Alarm.stop(widget.alarmSettings.id)
                          .then((_) => Get.offAll(() {
                                SBottomNavigationController controller =
                                    Get.put(SBottomNavigationController());
                                controller.changeIndex(2);

                                return const SBottomNavigation(pageIndex: 2);
                              }));
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent),
                      backgroundColor: SColors.secondary.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      S.of(context).open_adhkar,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      Alarm.stop(widget.alarmSettings.id)
                          .then((_) => SystemNavigator.pop(animated: true));
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      S.of(context).close,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

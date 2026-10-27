import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/widgets/adhan_line.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/adhan/widgets/sound_picker_sheet.dart';
import 'package:noor/generals/location_flow.dart';
import 'package:noor/generals/widgets/check_dialog.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/location_pill.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_header.dart';
import 'package:noor/generals/widgets/noor_pill.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/helpers/helper_functions.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class AdhanScreen extends StatefulWidget {
  const AdhanScreen({super.key});

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _onPreviousDay(BuildContext context, AdhanController controller) {
    final d = controller.date.value;
    if (d.month == 1 && d.day == 1) {
      showDialog(
        context: context,
        builder: (c) => CheckDialog(
          title: S.of(c).year_ended,
          imagePath: SImageString.lottieCalendarOut,
          color: c.noor.danger,
        ),
      );
    } else {
      controller.decrementDay();
    }
  }

  void _onNextDay(BuildContext context, AdhanController controller) {
    final d = controller.date.value;
    if (d.month == 12 && d.day == 31) {
      showDialog(
        context: context,
        builder: (c) => CheckDialog(
          title: S.of(c).year_ended,
          imagePath: SImageString.lottieCalendarOut,
          color: c.noor.danger,
        ),
      );
    } else {
      controller.incrementDay();
    }
  }

  String _formatDateTitle(BuildContext context, AdhanController controller) {
    final d = controller.date.value;
    final isToday = SHelperFunctions.isSameDay(d, DateTime.now());
    if (isToday) {
      return S.of(context).today;
    }

    final isRtl = SHelperFunctions.isRtl(context);
    final pt = controller.prayerTime.value;
    final monthList = pt?.data[d.month.toString()];
    final datum = (monthList != null &&
            d.day - 1 >= 0 &&
            d.day - 1 < monthList.length)
        ? monthList[d.day - 1]
        : null;

    if (datum != null) {
      return isRtl
          ? "${datum.date.hijri.weekday.ar} ${SHelperFunctions.formatDate(datum.date.timestamp)}"
          : "${datum.date.gregorian.weekday.en} ${SHelperFunctions.formatDate(datum.date.timestamp)}";
    }

    return DateFormat('EEEE, dd MMM yyyy').format(d);
  }

  String _formatNextPrayerDuration(BuildContext context,
      ({Prayer prayer, DateTime at, bool isTomorrow}) next) {
    final now = DateTime.now();
    final diff = next.at.difference(now);
    final totalMinutes = (diff.inSeconds + 59) ~/ 60;
    final s = S.of(context);
    final prayerName = next.prayer.localizedTitle(context);

    final String timeStr;
    if (totalMinutes < 60) {
      final m = totalMinutes > 0 ? totalMinutes : 1;
      timeStr = s.duration_m(m);
    } else {
      final h = totalMinutes ~/ 60;
      final m = totalMinutes % 60;
      timeStr = s.duration_hm(h, m);
    }

    return s.next_prayer_in(prayerName, timeStr);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdhanController>()
        ? Get.find<AdhanController>()
        : Get.put(AdhanController());
    final soundController = Get.isRegistered<SoundPickerController>()
        ? Get.find<SoundPickerController>()
        : Get.put(SoundPickerController());
    final n = context.noor;
    final isRtl = SHelperFunctions.isRtl(context);

    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NoorHeader(),
                const SizedBox(height: NoorSpace.sm),
                const LocationPill(),
                const SizedBox(height: NoorSpace.sm),
                Obx(() {
                  final soundName = soundController.adhanSoundName.value;
                  return NoorPill(
                    icon: Icon(
                      Iconsax.volume_high,
                      size: 18,
                      color: n.primary,
                    ),
                    label: soundName.isNotEmpty
                        ? soundName
                        : S.of(context).pick_adhan,
                    onTap: () => showAdhanSoundPickerSheet(context),
                  );
                }),
                const SizedBox(height: NoorSpace.lg),
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(NoorSpace.xxxl),
                        child: CircularProgressIndicator(color: n.primary),
                      ),
                    );
                  }

                  final timings = controller.selectedTimings;
                  final hasLocation = (controller
                              .locationController.country.value
                              .trim()
                              .isNotEmpty &&
                          controller.locationController.city.value
                              .trim()
                              .isNotEmpty) ||
                      (AppPrefs.country.isNotEmpty && AppPrefs.city.isNotEmpty);

                  if (!hasLocation || timings == null) {
                    return EmptyState(
                      message: S.of(context).enter_location,
                      actionLabel: S.of(context).add_location,
                      onAction: () => pickLocation(context),
                      lottie: SImageString.lottieAddLocation,
                    );
                  }

                  final isToday = SHelperFunctions.isSameDay(
                      controller.date.value, DateTime.now());
                  final next = isToday ? controller.nextPrayer() : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Next prayer card (when available)
                      if (next != null) ...[
                        NoorCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: NoorSpace.lg,
                            vertical: NoorSpace.md,
                          ),
                          child: Row(
                            children: [
                              IconTile(
                                icon: next.prayer.icon,
                                tint: next.prayer.tint,
                                size: 44,
                              ),
                              const SizedBox(width: NoorSpace.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: n.gold,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: NoorSpace.xs),
                                        Text(
                                          S.of(context).next_prayer,
                                          style:
                                              NoorText.meta(context).copyWith(
                                            color: n.gold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatNextPrayerDuration(context, next),
                                      style:
                                          NoorText.rowTitle(context).copyWith(
                                        color: n.ink,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                SHelperFunctions.removeTimeZone(
                                  next.prayer.timeFromTimings(
                                    controller.timingsFor(next.at) ??
                                        controller.selectedTimings!,
                                  ),
                                ),
                                style: NoorText.numeral(context, size: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: NoorSpace.md),
                      ],

                      // 2. Day navigator card
                      NoorCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NoorSpace.sm,
                          vertical: NoorSpace.xs,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _onPreviousDay(context, controller),
                              icon: Icon(
                                isRtl
                                    ? Iconsax.arrow_right_3
                                    : Iconsax.arrow_left_2,
                                color: n.primary,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _formatDateTitle(context, controller),
                                  style: NoorText.rowTitle(context).copyWith(
                                    color: n.ink,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _onNextDay(context, controller),
                              icon: Icon(
                                isRtl
                                    ? Iconsax.arrow_left_2
                                    : Iconsax.arrow_right_3,
                                color: n.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NoorSpace.md),

                      // 3. Six prayer rows card
                      NoorCard(
                        padding:
                            const EdgeInsets.symmetric(vertical: NoorSpace.xs),
                        child: Column(
                          children: [
                            for (var i = 0; i < Prayer.all.length; i++) ...[
                              if (i > 0)
                                Divider(
                                  color: n.line,
                                  height: 1,
                                  thickness: 1,
                                  indent: NoorSpace.lg,
                                  endIndent: NoorSpace.lg,
                                ),
                              AdhanLine(
                                prayer: Prayer.all[i],
                                time: SHelperFunctions.removeTimeZone(
                                  Prayer.all[i].timeFromTimings(timings),
                                ),
                                isNext: next?.prayer == Prayer.all[i],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

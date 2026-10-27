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
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_pill.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatDate(String timeStamp) => DateFormat('dd MMM yyyy')
    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp) * 1000));

String _removeTimeZone(String timeString) => timeString.split(' ').first;

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
          icon: Icons.event_busy_outlined,
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
          icon: Icons.event_busy_outlined,
          color: c.noor.danger,
        ),
      );
    } else {
      controller.incrementDay();
    }
  }

  String _formatDateTitle(BuildContext context, AdhanController controller) {
    final d = controller.date.value;
    final isToday = _isSameDay(d, DateTime.now());
    if (isToday) {
      return S.of(context).today;
    }

    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final pt = controller.prayerTime.value;
    final monthList = pt?.data[d.month.toString()];
    final datum =
        (monthList != null && d.day - 1 >= 0 && d.day - 1 < monthList.length)
            ? monthList[d.day - 1]
            : null;

    if (datum != null) {
      return isRtl
          ? "${datum.date.hijri.weekday.ar} ${_formatDate(datum.date.timestamp)}"
          : "${datum.date.gregorian.weekday.en} ${_formatDate(datum.date.timestamp)}";
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
    // Both icons mirror themselves in RTL (matchTextDirection).
    const chevron = Icons.chevron_right_rounded;
    const chevronBack = Icons.chevron_left_rounded;

    return Scaffold(
      backgroundColor: n.paper,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NoorHero(
              art: NoorArt.heroPrayers,
              settings: true,
              title: S.of(context).nav_prayers,
              subtitle: S.of(context).tagline_prayers,
              overlap: const LocationPill(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: NoorSpace.md),
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
                        (AppPrefs.country.isNotEmpty &&
                            AppPrefs.city.isNotEmpty);

                    if (!hasLocation || timings == null) {
                      return EmptyState(
                        message: S.of(context).enter_location,
                        actionLabel: S.of(context).add_location,
                        onAction: () => pickLocation(context),
                        icon: Iconsax.location,
                      );
                    }

                    final isToday =
                        _isSameDay(controller.date.value, DateTime.now());
                    final next = isToday ? controller.nextPrayer() : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (next != null) ...[
                          NoorCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: NoorSpace.lg,
                              vertical: NoorSpace.md,
                            ),
                            child: Row(
                              children: [
                                const IconTile(
                                  svg: SImageString.masjid,
                                  tint: NoorTint.sage,
                                ),
                                const SizedBox(width: NoorSpace.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        S.of(context).next_prayer,
                                        style: NoorText.meta(context),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatNextPrayerDuration(
                                            context, next),
                                        style: NoorText.rowTitle(context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: NoorSpace.sm),
                                Text(
                                  _removeTimeZone(
                                    next.prayer.timeFromTimings(
                                      controller.timingsFor(next.at) ??
                                          controller.selectedTimings!,
                                    ),
                                  ),
                                  style: NoorText.numeral(context, size: 22),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: NoorSpace.md),
                        ],
                        NoorCard(
                          padding: const EdgeInsets.all(NoorSpace.xs),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _onPreviousDay(context, controller),
                                icon: Icon(chevronBack, color: n.primary),
                              ),
                              Expanded(
                                child: Text(
                                  _formatDateTitle(context, controller),
                                  style: NoorText.rowTitle(context),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _onNextDay(context, controller),
                                icon: Icon(chevron, color: n.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: NoorSpace.md),
                        NoorCard(
                          padding: const EdgeInsets.symmetric(
                            vertical: NoorSpace.xs,
                          ),
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
                                  time: _removeTimeZone(
                                    Prayer.all[i].timeFromTimings(timings),
                                  ),
                                  isNext: next?.prayer == Prayer.all[i],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: NoorSpace.md),
                        // Pick Adhan has no other entry point, so it stays.
                        Obx(() {
                          final soundName =
                              soundController.adhanSoundName.value;
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
                      ],
                    );
                  }),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/widgets/adhan_line.dart';
import 'package:noor/features/adhan/widgets/permission_notice.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/features/adhan/widgets/sound_picker_sheet.dart';
import 'package:noor/generals/location_flow.dart';
import 'package:noor/generals/widgets/check_dialog.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/loading_state.dart';
import 'package:noor/generals/widgets/location_pill.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_pill.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
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
          glyph: NoorGlyph.calendar,
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
          glyph: NoorGlyph.calendar,
          color: c.noor.danger,
        ),
      );
    } else {
      controller.incrementDay();
    }
  }

  /// The calendar entry of the selected day, or null before it has loaded.
  dynamic _datum(AdhanController controller) {
    final d = controller.date.value;
    final monthList = controller.prayerTime.value?.data[d.month.toString()];
    return (monthList != null && d.day - 1 >= 0 && d.day - 1 < monthList.length)
        ? monthList[d.day - 1]
        : null;
  }

  String _formatDateTitle(BuildContext context, AdhanController controller) {
    final d = controller.date.value;
    if (_isSameDay(d, DateTime.now())) {
      return S.of(context).today;
    }

    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final datum = _datum(controller);

    if (datum != null) {
      return isRtl
          ? "${datum.date.hijri.weekday.ar} ${_formatDate(datum.date.timestamp)}"
          : "${datum.date.gregorian.weekday.en} ${_formatDate(datum.date.timestamp)}";
    }

    return DateFormat('EEEE, dd MMM yyyy').format(d);
  }

  /// "12 Rajab 1448" from the API date "12-07-1448" and its month name; the
  /// raw API date when the cached calendar has no month name yet.
  String? _formatHijri(BuildContext context, AdhanController controller) {
    final hijri = _datum(controller)?.date.hijri;
    if (hijri == null) return null;
    final parts = (hijri.date as String).split('-');
    final month = hijri.month;
    if (month == null || parts.length != 3) return hijri.date;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    return "${int.tryParse(parts[0]) ?? parts[0]} ${isRtl ? month.ar : month.en} ${parts[2]}";
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
              padding:
                  EdgeInsets.symmetric(horizontal: NoorLayout.gutter(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: NoorSpace.s5),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return LoadingState(message: S.of(context).wait_please);
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

                    if (!hasLocation) {
                      return EmptyState(
                        message: S.of(context).location_needed,
                        actionLabel: S.of(context).add_location,
                        onAction: () => pickLocation(context),
                        icon: Iconsax.location,
                      );
                    }

                    // A saved city with no calendar: the fetch failed, so say
                    // so instead of asking for a location again.
                    if (timings == null) {
                      return EmptyState(
                        danger: true,
                        icon: NoorGlyph.alert,
                        message: S.of(context).prayer_times_failed,
                        actionLabel: S.of(context).try_again,
                        onAction: () =>
                            controller.initController(DateTime.now().year),
                      );
                    }

                    final isToday =
                        _isSameDay(controller.date.value, DateTime.now());
                    final next = isToday ? controller.nextPrayer() : null;

                    // The card's night theme only reaches widgets below it, so the
                    // text here takes the window colours itself.
                    final hijri = _formatHijri(context, controller);

                    return NoorSettle(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (next != null) ...[
                          NoorCard(
                            tone: NoorCardTone.night,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${S.of(context).next_prayer} · ${next.prayer.localizedTitle(context)}',
                                        style: NoorText.bodySm(context)
                                            .copyWith(color: n.onWindowMuted),
                                      ),
                                      const SizedBox(height: NoorSpace.s1),
                                      // The one brass of the screen.
                                      Text(
                                        _removeTimeZone(
                                          next.prayer.timeFromTimings(
                                            controller.timingsFor(next.at) ??
                                                controller.selectedTimings!,
                                          ),
                                        ),
                                        style: NoorText.numeral(context,
                                            size: 48, color: n.brass),
                                      ),
                                      const SizedBox(height: NoorSpace.s1),
                                      Text(
                                        _formatNextPrayerDuration(
                                            context, next),
                                        style: NoorText.body(context)
                                            .copyWith(color: n.onWindow),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: NoorSpace.s6),
                        ],
                        NoorWell(
                          radius: NoorRadius.md,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _onPreviousDay(context, controller),
                                constraints: const BoxConstraints.tightFor(
                                    width: 48, height: 56),
                                icon: Icon(chevronBack, color: n.ink),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatDateTitle(context, controller),
                                      style: NoorText.heading(context),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (hijri != null)
                                      Text(
                                        hijri,
                                        style: NoorText.bodySm(context),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _onNextDay(context, controller),
                                constraints: const BoxConstraints.tightFor(
                                    width: 48, height: 56),
                                icon: Icon(chevron, color: n.ink),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: NoorSpace.s5),
                        const PermissionNotice(),
                        NoorListGroup(
                          children: [
                            for (final prayer in Prayer.all)
                              AdhanLine(
                                prayer: prayer,
                                time: _removeTimeZone(
                                  prayer.timeFromTimings(timings),
                                ),
                                isNext: next?.prayer == prayer,
                              ),
                          ],
                        ),
                        const SizedBox(height: NoorSpace.s6),
                        // Pick Adhan has no other entry point, so it stays.
                        Obx(() {
                          final soundName =
                              soundController.adhanSoundName.value;
                          return NoorPill(
                            icon: Icon(
                              Iconsax.volume_high,
                              size: 18,
                              color: n.ink,
                            ),
                            label: soundName.isNotEmpty
                                ? soundName
                                : S.of(context).pick_adhan,
                            onTap: () => showAdhanSoundPickerSheet(context),
                          );
                        }),
                      ],
                    ));
                  }),
                  // extendBody: the shell reports the floating nav bar as bottom padding.
                  SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + NoorSpace.s4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/controllers/adhan_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/views/widgets/adhan_reminders_sheet.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';

extension PrayerUI on Prayer {
  String localizedTitle(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case Prayer.fajr:
        return s.fajr;
      case Prayer.chourouk:
        return s.sun_rise;
      case Prayer.dhuhr:
        return s.dhuhr;
      case Prayer.asr:
        return s.asr;
      case Prayer.maghrib:
        return s.maghrib;
      case Prayer.isha:
        return s.isha;
    }
  }

  /// Each prayer has its own mark, so the list reads at a glance: the moon
  /// before dawn, the sunrise, the high sun, the low afternoon sun, the sunset,
  /// the night.
  NoorGlyph get glyph => switch (this) {
        Prayer.fajr => NoorGlyph.moonHaze,
        Prayer.chourouk => NoorGlyph.sunrise,
        Prayer.dhuhr => NoorGlyph.sun,
        Prayer.asr => NoorGlyph.sunHaze,
        Prayer.maghrib => NoorGlyph.sunset,
        Prayer.isha => NoorGlyph.moonStars,
      };
}

/// One prayer in the day's list: its sun or moon (a flat mark, not a control),
/// its name, its time (the screen's brass when it is next), the adhan bell on
/// an ornament, and a tap that opens its reminders sheet.
class AdhanLine extends StatelessWidget {
  final Prayer prayer;
  final String time;
  final bool isNext;

  const AdhanLine({
    super.key,
    required this.prayer,
    required this.time,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final controller = Get.find<AdhanController>();

    // Name and time side by side stop fitting past about 1.5x; stack them.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 24;
    final title = Text(
      prayer.localizedTitle(context),
      style: NoorText.heading(context),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    final timeText = Text(
      time,
      style: NoorText.numeral(context, color: isNext ? n.brass : n.ink),
    );

    final rowRadius = isNext ? NoorRadius.pill : NoorRadius.md;
    final row = Material(
      color: Colors.transparent,
      animationDuration: Duration.zero,
      borderRadius: BorderRadius.circular(rowRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(rowRadius),
        onTap: () => showAdhanRemindersSheet(
          context,
          prayer: prayer,
          time: time,
          selectedDate: controller.date.value,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            NoorSpace.s3,
            NoorSpace.s1,
            NoorSpace.s1,
            NoorSpace.s1,
          ),
          child: Row(
            children: [
              // Flat, so it reads as a marker; the bell is the ornament you press.
              SizedBox.square(
                dimension: 40,
                child: Center(
                  child: NoorIcon(prayer.glyph, size: 26, color: n.muted),
                ),
              ),
              const SizedBox(width: NoorSpace.s3),
              Expanded(
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, timeText],
                      )
                    : title,
              ),
              if (!stacked) timeText,
              Obx(() {
                final isEnabled = controller.enabledFor(prayer.key).value;
                return NoorCloudButton(
                  icon: NoorIcon(
                    isEnabled ? NoorGlyph.bell : NoorGlyph.bellOff,
                    color: isEnabled ? n.ink : n.muted,
                  ),
                  tooltip: prayer.localizedTitle(context),
                  onTap: () async {
                    final overlay =
                        Overlay.maybeOf(context, rootOverlay: true);
                    final s = S.of(context);
                    await controller.toggle(prayer.key);
                    final nowEnabled = controller.enabledFor(prayer.key).value;
                    showAlarmSnackBar(
                      overlay,
                      nowEnabled ? s.adhan_enabled : s.adhan_disabled,
                    );
                  },
                );
              }),
              Icon(
                Icons.chevron_right_rounded, // mirrors in RTL
                color: n.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );

    // The current prayer sits in a rounded sunken well inside the group.
    return Padding(
      padding: const EdgeInsets.all(NoorSpace.s1),
      child: isNext ? NoorWell(radius: NoorRadius.pill, child: row) : row,
    );
  }
}

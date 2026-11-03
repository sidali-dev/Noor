import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/widgets/adhan_reminders_sheet.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

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

  /// As in the Prayer times mock: the sun by day, the moon from sunset.
  NoorGlyph get glyph => this == Prayer.maghrib || this == Prayer.isha
      ? NoorGlyph.moon
      : NoorGlyph.sun;
}

/// One prayer in the day's list: its sun or moon (a flat mark, not a control),
/// its name, its time (the screen's brass when it is next), the adhan bell on
/// a puff, and a tap that opens its reminders sheet.
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

    final row = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(NoorRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            showAdhanRemindersSheet(context, prayer: prayer, time: time),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            NoorSpace.s3,
            NoorSpace.s1,
            NoorSpace.s1,
            NoorSpace.s1,
          ),
          child: Row(
            children: [
              // Flat, so it reads as a marker; the bell is the puff you press.
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
                  size: 40,
                  icon: NoorIcon(
                    isEnabled ? NoorGlyph.bell : NoorGlyph.bellOff,
                    color: isEnabled ? n.ink : n.muted,
                  ),
                  tooltip: prayer.localizedTitle(context),
                  onTap: () => controller.toggle(prayer.key),
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

    // The current prayer sits in a sunken well inside the group.
    return Padding(
      padding: const EdgeInsets.all(NoorSpace.s1),
      child: isNext ? NoorWell(radius: NoorRadius.md, child: row) : row,
    );
  }
}

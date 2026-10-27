import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/controllers/adhan_line_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_button.dart';
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

  IconData get icon {
    switch (this) {
      case Prayer.fajr:
      case Prayer.chourouk:
      case Prayer.maghrib:
        return Iconsax.sun_fog;
      case Prayer.dhuhr:
        return Iconsax.sun_1;
      case Prayer.asr:
        return Iconsax.cloud_sunny;
      case Prayer.isha:
        return Iconsax.moon;
    }
  }

  NoorTint get tint {
    switch (this) {
      case Prayer.fajr:
        return NoorTint.blue;
      case Prayer.chourouk:
        return NoorTint.amber;
      case Prayer.dhuhr:
        return NoorTint.sage;
      case Prayer.asr:
        return NoorTint.mint;
      case Prayer.maghrib:
        return NoorTint.lilac;
      case Prayer.isha:
        return NoorTint.blue;
    }
  }
}

class AdhanLine extends StatefulWidget {
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
  State<AdhanLine> createState() => _AdhanLineState();
}

class _AdhanLineState extends State<AdhanLine> {
  bool _isExpanded = false;
  int _minutes = 10;

  void _incrementMinutes() {
    setState(() {
      if (_minutes < 60) {
        _minutes++;
        if (_minutes == 0) _minutes = 1;
      }
    });
  }

  void _decrementMinutes() {
    setState(() {
      if (_minutes > -60) {
        _minutes--;
        if (_minutes == 0) _minutes = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final controller = Get.find<AdhanController>();
    final s = S.of(context);
    final reminders = AdhanScheduler.reminders(widget.prayer);

    final rtl = Directionality.of(context) == TextDirection.rtl;
    final next = widget.isNext;
    final radius = BorderRadius.circular(NoorRadius.tile);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xs),
      child: Material(
        color: next ? n.tintBg(NoorTint.sage) : Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NoorSpace.md,
              NoorSpace.sm,
              NoorSpace.xs,
              NoorSpace.sm,
            ).resolve(Directionality.of(context)),
            child: Column(
              children: [
                Row(
                  children: [
                    if (next)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: n.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.prayer.icon,
                          size: 22,
                          color: n.onPrimary,
                        ),
                      )
                    else
                      IconTile(
                        icon: widget.prayer.icon,
                        tint: widget.prayer.tint,
                        size: 44,
                      ),
                    const SizedBox(width: NoorSpace.md),
                    Expanded(
                      child: Text(
                        widget.prayer.localizedTitle(context),
                        style: NoorText.rowTitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(widget.time, style: NoorText.numeral(context)),
                    Obx(() {
                      final isEnabled =
                          controller.enabledFor(widget.prayer.key).value;
                      return IconButton(
                        icon: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: next
                                ? n
                                    .tintFg(NoorTint.sage)
                                    .withValues(alpha: 0.14)
                                : null,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEnabled
                                ? Iconsax.volume_high
                                : Iconsax.volume_cross,
                            color: isEnabled ? n.primary : n.muted,
                            size: 20,
                          ),
                        ),
                        constraints: const BoxConstraints.tightFor(
                            width: 48, height: 48),
                        tooltip: widget.prayer.localizedTitle(context),
                        onPressed: () => controller.toggle(widget.prayer.key),
                      );
                    }),
                    // Points to the end; turns down when the reminders open.
                    AnimatedRotation(
                      turns: _isExpanded ? (rtl ? -0.25 : 0.25) : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.chevron_right_rounded, // mirrors in RTL
                        color: n.muted,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: _isExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: NoorSpace.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final reminder in reminders) ...[
                                Container(
                                  margin: const EdgeInsets.only(
                                      bottom: NoorSpace.sm),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: NoorSpace.md,
                                    vertical: NoorSpace.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: n.isDark ? n.line : n.paper,
                                    borderRadius:
                                        BorderRadius.circular(NoorRadius.input),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.alarm_on_rounded,
                                        size: 18,
                                        color: n.primary,
                                      ),
                                      const SizedBox(width: NoorSpace.sm),
                                      Expanded(
                                        child: Text(
                                          getAlarmText(
                                              context, reminder.minutes),
                                          style:
                                              NoorText.body(context).copyWith(
                                            fontSize: 13,
                                            color: n.ink,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await AdhanScheduler.removeReminder(
                                            widget.prayer,
                                            reminder.slot,
                                          );
                                          if (mounted) setState(() {});
                                        },
                                        child: Text(
                                          s.remove,
                                          style: TextStyle(
                                            color: n.danger,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (reminders.length < 2) ...[
                                const SizedBox(height: NoorSpace.xs),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: n.isDark ? n.line : n.paper,
                                        borderRadius: BorderRadius.circular(
                                            NoorRadius.input),
                                        border: Border.all(color: n.line),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_rounded,
                                                size: 18),
                                            onPressed: _decrementMinutes,
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            color: n.ink,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Text(
                                                '${_minutes > 0 ? "+$_minutes" : _minutes} ${s.minute_short}',
                                                style: NoorText.numeral(context,
                                                    size: 14),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_rounded,
                                                size: 18),
                                            onPressed: _incrementMinutes,
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            color: n.ink,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: NoorSpace.md),
                                    Expanded(
                                      child: NoorButton(
                                        label: s.set_new_alarm,
                                        variant: NoorButtonVariant.tonal,
                                        onPressed: () async {
                                          await AdhanScheduler.addReminder(
                                            widget.prayer,
                                            _minutes,
                                          );
                                          if (mounted) setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/controllers/adhan_line_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_motion.dart';
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

  /// The Hilal glyph when Hilal has one for this prayer (the moon); the rest
  /// fall back to [icon], iconsax Linear.
  NoorGlyph? get glyph => this == Prayer.isha ? NoorGlyph.moon : null;
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
    // Name and time side by side stop fitting past about 1.5x; stack them.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 24;
    final title = Text(
      widget.prayer.localizedTitle(context),
      style: NoorText.heading(context),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    final time = Text(widget.time, style: NoorText.numeral(context));
    final radius = BorderRadius.circular(NoorRadius.md);

    final stepper = NoorWell(
      radius: NoorRadius.md,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Iconsax.minus, size: 18),
            onPressed: _decrementMinutes,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            color: n.ink,
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${_minutes > 0 ? "+$_minutes" : _minutes} ${s.minute_short}',
                  style: NoorText.numeral(context, size: 16),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const NoorIcon(NoorGlyph.plus, size: 18),
            onPressed: _incrementMinutes,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            color: n.ink,
          ),
        ],
      ),
    );
    final addButton = NoorButton(
      label: s.set_new_alarm,
      variant: NoorButtonVariant.tonal,
      onPressed: () async {
        await AdhanScheduler.addReminder(
          widget.prayer,
          _minutes,
        );
        if (mounted) setState(() {});
      },
    );

    final row = Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            NoorSpace.s3,
            NoorSpace.s2,
            NoorSpace.s1,
            NoorSpace.s2,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.prayer.glyph != null)
                    NoorIcon(widget.prayer.glyph!, size: 24)
                  else
                    Icon(widget.prayer.icon, size: 24, color: n.ink),
                  const SizedBox(width: NoorSpace.s3),
                  Expanded(
                    child: stacked
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [title, time],
                          )
                        : title,
                  ),
                  if (!stacked) time,
                  Obx(() {
                    final isEnabled =
                        controller.enabledFor(widget.prayer.key).value;
                    return IconButton(
                      icon: NoorIcon(
                        isEnabled ? NoorGlyph.bell : NoorGlyph.bellOff,
                        color: isEnabled ? n.ink : n.muted,
                        size: 22,
                      ),
                      constraints:
                          const BoxConstraints.tightFor(width: 48, height: 48),
                      tooltip: widget.prayer.localizedTitle(context),
                      onPressed: () => controller.toggle(widget.prayer.key),
                    );
                  }),
                  // Points to the end; turns down when the reminders open.
                  AnimatedRotation(
                    turns: _isExpanded ? (rtl ? -0.25 : 0.25) : 0,
                    duration: noorDuration(
                        context, const Duration(milliseconds: 220)),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.chevron_right_rounded, // mirrors in RTL
                      color: n.muted,
                      size: 22,
                    ),
                  ),
                ],
              ),
              _RevealSize(
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: NoorSpace.s3,
                          end: NoorSpace.s3,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final reminder in reminders) ...[
                              NoorWell(
                                radius: NoorRadius.md,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: NoorSpace.s3,
                                    end: NoorSpace.s1,
                                  ),
                                  child: Row(
                                    children: [
                                      NoorIcon(
                                        NoorGlyph.bell,
                                        size: 18,
                                        color: n.ink,
                                      ),
                                      const SizedBox(width: NoorSpace.s2),
                                      Expanded(
                                        child: Text(
                                          getAlarmText(
                                              context, reminder.minutes),
                                          style: NoorText.bodySm(context)
                                              .copyWith(color: n.ink),
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(48, 48),
                                        ),
                                        onPressed: () async {
                                          await AdhanScheduler.removeReminder(
                                            widget.prayer,
                                            reminder.slot,
                                          );
                                          if (mounted) setState(() {});
                                        },
                                        child: Text(
                                          s.remove,
                                          style: NoorText.bodySm(context)
                                              .copyWith(color: n.danger),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: NoorSpace.s2),
                            ],
                            if (reminders.length < 2)
                              stacked
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                          child: stepper,
                                        ),
                                        const SizedBox(height: NoorSpace.s2),
                                        addButton,
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        stepper,
                                        const SizedBox(width: NoorSpace.s3),
                                        Expanded(child: addButton),
                                      ],
                                    ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );

    // The current prayer sits in a sunken well inside the group.
    return Padding(
      padding: const EdgeInsets.all(NoorSpace.s1),
      child: next ? NoorWell(radius: NoorRadius.md, child: row) : row,
    );
  }
}

/// [child] easing open and shut, or simply there under Reduce Motion: an
/// AnimatedSize with a zero duration re-dirties itself during layout and throws.
class _RevealSize extends StatelessWidget {
  final Widget child;

  const _RevealSize({required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

import 'dart:math' as math;

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:noor/bottom_navigation.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/generals/widgets/arch_frame.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Latin and Arabic name of each prayer, keyed by [Prayer.key]. Both show in
/// every locale, stacked at equal weight.
const _names = {
  'fajr': ('Fajr', 'الفجر'),
  'chourouk': ('Chourouk', 'الشروق'),
  'dhuhr': ('Dhuhr', 'الظهر'),
  'asr': ('Asr', 'العصر'),
  'maghrib': ('Maghrib', 'المغرب'),
  'isha': ('Isha', 'العشاء'),
};

class AdhanRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AdhanRingScreen({super.key, required this.alarmSettings});

  @override
  State<AdhanRingScreen> createState() => _AdhanRingScreenState();
}

class _AdhanRingScreenState extends State<AdhanRingScreen> {
  /// Below this the screen scrolls: room for the arch, the time, a note and two
  /// buttons.
  static const double _minHeight = 560;
  static const double _maxNoteHeight = 120;
  static const double _timeHeight = 72;

  @override
  void dispose() {
    Alarm.stop(widget.alarmSettings.id);
    super.dispose();
  }

  Prayer? _prayerFromBaseId(int baseId) {
    for (final prayer in Prayer.all) {
      if (prayer.adhanId == baseId ||
          prayer.alarmId1 == baseId ||
          prayer.alarmId2 == baseId) {
        return prayer;
      }
    }
    return null;
  }

  void _openAdhkar() {
    Alarm.stop(widget.alarmSettings.id).then((_) {
      Get.offAll(() => const SBottomNavigation(pageIndex: 2));
    });
  }

  void _close() {
    // Pushed over the app (bottom_navigation), so pop back instead of exiting.
    Alarm.stop(widget.alarmSettings.id).then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final baseId = AdhanScheduler.baseOf(widget.alarmSettings.id);
    final prayer = _prayerFromBaseId(baseId);
    final names = prayer == null ? null : _names[prayer.key];

    final title = widget.alarmSettings.notificationSettings.title;
    final body = widget.alarmSettings.notificationSettings.body;
    // 'en' keeps Western digits 0-9 in every locale.
    final formattedTime =
        DateFormat('HH:mm', 'en').format(widget.alarmSettings.dateTime);

    // The ground is the night sky in both themes, so the system bars take
    // light icons whatever the theme.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: noorSystemOverlay(Brightness.dark),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: n.window,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                NoorLayout.gutter(context),
                NoorSpace.s5,
                NoorLayout.gutter(context),
                NoorSpace.s4,
              ),
              // Short phones and large text scroll the whole screen rather than
              // squeeze the arch to nothing or push the buttons off it.
              child: LayoutBuilder(
                builder: (context, view) => SingleChildScrollView(
                  child: SizedBox(
                    height: math.max(view.maxHeight, _minHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, box) {
                              final width = box.maxWidth <
                                      box.maxHeight / ArchFrame.aspect
                                  ? box.maxWidth
                                  : box.maxHeight / ArchFrame.aspect;
                              // Spare height goes to the sky above the arch,
                              // so the arch stays close to its time.
                              return Align(
                                alignment: Alignment.bottomCenter,
                                // The active alarm screen is one of the loops
                                // Hilal allows: the sky twinkles.
                                child: NoorTwinkle(
                                  builder: (context, twinkle) => ArchFrame(
                                    width: width,
                                    twinkle: twinkle,
                                    child: _ArchContent(
                                      unit: width / 240,
                                      names: names,
                                      title: title,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: NoorSpace.s4),
                        // Out of the arch, where it has room to be the largest
                        // thing on the screen. Shrinks rather than scales.
                        SizedBox(
                          height: _timeHeight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formattedTime,
                              textDirection: TextDirection.ltr,
                              style: NoorText.numeral(context,
                                  size: 64, color: n.onWindow),
                            ),
                          ),
                        ),
                        // Reminders say how long until the prayer; keep the
                        // sentence, and let a long one scroll in its own box.
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: NoorSpace.s1),
                          ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxHeight: _maxNoteHeight),
                            child: SingleChildScrollView(
                              child: Text(
                                body,
                                style: NoorText.bodySm(context)
                                    .copyWith(color: n.onWindowMuted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: NoorSpace.s5),
                        NoorButton(
                          label: S.of(context).stop_adhan,
                          onPressed: _close,
                          variant: NoorButtonVariant.onWindow,
                        ),
                        const SizedBox(height: NoorSpace.s2),
                        NoorButton(
                          label: S.of(context).open_adhkar,
                          onPressed: _openAdhkar,
                          variant: NoorButtonVariant.ghostOnWindow,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The names in the arch's night window: Latin and Arabic at equal weight, kept
/// clear of the cloud scroll, which starts at artwork y = 168. Scaled down as a
/// block when a large text scale would not fit the window, never clipped.
class _ArchContent extends StatelessWidget {
  /// One ArchFrame artwork unit in dp.
  final double unit;
  final (String, String)? names;
  final String title;

  const _ArchContent({
    required this.unit,
    required this.names,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final names = this.names;
    return SizedBox(
      width: 150 * unit,
      height: 100 * unit,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (names != null) ...[
              Text(
                names.$1,
                textDirection: TextDirection.ltr,
                style: NoorText.displayLg(context).copyWith(color: n.onWindow),
              ),
              Text(
                names.$2,
                textDirection: TextDirection.rtl,
                style:
                    NoorText.arabicDisplay(context).copyWith(color: n.onWindow),
              ),
            ] else
              Text(
                title,
                textAlign: TextAlign.center,
                style: NoorText.display(context).copyWith(color: n.onWindow),
              ),
          ],
        ),
      ),
    );
  }
}

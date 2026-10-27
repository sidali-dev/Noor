import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:noor/bottom_navigation.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_mark.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/helpers/helper_functions.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class AdhanRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AdhanRingScreen({super.key, required this.alarmSettings});

  @override
  State<AdhanRingScreen> createState() => _AdhanRingScreenState();
}

class _AdhanRingScreenState extends State<AdhanRingScreen> {
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

  IconData _prayerIcon(Prayer? prayer) {
    switch (prayer) {
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
      case null:
        return Iconsax.sun_fog;
    }
  }

  NoorTint _prayerTint(Prayer? prayer) {
    switch (prayer) {
      case Prayer.fajr:
      case Prayer.chourouk:
      case Prayer.asr:
        return NoorTint.amber;
      case Prayer.dhuhr:
        return NoorTint.sage;
      case Prayer.maghrib:
        return NoorTint.lilac;
      case Prayer.isha:
        return NoorTint.blue;
      case null:
        return NoorTint.sage;
    }
  }

  void _openAdhkar() {
    Alarm.stop(widget.alarmSettings.id).then((_) {
      Get.offAll(() => const SBottomNavigation(pageIndex: 2));
    });
  }

  void _close() {
    Alarm.stop(widget.alarmSettings.id).then((_) {
      SystemNavigator.pop(animated: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseId = AdhanScheduler.baseOf(widget.alarmSettings.id);
    final prayer = _prayerFromBaseId(baseId);
    // Legacy helper reference for base alarm colour mapping.
    final _ = SHelperFunctions.getAlarmColor(baseId);

    final title = widget.alarmSettings.notificationSettings.title;
    final body = widget.alarmSettings.notificationSettings.body;
    final formattedTime =
        DateFormat('HH:mm').format(widget.alarmSettings.dateTime);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.noor.paper,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: NoorSpace.xl,
                  vertical: NoorSpace.xl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (NoorSpace.xl * 2),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: NoorMark(size: 32),
                        ),
                        const Spacer(),
                        const SizedBox(height: NoorSpace.xl),
                        Center(
                          child: IconTile(
                            icon: _prayerIcon(prayer),
                            tint: _prayerTint(prayer),
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: NoorSpace.xxl),
                        if (title.isNotEmpty) ...[
                          Text(
                            title,
                            style: NoorText.display(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: NoorSpace.md),
                        ],
                        Text(
                          formattedTime,
                          style: NoorText.numeral(context, size: 56),
                          textAlign: TextAlign.center,
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: NoorSpace.md),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: NoorSpace.md,
                            ),
                            child: Text(
                              body,
                              style: NoorText.body(context).copyWith(
                                color: context.noor.muted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        const Spacer(),
                        const SizedBox(height: NoorSpace.xxxl),
                        NoorButton(
                          label: S.of(context).open_adhkar,
                          onPressed: _openAdhkar,
                          variant: NoorButtonVariant.primary,
                        ),
                        const SizedBox(height: NoorSpace.md),
                        NoorButton(
                          label: S.of(context).close,
                          onPressed: _close,
                          variant: NoorButtonVariant.tonal,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

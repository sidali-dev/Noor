import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:noor/bottom_navigation.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/widgets/adhan_line.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_mark.dart';
import 'package:noor/generated/l10n.dart';
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
    final baseId = AdhanScheduler.baseOf(widget.alarmSettings.id);
    final prayer = _prayerFromBaseId(baseId);

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
                            icon: prayer?.icon ?? Iconsax.sun_fog,
                            tint: prayer?.tint ?? NoorTint.sage,
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

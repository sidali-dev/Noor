import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:noor/core/services/adhan_channels.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// One calm sentence and Open settings, in a sunken well, when notifications,
/// or on Android exact alarms or full-screen alerts, are off and the adhan
/// cannot ring or cannot show its screen. It only reads the status, never
/// requests it, and checks again on return from settings. Nothing shows while
/// all are granted.
class PermissionNotice extends StatefulWidget {
  const PermissionNotice({super.key});

  @override
  State<PermissionNotice> createState() => _PermissionNoticeState();
}

class _PermissionNoticeState extends State<PermissionNotice>
    with WidgetsBindingObserver {
  bool _notifications = true;
  bool _alarms = true;
  bool _fullScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final notifications = await Permission.notification.isGranted;
      final alarms =
          !Alarm.android || await Permission.scheduleExactAlarm.isGranted;
      final fullScreen =
          !Alarm.android || await AppChannel.canUseFullScreenIntent();
      // Granted from settings: nothing was scheduled while it was off.
      if (notifications && !_notifications) AdhanScheduler.sync();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _alarms = alarms;
          _fullScreen = fullScreen;
        });
      }
    } catch (_) {
      // ponytail: status unreadable (no plugin, as in tests): say nothing.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_notifications && _alarms && _fullScreen) {
      return const SizedBox.shrink();
    }
    final s = S.of(context);
    // The one that stops the adhan ringing at all comes first.
    final (text, open) = !_notifications
        ? (s.notifications_off, openAppSettings)
        : !_alarms
            ? (s.alarms_off, openAppSettings)
            : (s.full_screen_off, AppChannel.openFullScreenIntentSettings);

    return Padding(
      padding: const EdgeInsets.only(bottom: NoorSpace.s5),
      child: NoorWell(
        radius: NoorRadius.md,
        child: Padding(
          padding: const EdgeInsets.all(NoorSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ExcludeSemantics(child: NoorIcon(NoorGlyph.bellOff)),
                  const SizedBox(width: NoorSpace.s3),
                  Expanded(
                    child: Text(text, style: NoorText.body(context)),
                  ),
                ],
              ),
              const SizedBox(height: NoorSpace.s4),
              NoorButton(
                label: s.open_settings,
                variant: NoorButtonVariant.tonal,
                onPressed: open,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// One calm sentence and Open settings, in a sunken well, when notifications
/// or (on Android) exact alarms are off and the adhan cannot ring. It only
/// reads the status, never requests it, and checks again on return from
/// settings. Nothing shows while both are granted.
class PermissionNotice extends StatefulWidget {
  const PermissionNotice({super.key});

  @override
  State<PermissionNotice> createState() => _PermissionNoticeState();
}

class _PermissionNoticeState extends State<PermissionNotice>
    with WidgetsBindingObserver {
  bool _notifications = true;
  bool _alarms = true;

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
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _alarms = alarms;
        });
      }
    } catch (_) {
      // ponytail: status unreadable (no plugin, as in tests): say nothing.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_notifications && _alarms) return const SizedBox.shrink();
    final s = S.of(context);

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
                    child: Text(
                      _notifications ? s.alarms_off : s.notifications_off,
                      style: NoorText.body(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NoorSpace.s4),
              NoorButton(
                label: s.open_settings,
                variant: NoorButtonVariant.tonal,
                onPressed: openAppSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:noor/features/adhan/adhan_ring_screen.dart';
import 'package:noor/features/adhan/models/adhan_ring.dart';

/// The ring screen as a route in the app, for iOS: nothing shows over its lock
/// screen, so the alarm's notification opens the app and this goes on top.
/// Android has its own activity for it (AdhanActivity).
class InAppAdhanRing extends StatefulWidget {
  final AlarmSettings alarm;

  /// After the adhan stops and this route has gone.
  final VoidCallback onOpenAthkar;

  const InAppAdhanRing({
    super.key,
    required this.alarm,
    required this.onOpenAthkar,
  });

  @override
  State<InAppAdhanRing> createState() => _InAppAdhanRingState();
}

class _InAppAdhanRingState extends State<InAppAdhanRing> {
  late final AdhanRing _ring = AdhanRing.of(
    id: widget.alarm.id,
    alarmTime: widget.alarm.dateTime,
    title: widget.alarm.notificationSettings.title,
  );
  StreamSubscription<dynamic>? _ringing;
  bool _wasRinging = false;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    // A non-looping adhan ends by itself, and a stop from the notification
    // bypasses the buttons: either way the screen goes.
    _ringing = Alarm.ringing.listen((set) {
      if (set.containsId(widget.alarm.id)) {
        _wasRinging = true;
      } else if (_wasRinging) {
        _leave();
      }
    });
  }

  @override
  void dispose() {
    _ringing?.cancel();
    super.dispose();
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pop();
  }

  Future<void> _stop() async {
    await Alarm.stop(widget.alarm.id);
    _leave();
  }

  Future<void> _openAthkar() async {
    await _stop();
    widget.onOpenAthkar();
  }

  @override
  Widget build(BuildContext context) => AdhanRingScreen(
        ring: _ring,
        onStop: _stop,
        onOpenAthkar: _openAthkar,
      );
}

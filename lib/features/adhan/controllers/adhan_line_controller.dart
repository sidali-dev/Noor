import 'package:flutter/material.dart';
import 'package:noor/generated/l10n.dart';

String getAlarmText(BuildContext context, int minutes) {
  final s = S.of(context);
  final absMin = minutes.abs();
  final minStr = '$absMin ${s.minute_short}';
  if (minutes > 0) {
    return '${s.alarm_set_for} $minStr ${s.after_adhan}';
  } else {
    return '${s.alarm_set_for} $minStr ${s.before_adhan}';
  }
}

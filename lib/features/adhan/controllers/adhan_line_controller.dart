import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';

class AdhanLineController extends GetxController {
  final RxBool isExpanded = false.obs;
  final RxInt time = 0.obs;

  late RxBool isAlarm1Active = false.obs;
  late RxBool isAlarm2Active = false.obs;
  late RxBool isAlarmFull = false.obs;

  void onAlarmExpanded(
      {required String alarmKey1, required String alarmKey2}) {
    isAlarm1Active.value =
        AppPrefs.reminderActive(int.tryParse(alarmKey1) ?? 0);
    isAlarm2Active.value =
        AppPrefs.reminderActive(int.tryParse(alarmKey2) ?? 0);

    isAlarmFull.value = isAlarm1Active.value && isAlarm2Active.value;
  }

  void isAlarmSet({required String alarmKey, required int alarmNumber}) {
    final active = AppPrefs.reminderActive(int.tryParse(alarmKey) ?? 0);
    if (alarmNumber == 1) {
      isAlarm1Active.value = active;
    } else if (alarmNumber == 2) {
      isAlarm2Active.value = active;
    }

    isAlarmFull.value = isAlarm1Active.value && isAlarm2Active.value;
  }

  void incrementTime() {
    if (time.value < 60) {
      time.value++;
    }
  }

  void decrementTime() {
    if (time.value > -60) {
      time.value--;
    }
  }

  @Deprecated('Use AdhanScheduler.sync()')
  static Future<void> scheduleAlarms() async {
    await AdhanScheduler.sync();
  }

  Future<void> addAlarm(
      String alarmActivationKey1,
      String alarmActivationKey2,
      String alarmDurationKey1,
      String alarmDurationKey2,
      String timing) async {
    final prayer = Prayer.all.where((p) =>
        p.alarmId1.toString() == alarmActivationKey1 ||
        p.alarmId2.toString() == alarmActivationKey2).firstOrNull;

    if (prayer != null) {
      await AdhanScheduler.addReminder(prayer, time.value);
    }
  }

  @Deprecated('Use AdhanScheduler')
  static Future<void> setUpAdhanAlarm({
    required DateTime date,
    required String timings,
    required String tomorrowTimings,
    required int alarmId,
    required String alarmDurationKey,
  }) async {
    await AdhanScheduler.sync();
  }

  bool isAlarmsFull({required String key1, required String key2}) {
    final a1 = AppPrefs.reminderActive(int.tryParse(key1) ?? 0);
    final a2 = AppPrefs.reminderActive(int.tryParse(key2) ?? 0);
    return a1 && a2;
  }

  String getAlarmText(BuildContext context, int duration) {
    if (duration > 0) {
      return "${S.of(context).alarm_set_for} $duration ${S.of(context).minute_short} ${S.of(context).after_adhan}";
    }
    return "${S.of(context).alarm_set_for} ${duration.abs()} ${S.of(context).minute_short} ${S.of(context).before_adhan}";
  }
}

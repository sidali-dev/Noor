import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/local_storage/services/sharedpreferences_service.dart';
import '../models/prayer_time.dart';
import '../models/sub_models.dart/timings.dart';

class AdhanLineController extends GetxController {
  final RxBool isExpanded = false.obs;
  final RxInt time = 0.obs;

  incrementTime() {
    if (time.value < 60) {
      time.value++;
    }
  }

  decrementTime() {
    if (time.value > -60) {
      time.value--;
    }
  }

  scheduleAlarms() async {
    DateTime date = DateTime.now();

    String? adhanYear = SharedPrefService.getString("Adhan${date.year}");

    //in case notification permission isn't granted
    if (!await Permission.notification.isGranted) {
      return;
    }

    //in case the adhan data isn't set up
    if (adhanYear == null) {
      return;
    }

    PrayerTime prayerTime = PrayerTime.fromJson(jsonDecode(adhanYear));

    Timings timings =
        prayerTime.data[date.month.toString()]![date.day - 1].timings;

    Timings tomorrowTimings =
        prayerTime.data[date.month.toString()]![date.day].timings;

    await setUpAdhanAlarm(
        date: date,
        timings: timings.fajr,
        tomorrowTimings: tomorrowTimings.fajr,
        alarmId: 101,
        alarmDurationKey: "fajr_alarm_1_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.fajr,
        tomorrowTimings: tomorrowTimings.fajr,
        alarmId: 102,
        alarmDurationKey: "fajr_alarm_2_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.sunrise,
        tomorrowTimings: tomorrowTimings.sunrise,
        alarmId: 201,
        alarmDurationKey: "chourouk_alarm_1_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.sunrise,
        tomorrowTimings: tomorrowTimings.sunrise,
        alarmId: 202,
        alarmDurationKey: "chourouk_alarm_2_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.dhuhr,
        tomorrowTimings: tomorrowTimings.dhuhr,
        alarmId: 301,
        alarmDurationKey: "dhuhr_alarm_1_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.dhuhr,
        tomorrowTimings: tomorrowTimings.dhuhr,
        alarmId: 302,
        alarmDurationKey: "dhuhr_alarm_2_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.asr,
        tomorrowTimings: tomorrowTimings.asr,
        alarmId: 401,
        alarmDurationKey: "asr_alarm_1_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.asr,
        tomorrowTimings: tomorrowTimings.asr,
        alarmId: 402,
        alarmDurationKey: "asr_alarm_2_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.maghrib,
        tomorrowTimings: tomorrowTimings.maghrib,
        alarmId: 501,
        alarmDurationKey: "maghrib_alarm_1_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.maghrib,
        tomorrowTimings: tomorrowTimings.maghrib,
        alarmId: 502,
        alarmDurationKey: "maghrib_alarm_2_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.isha,
        tomorrowTimings: tomorrowTimings.isha,
        alarmId: 601,
        alarmDurationKey: "isha_alarm_1_duration");

    await setUpAdhanAlarm(
        date: date,
        timings: timings.isha,
        tomorrowTimings: tomorrowTimings.isha,
        alarmId: 602,
        alarmDurationKey: "isha_alarm_2_duration");
  }

  addAlarm(String alarmActivationKey1, String alarmActivationKey2,
      String alarmDurationKey1, String alarmDurationKey2, String timing) async {
    //in case notification permission isn't granted
    if (!await Permission.notification.isGranted) {
      return;
    }

    bool? alarm1IsUp = SharedPrefService.getBool(alarmActivationKey1);

    if (alarm1IsUp == null || alarm1IsUp == false) {
      await SharedPrefService.setBool(alarmActivationKey1, true);

      await SharedPrefService.setInt(alarmDurationKey1, time.value);

      await setUpAdhanAlarm(
          date: DateTime.now(),
          timings: timing,
          tomorrowTimings: timing,
          alarmId: int.parse(alarmActivationKey1),
          alarmDurationKey: alarmDurationKey1);

      return;
    }

    bool? alarm2IsUp = SharedPrefService.getBool(alarmActivationKey2);

    if (alarm2IsUp == null || alarm2IsUp == false) {
      SharedPrefService.setBool(alarmActivationKey2, true);

      await SharedPrefService.setInt(alarmDurationKey2, time.value);

      await setUpAdhanAlarm(
          date: DateTime.now(),
          timings: timing,
          tomorrowTimings: timing,
          alarmId: int.parse(alarmActivationKey2),
          alarmDurationKey: alarmDurationKey2);

      return;
    }
  }

  static Future setUpAdhanAlarm(
      {required DateTime date,
      required String timings,
      required String tomorrowTimings,
      required int alarmId,
      required String alarmDurationKey}) async {
    if (SharedPrefService.getBool(alarmId.toString()) ?? false) {
      int duration = SharedPrefService.getInt(alarmDurationKey)!;
      if (date !=
          SHelperFunctions.turnTimingToDate(timings)
              .add(Duration(minutes: duration))) {
        await SHelperFunctions.setUpAlarm(
            id: alarmId,
            title: "aa", //ADD LATER
            body: "bb", //ADD LATER
            stopButtonText: SHelperFunctions.getAdhanStopText(),
            dateTime: date,
            timing: SHelperFunctions.turnTimingToDate(timings)
                .add(Duration(minutes: duration)),
            tomorrowTiming: SHelperFunctions.turnTimingToDate(tomorrowTimings)
                .add(Duration(minutes: duration, days: 1)),
            assetAudioPath: SharedPrefService.getString("adhan_sound_path")!);
      }
    } else {
      await SHelperFunctions.cancelAlarm(alarmId);
    }
  }

  bool isAlarmsFull({required String key1, required String key2}) {
    bool a1 = SharedPrefService.getBool(key1) ?? false;
    bool a2 = SharedPrefService.getBool(key2) ?? false;

    if (a1 == true && a2 == true) {
      return true;
    } else {
      return false;
    }
  }

  String getAlarmText(BuildContext context, int duration) {
    if (duration > 0) {
      return "${S.of(context).alarm_set_for} $duration ${S.of(context).minute_short} ${S.of(context).after_adhan}";
    } else {}
    return "${S.of(context).alarm_set_for} ${duration.abs()} ${S.of(context).minute_short} ${S.of(context).before_adhan}";
  }
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // setNewAlarm(int prayerAlarmId, String timing, int difference) {
  //   List<int> alarmsId = checkExtraAlarms(prayerAlarmId);
  //   String alarmsIdText = "";

  //   DateTime dateTime = DateFormat('HH:mm').parse(timing);
  //   DateTime date = DateTime(DateTime.now().year, DateTime.now().month,
  //       DateTime.now().day, dateTime.hour, dateTime.minute);
  //   if (DateTime.now().isBefore(date)) {
  //     DateTime alarmTime = date.add(Duration(minutes: difference));
  //     String hourAndMinute = "${alarmTime.hour}:${alarmTime.minute}";

  //     if (alarmsId.isNotEmpty) {
  //       int lastAlarm = alarmsId.last;
  //       SHelperFunctions.setUpAlarm(
  //           id: lastAlarm + 1,
  //           dateTime: DateTime.now(),
  //           assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
  //           timing: hourAndMinute,
  //           tomorrowTiming: hourAndMinute,
  //           title: SHelperFunctions.getAlarmNotificationTitle(prayerAlarmId),
  //           body: SHelperFunctions.getAlarmNotificationBody(
  //               prayerAlarmId, difference.toString(), alarmTime, date),
  //           stopButtonText: SHelperFunctions.getAdhanStopText());
  //       // alarmsId.map((e) => alarmsIdText = "${alarmsIdText}${lastAlarm+1}-")
  //     } else {
  //       SHelperFunctions.setUpAlarm(
  //           id: prayerAlarmId + 1,
  //           dateTime: DateTime.now(),
  //           assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
  //           timing: hourAndMinute,
  //           tomorrowTiming: hourAndMinute,
  //           title: SHelperFunctions.getAlarmNotificationTitle(prayerAlarmId),
  //           body: SHelperFunctions.getAlarmNotificationBody(
  //               prayerAlarmId, difference.toString(), alarmTime, date),
  //           stopButtonText: SHelperFunctions.getAdhanStopText());
  //     }
  //   } else {
  //     DateTime alarmTime = date.add(Duration(days: 1, minutes: difference));
  //     String hourAndMinute = "${alarmTime.hour}:${alarmTime.minute}";

  //     if (alarmsId.isNotEmpty) {
  //       int lastAlarm = alarmsId.last;
  //       SHelperFunctions.setUpAlarm(
  //           id: lastAlarm + 1,
  //           dateTime: DateTime.now(),
  //           assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
  //           timing: hourAndMinute,
  //           tomorrowTiming: hourAndMinute,
  //           title: SHelperFunctions.getAlarmNotificationTitle(prayerAlarmId),
  //           body: SHelperFunctions.getAlarmNotificationBody(
  //               prayerAlarmId, difference.toString(), alarmTime, date),
  //           stopButtonText: SHelperFunctions.getAdhanStopText());
  //     } else {
  //       SHelperFunctions.setUpAlarm(
  //           id: prayerAlarmId + 1,
  //           dateTime: DateTime.now(),
  //           assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
  //           timing: hourAndMinute,
  //           tomorrowTiming: hourAndMinute,
  //           title: SHelperFunctions.getAlarmNotificationTitle(prayerAlarmId),
  //           body: SHelperFunctions.getAlarmNotificationBody(
  //               prayerAlarmId, difference.toString(), alarmTime, date),
  //           stopButtonText: SHelperFunctions.getAdhanStopText());
  //     }
  //   }

  //   // checkExtraAlarms(prayerAlarmId);
  //   // SHelperFunctions.setUpAlarm(id: id, dateTime: dateTime, assetAudioPath: assetAudioPath, timing: timing, tomorrowTiming: tomorrowTiming, title: title, body: body, stopButtonText: stopButtonText)
  // }

  // List<int> checkExtraAlarms(int prayerAlarmId) {
  //   prayerAlarmId = prayerAlarmId * 100;
  //   List<int> savedAlarmsId = [];
  //   String savedAlarms =
  //       SharedPrefService.getString(prayerAlarmId.toString()) ?? "";
  //   if (savedAlarms != "") {
  //     List<String> savedAlarmsText = savedAlarms.split("-");
  //     savedAlarmsText.map((e) => savedAlarmsId.add(int.parse(e))).toList();
  //     return savedAlarmsId;
  //   } else {
  //     return savedAlarmsId;
  //   }
  // }

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
    print(
        "YOUVE HIT YOUR LIMIT///////////////////////////////////////////////");
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
}

import 'package:get/get.dart';

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
}

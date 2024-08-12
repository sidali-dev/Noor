import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/helpers/helper_functions.dart';
import 'models/sub_models.dart/timings.dart';

class AdhanController extends GetxController {
  Rx<PrayerTime?> prayerTime = PrayerTime.empty().obs;
  Rx<DateTime> date = DateTime.now().obs;

  RxBool adhanFajr = SharedPrefService.getBool("fajr")!.obs;
  RxBool adhanChourouk = SharedPrefService.getBool("chourouk")!.obs;
  RxBool adhanDhuhr = SharedPrefService.getBool("dhuhr")!.obs;
  RxBool adhanAsr = SharedPrefService.getBool("asr")!.obs;
  RxBool adhanMaghrib = SharedPrefService.getBool("maghrib")!.obs;
  RxBool adhanIsha = SharedPrefService.getBool("isha")!.obs;

  LocationController locationController = Get.put(LocationController());

  //refreshes the location and prayers times
  refreshAdhanData(String country, String state, String city, int year) async {
    await locationController.insertNewLocation(country, state, city);
    locationController.getLocation();
    await getAdhanTimeCalendarByCity(year);
  }

//gets the adhan time for the year, and saves it to shared prefs
  Future getAdhanTimeCalendarByCity(int year) async {
    Map<String, dynamic> response = await SHttpHelper.get(
        locationController.country.value.replaceAll(" ", "%20"),
        locationController.city.value.replaceAll(" ", "%20"),
        year.toString());

    prayerTime.value = PrayerTime.fromJson(response);

    await SharedPrefService.setString(
        "Adhan$year", jsonEncode(prayerTime.value));
  }

//must be called at the start
  initController(int year) async {
    locationController.getLocation();

    if (locationController.city.value.isNotEmpty ||
        locationController.city.value != "") {
      try {
        prayerTime.value = PrayerTime.fromJson(
            jsonDecode(SharedPrefService.getString("Adhan$year")!));
      } catch (e) {
        await refreshAdhanData(
            locationController.country.value,
            locationController.state.value,
            locationController.city.value,
            year);
      }
    }
  }

  incrementDay() {
    date.value = date.value.add(const Duration(days: 1));
  }

  decrementDay() {
    date.value = date.value.subtract(const Duration(days: 1));
  }

  switchAdhan(String prayerName) async {
    switch (prayerName) {
      case "fajr":
        await SharedPrefService.setBool("fajr", !adhanFajr.value);
        adhanFajr.value = SharedPrefService.getBool("fajr")!;
        break;

      case "chourouk":
        await SharedPrefService.setBool("chourouk", !adhanChourouk.value);
        adhanChourouk.value = SharedPrefService.getBool("chourouk")!;

        break;
      case "dhuhr":
        await SharedPrefService.setBool("dhuhr", !adhanDhuhr.value);
        adhanDhuhr.value = SharedPrefService.getBool("dhuhr")!;
        break;

      case "asr":
        await SharedPrefService.setBool("asr", !adhanAsr.value);
        adhanAsr.value = SharedPrefService.getBool("asr")!;
        break;

      case "maghrib":
        await SharedPrefService.setBool("maghrib", !adhanMaghrib.value);
        adhanMaghrib.value = SharedPrefService.getBool("maghrib")!;
        break;

      case "isha":
        await SharedPrefService.setBool("isha", !adhanIsha.value);
        adhanIsha.value = SharedPrefService.getBool("isha")!;
        break;

      default:
        break;
    }
  }

  static scheduleAdhans() async {
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

    if (SharedPrefService.getBool("fajr")!) {
      await SHelperFunctions.setUpAlarm(
          id: 1,
          title: SHelperFunctions.getAdhanNotificationTitle(1),
          body: SHelperFunctions.getAdhanNotificationBody(1),
          dateTime: date,
          timing: timings.fajr,
          tomorrowTiming: tomorrowTimings.fajr,
          assetAudioPath: SharedPrefService.getString("adhan_sound_path")!);
    } else {
      await SHelperFunctions.cancelAlarm(1);
    }

    if (SharedPrefService.getBool("chourouk")!) {
      await SHelperFunctions.setUpAlarm(
          id: 2,
          dateTime: date,
          timing: timings.sunrise,
          tomorrowTiming: tomorrowTimings.sunrise,
          assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
          title: SHelperFunctions.getAdhanNotificationTitle(2),
          body: SHelperFunctions.getAdhanNotificationBody(2));
    } else {
      await SHelperFunctions.cancelAlarm(2);
    }

    if (SharedPrefService.getBool("dhuhr")!) {
      await SHelperFunctions.setUpAlarm(
          id: 3,
          dateTime: date,
          timing: timings.dhuhr,
          tomorrowTiming: tomorrowTimings.dhuhr,
          assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
          title: SHelperFunctions.getAdhanNotificationTitle(3),
          body: SHelperFunctions.getAdhanNotificationBody(3));
    } else {
      await SHelperFunctions.cancelAlarm(3);
    }

    if (SharedPrefService.getBool("asr")!) {
      await SHelperFunctions.setUpAlarm(
          id: 4,
          dateTime: date,
          timing: timings.asr,
          tomorrowTiming: tomorrowTimings.asr,
          assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
          title: SHelperFunctions.getAdhanNotificationTitle(4),
          body: SHelperFunctions.getAdhanNotificationBody(4));
    } else {
      await SHelperFunctions.cancelAlarm(4);
    }

    if (SharedPrefService.getBool("maghrib")!) {
      await SHelperFunctions.setUpAlarm(
          id: 5,
          dateTime: date,
          timing: timings.maghrib,
          tomorrowTiming: tomorrowTimings.maghrib,
          assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
          title: SHelperFunctions.getAdhanNotificationTitle(5),
          body: SHelperFunctions.getAdhanNotificationBody(5));
    } else {
      await SHelperFunctions.cancelAlarm(5);
    }

    if (SharedPrefService.getBool("isha")!) {
      await SHelperFunctions.setUpAlarm(
          id: 6,
          dateTime: date,
          timing: timings.isha,
          tomorrowTiming: tomorrowTimings.isha,
          assetAudioPath: SharedPrefService.getString("adhan_sound_path")!,
          title: SHelperFunctions.getAdhanNotificationTitle(6),
          body: SHelperFunctions.getAdhanNotificationBody(6));
    } else {
      await SHelperFunctions.cancelAlarm(6);
    }
  }
}

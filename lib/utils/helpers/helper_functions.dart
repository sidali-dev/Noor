import 'package:alarm/alarm.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:noor/utils/local_storage/services/sharedpreferences_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import '../constants/image_strings.dart';
import '../constants/sound_string.dart';

class SHelperFunctions {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getLangluageCode() {
    return Get.locale!.languageCode;
  }

  static getLanguage(String language) {
    switch (language) {
      case ('en'):
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(SImageString.eng, height: 30),
          const SizedBox(width: 8),
          const Text('English')
        ]);

      case ('fr'):
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(SImageString.france, height: 30),
          const SizedBox(width: 8),
          const Text('Frencais')
        ]);

      case ('ar'):
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(SImageString.arabic, height: 30),
          const SizedBox(width: 8),
          const Text('العربية')
        ]);
    }
  }

  static bool isRtl(BuildContext context) {
    return Localizations.localeOf(context).languageCode == "ar";
  }

  static String removeTimeZone(String timeString) {
    List<String> parts = timeString.split(' ');

    return parts.first;
  }

  static Future<bool> isInternetConnected() async {
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static formatDate(String timeStamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(timeStamp) * 1000,
        isUtc: false);

    final dateFormatter = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormatter.format(dateTime);

    return formattedDate;
  }

  static Future<bool> isFirstRun() async {
    return SharedPrefService.getBool('isFirstRun') ?? true;
  }

  static Future<void> saveInitialValues() async {
    final isFirstRun = await SHelperFunctions.isFirstRun();
    if (isFirstRun) {
      await SharedPrefService.setBool('isFirstRun', false);
      await SharedPrefService.setBool('fajr', true);
      await SharedPrefService.setBool('chourouk', false);
      await SharedPrefService.setBool('dhuhr', true);
      await SharedPrefService.setBool('asr', true);
      await SharedPrefService.setBool('maghrib', true);
      await SharedPrefService.setBool('isha', true);
      await SharedPrefService.setString('country', "");
      await SharedPrefService.setString('state', "");
      await SharedPrefService.setString('city', "");
      await SharedPrefService.setString(
          'adhan_sound_path', "assets/sounds/ahmad_alnafees.mp3");
      await SharedPrefService.setString(
          'adhan_sound_name', "أذان الشيخ النفيس");
      await SharedPrefService.setInt('last_read_quran', 1);
      await SharedPrefService.setString('quran_bookmark', "");
    }
  }

  static Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted',
      );
    }
  }

  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      alarmPrint(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  static setUpAdhan(
      {required int id,
      required DateTime dateTime,
      required String assetAudioPath,
      required String timing,
      required String tomorrowTiming,
      required String title,
      required String body,
      required String stopButtonText}) async {
    String time = SHelperFunctions.removeTimeZone(timing);

    String tomorrowTime = SHelperFunctions.removeTimeZone(timing);

    DateTime prayerTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        int.parse(time.split(":")[0]), int.parse(time.split(":")[1]));

    DateTime prayerTimeTomorrow = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day + 1,
        int.parse(tomorrowTime.split(":")[0]),
        int.parse(tomorrowTime.split(":")[1]));

    if (dateTime.isBefore(prayerTime)) {
      AlarmSettings alarmSettings = AlarmSettings(
        id: id,
        notificationSettings: NotificationSettings(
            title: title, body: body, stopButton: stopButtonText),
        dateTime: prayerTime,
        assetAudioPath: assetAudioPath,
        loopAudio: false,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        vibrate: false,
        volume: 0.5,
        fadeDuration: 3.0,
      );
      await Alarm.set(alarmSettings: alarmSettings);
    } else {
      AlarmSettings alarmSettings = AlarmSettings(
          id: id,
          notificationSettings: NotificationSettings(
              title: title, body: body, stopButton: stopButtonText),
          dateTime: prayerTimeTomorrow,
          assetAudioPath: assetAudioPath,
          warningNotificationOnKill: false,
          loopAudio: false,
          androidFullScreenIntent: true,
          vibrate: false,
          volume: 0.5,
          fadeDuration: 3.0);
      await Alarm.set(alarmSettings: alarmSettings);
    }
  }

  static setUpAlarm(
      {required int id,
      required DateTime dateTime,
      required String assetAudioPath,
      required DateTime timing,
      required DateTime tomorrowTiming,
      required String title,
      required String body,
      required String stopButtonText}) async {
    if (dateTime.isBefore(timing)) {
      AlarmSettings alarmSettings = AlarmSettings(
        id: id,
        notificationSettings: NotificationSettings(
            title: title, body: body, stopButton: stopButtonText),
        dateTime: timing,
        assetAudioPath: assetAudioPath,
        loopAudio: false,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        vibrate: false,
        volume: 0.5,
        fadeDuration: 3.0,
      );
      await Alarm.set(alarmSettings: alarmSettings);
    } else {
      AlarmSettings alarmSettings = AlarmSettings(
          id: id,
          notificationSettings: NotificationSettings(
              title: title, body: body, stopButton: stopButtonText),
          dateTime: tomorrowTiming,
          assetAudioPath: assetAudioPath,
          warningNotificationOnKill: false,
          loopAudio: false,
          androidFullScreenIntent: true,
          vibrate: false,
          volume: 0.5,
          fadeDuration: 3.0);
      await Alarm.set(alarmSettings: alarmSettings);
    }
  }

  static getAdhanNotificationTitle(int id) {
    String storedLanguage = SharedPrefService.getString("language") ?? 'ar';
    final bool isRtl = storedLanguage == "ar";
    final bool isFr = storedLanguage == "fr";

    switch (id) {
      case 1:
        return isRtl ? "أذان الفجر" : "Adhan el Fajr";
      case 2:
        return isRtl
            ? "وقت الشروق"
            : isFr
                ? "C'est l'heure du Chourouk"
                : "It's Chourouk Time";
      case 3:
        return isRtl ? "أذان الظهر" : "Adhan el Dhuhr";
      case 4:
        return isRtl ? "أذان العصر" : "Adhan el Asr";
      case 5:
        return isRtl ? "أذان المغرب" : "Adhan el Maghrib";
      case 6:
        return isRtl ? "أذان العشاء" : "Adhan el Isha";
    }
  }

  static getAlarmNotificationTitle(int id) {
    String storedLanguage = SharedPrefService.getString("language") ?? 'ar';
    final bool isRtl = storedLanguage == "ar";
    final bool isFr = storedLanguage == "fr";

    switch (id) {
      case 101 || 102:
        return isRtl
            ? "تنبيه أذان الفجر"
            : isFr
                ? "Alarme de l'adhan d'El Fajr"
                : "Alarm Of Adhan El Fajr";
      case 201 || 202:
        return isRtl
            ? "تنبيه وقت الشروق"
            : isFr
                ? "Alarme du Chourouk"
                : "Chourouk Time's Alarm";
      case 301 || 302:
        return isRtl
            ? "تنبيه أذان الظهر"
            : isFr
                ? "Alarme de l'adhan d'El Dhuhr"
                : "Alarm Of Adhan El Dhuhr";
      case 401 || 402:
        return isRtl
            ? "تنبيه أذان العصر"
            : isFr
                ? "Alarme de l'adhan d'El Asr"
                : "Alarm Of Adhan El Asr";
      case 501 || 502:
        return isRtl
            ? "تنبيه أذان المغرب"
            : isFr
                ? "Alarme de l'adhan d'El Maghrib"
                : "Alarm Of Adhan El Maghrib";
      case 601 || 602:
        return isRtl
            ? "تنبيه أذان العشاء"
            : isFr
                ? "Alarme de l'adhan d'El Isha"
                : "Alarm Of Adhan El Isha";
    }
  }

  static getAdhanNotificationBody(int id) {
    String storedLanguage = SharedPrefService.getString("language") ?? 'ar';
    if (id == 2) {
      switch (storedLanguage) {
        case "ar":
          return "الشمس تشرق";
        case "fr":
          return "Le soleil se lève";
        case "en":
          return "Sun is Rising";
        default:
          return "الشمس تشرق";
      }
    } else {
      switch (storedLanguage) {
        case "ar":
          return "حان وقت الذهاب إلى المسجد";
        case "fr":
          return "Temps d'aller à la mosquée";
        case "en":
          return "Time to go to the Masjid";
        default:
          return "حان وقت الذهاب إلى المسجد";
      }
    }
  }

  static getAlarmNotificationBody(int id, int difference) {
    String storedLanguage = SharedPrefService.getString("language") ?? 'ar';

    if (id != 2) {
      if (difference < 0) {
        switch (storedLanguage) {
          case "ar":
            return "تبقى ${difference.abs().toString()}د على الأذان";
          case "fr":
            return "Il reste ${difference.abs().toString()} minutes avant l'adhan";
          case "en":
            return "${difference.abs().toString()} minutes remaining until the adhan";
        }
      } else {
        switch (storedLanguage) {
          case "ar":
            return "مرت $differenceد على الأذان";
          case "en":
            return "$difference minutes have passed since the adhan";
          case "fr":
            return "$difference minutes se sont écoulées depuis l'adhan";
        }
      }
    } else {
      if (difference < 0) {
        switch (storedLanguage) {
          case "ar":
            return "تبقى ${difference.abs().toString()} د على شروق الشمس";
          case "fr":
            return "Il reste ${difference.abs().toString()} minutes avant le lever du soleil";
          case "en":
            return "${difference.abs().toString()} minutes left until sunrise";
        }
      } else {
        switch (storedLanguage) {
          case "ar":
            return "مضى على شروق الشمس $difference د";
          case "fr":
            return "$difference minutes se sont écoulées depuis le lever du soleil";
          case "en":
            return "$difference minutes have passed since sunrise";
        }
      }
    }
  }

  static DateTime turnTimingToDate(String timing) {
    String time = SHelperFunctions.removeTimeZone(timing);

    DateTime dateTime = DateTime.now();

    DateTime prayerTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        int.parse(time.split(":")[0]), int.parse(time.split(":")[1]));

    return prayerTime;
  }

  static getAdhanStopText() {
    String storedLanguage = SharedPrefService.getString("language") ?? 'ar';

    switch (storedLanguage) {
      case "ar":
        return "إيقاف الأذان";
      case "fr":
        return "Arrêter l'Adhan";
      case "en":
        return "Stop Adhan";
      default:
        return "إيقاف الأذان";
    }
  }

  static cancelAlarm(int id) async {
    await Alarm.stop(id);
  }

  static getAlarmColor(int id) {
    switch (id) {
      case 1 || 101 || 102:
        return const Color(0xFFFFD700); // Fajr (Golden Yellow)
      case 2 || 201 || 202:
        return const Color(0xFFFFA500); // Chourouk (Orange)
      case 3 || 301 || 302:
        return const Color(0xFF87CEEB); // Dhuhr (Sky Blue)
      case 4 || 401 || 402:
        return const Color(0xFFFFD700); // Asr (Golden Yellow)
      case 5 || 501 || 502:
        return const Color(0xFFFF4500); // Maghrib (Orange Red)
      case 6 || 601 || 602:
        return const Color(0xFF191970); // Isha (Midnight Blue)
      default:
        return Colors.indigo;
    }
  }

  static String getAdhanChikhName() {
    switch (SharedPrefService.getString('adhan_sound_path')!) {
      case SSoundString.adhanAhmadAlNafees:
        return S.of(Get.context!).chikh_nafees;
      case SSoundString.adhanAlafasy1:
        return S.of(Get.context!).chikh_afassy_1;
      case SSoundString.adhanAlafasy2:
        return S.of(Get.context!).chilh_afassy_2;
      case SSoundString.adhanAhmedElKourdi:
        return S.of(Get.context!).chikh_elkourdi;
      case SSoundString.adhanHamzaElMajali:
        return S.of(Get.context!).chikh_elmajali;
      default:
        return S.of(Get.context!).chikh_nafees;
    }
  }

  static bool isSameDay(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  static Future<Placemark> getLocation() async {
    List<Placemark> placemarks;
    LocationStatus locationStatus;

    int retryCount = 0;
    while (retryCount < 3) {
      retryCount++;

      locationStatus = await FlutterQiblah.checkLocationStatus();

      if (locationStatus.status == LocationPermission.denied) {
        await FlutterQiblah.requestPermissions();
      }
      if (locationStatus.status == LocationPermission.denied &&
          retryCount == 3) {
        await openAppSettings();
      }
      if (locationStatus.status == LocationPermission.always ||
          locationStatus.status == LocationPermission.whileInUse) {
        try {
          Position position = await Geolocator.getCurrentPosition();
          placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          retryCount = 3;

          return placemarks.first;
        } catch (e) {
          retryCount = 3;

          return const Placemark(country: null);
        }
      }
    }
    return const Placemark(country: null);
  }

  static getHizbStartingPage(int hizbNumber) {
    switch (hizbNumber) {
      case 1:
        return 2;
      case 2:
        return 12;
      case 3:
        return 23;
      case 4:
        return 33;
      case 5:
        return 43;
      case 6:
        return 52;
      case 7:
        return 63;
      case 8:
        return 73;
      case 9:
        return 83;
      case 10:
        return 93;
      case 11:
        return 103;
      case 12:
        return 113;
      case 13:
        return 122;
      case 14:
        return 133;
      case 15:
        return 143;
      case 16:
        return 152;
      case 17:
        return 163;
      case 18:
        return 174;
      case 19:
        return 183;
      case 20:
        return 193;
      case 21:
        return 202;
      case 22:
        return 213;
      case 23:
        return 223;
      case 24:
        return 232;
      case 25:
        return 243;
      case 26:
        return 253;
      case 27:
        return 263;
      case 28:
        return 273;
      case 29:
        return 283;
      case 30:
        return 293;
      case 31:
        return 303;
      case 32:
        return 313;
      case 33:
        return 323;
      case 34:
        return 333;
      case 35:
        return 343;
      case 36:
        return 353;
      case 37:
        return 363;
      case 38:
        return 372;
      case 39:
        return 383;
      case 40:
        return 393;
      case 41:
        return 403;
      case 42:
        return 414;
      case 43:
        return 423;
      case 44:
        return 432;
      case 45:
        return 443;
      case 46:
        return 452;
      case 47:
        return 463;
      case 48:
        return 473;
      case 49:
        return 483;
      case 50:
        return 492;
      case 51:
        return 503;
      case 52:
        return 514;
      case 53:
        return 523;
      case 54:
        return 532;
      case 55:
        return 543;
      case 56:
        return 554;
      case 57:
        return 563;
      case 58:
        return 573;
      case 59:
        return 583;
      case 60:
        return 592;
      default:
        return 1;
    }
  }
}

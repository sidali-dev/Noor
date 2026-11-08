// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(prayer) => "Time for ${prayer}";

  static String m1(count) => "${count} athkar";

  static String m2(name) => "Nearest authority: ${name}";

  static String m3(hours, minutes) => "${hours}h ${minutes}m";

  static String m4(minutes) => "${minutes}m";

  static String m5(prayer, time) => "${prayer} in ${time}";

  static String m6(name, days) =>
      "${Intl.plural(days, one: '${name} tomorrow', other: '${name} in ${days} days')}";

  static String m7(read, total) => "${read} of ${total} pages";

  static String m8(city, shift, saved) =>
      "Your network suggests you\'re near ${city}. Prayer times there differ by about ${shift} from ${saved}.";

  static String m9(shift, saved) =>
      "Your network suggests you\'re somewhere else. Prayer times there differ by about ${shift} from ${saved}.";

  static String m10(minutes, prayer) => "${minutes} min since ${prayer}";

  static String m11(minutes, prayer) => "${minutes} min until ${prayer}";

  static String m12(prayer) => "${prayer} reminder";

  static String m13(count) => "${count} verses";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_location": MessageLookupByLibrary.simpleMessage("Add location"),
        "adhan_adhkar": MessageLookupByLibrary.simpleMessage(
            "Athkar for Hearing the Adhan"),
        "adhan_asr": MessageLookupByLibrary.simpleMessage("Adhan el Asr"),
        "adhan_chourouk":
            MessageLookupByLibrary.simpleMessage("It\'s Chourouk Time"),
        "adhan_dhuhr": MessageLookupByLibrary.simpleMessage("Adhan el Dhuhr"),
        "adhan_disabled":
            MessageLookupByLibrary.simpleMessage("Adhan disabled"),
        "adhan_enabled": MessageLookupByLibrary.simpleMessage("Adhan enabled"),
        "adhan_fajr": MessageLookupByLibrary.simpleMessage("Adhan el Fajr"),
        "adhan_isha": MessageLookupByLibrary.simpleMessage("Adhan el Isha"),
        "adhan_maghrib":
            MessageLookupByLibrary.simpleMessage("Adhan el Maghrib"),
        "adhan_now": m0,
        "adhkar": MessageLookupByLibrary.simpleMessage("Athkar"),
        "adhkar_count": m1,
        "adjust_times": MessageLookupByLibrary.simpleMessage("Adjust times"),
        "adjust_times_hint": MessageLookupByLibrary.simpleMessage(
            "Shift a prayer by a few minutes to match your mosque."),
        "after_adhan": MessageLookupByLibrary.simpleMessage("after adhan"),
        "after_prayer_adhkar":
            MessageLookupByLibrary.simpleMessage("After Prayer Athkar"),
        "alarm_deleted": MessageLookupByLibrary.simpleMessage("Alarm removed"),
        "alarm_saved": MessageLookupByLibrary.simpleMessage("Alarm saved"),
        "alarms_off": MessageLookupByLibrary.simpleMessage(
            "Allow alarms and reminders so the adhan rings on time"),
        "asma_al_husna": MessageLookupByLibrary.simpleMessage("Asma al-Husna"),
        "asma_failed":
            MessageLookupByLibrary.simpleMessage("Couldn\'t load the names"),
        "asma_subtitle":
            MessageLookupByLibrary.simpleMessage("The 99 names of Allah"),
        "asr": MessageLookupByLibrary.simpleMessage("Asr"),
        "asr_hanafi": MessageLookupByLibrary.simpleMessage("Hanafi"),
        "asr_hint": MessageLookupByLibrary.simpleMessage(
            "Shafi\'i, Maliki and Hanbali follow the standard time. Hanafi Asr is later, when a shadow is twice its object\'s length."),
        "asr_standard": MessageLookupByLibrary.simpleMessage("Standard"),
        "asr_time": MessageLookupByLibrary.simpleMessage("Asr time"),
        "automatic": MessageLookupByLibrary.simpleMessage("Automatic"),
        "automatic_meta": MessageLookupByLibrary.simpleMessage(
            "The authority nearest your location"),
        "automatic_method_meta": m2,
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "before_adhan": MessageLookupByLibrary.simpleMessage("before adhan"),
        "bookmark": MessageLookupByLibrary.simpleMessage("Bookmark"),
        "bookmarks": MessageLookupByLibrary.simpleMessage("Bookmarks"),
        "calculation_method":
            MessageLookupByLibrary.simpleMessage("Calculation method"),
        "calibrate": MessageLookupByLibrary.simpleMessage("Calibrate"),
        "calibrate_step_1": MessageLookupByLibrary.simpleMessage(
            "Move your phone in a slow figure-8 a few times."),
        "calibrate_step_2": MessageLookupByLibrary.simpleMessage(
            "Keep away from metal, magnets and speakers."),
        "calibrate_step_3": MessageLookupByLibrary.simpleMessage(
            "Hold the phone flat, then check the arrow again."),
        "calibrate_title":
            MessageLookupByLibrary.simpleMessage("Calibrate the compass"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chikh_afassy_1":
            MessageLookupByLibrary.simpleMessage("Adhan Sheikh Alafasy 1"),
        "chikh_elkourdi":
            MessageLookupByLibrary.simpleMessage("Adhan Sheikh Ahmed Elkourdi"),
        "chikh_elmajali":
            MessageLookupByLibrary.simpleMessage("Adhan Sheikh Hamza Elmajali"),
        "chikh_nafees":
            MessageLookupByLibrary.simpleMessage("Adhan Sheikh Ahmad Alnafees"),
        "chilh_afassy_2":
            MessageLookupByLibrary.simpleMessage("Adhan Sheikh Alafasy 2"),
        "city": MessageLookupByLibrary.simpleMessage("City"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "compass_error": MessageLookupByLibrary.simpleMessage(
            "The compass isn\'t responding"),
        "comprehensive_duaa":
            MessageLookupByLibrary.simpleMessage("Comprehensive Duaa"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirm_location":
            MessageLookupByLibrary.simpleMessage("Confirm Location"),
        "continue_reading":
            MessageLookupByLibrary.simpleMessage("Continue reading"),
        "country": MessageLookupByLibrary.simpleMessage("Country"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "dhuhr": MessageLookupByLibrary.simpleMessage("Dhuhr"),
        "distance_to_kaaba":
            MessageLookupByLibrary.simpleMessage("Distance to the Kaaba"),
        "done": MessageLookupByLibrary.simpleMessage("Done"),
        "duration_hm": m3,
        "duration_m": m4,
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "enable_location_body": MessageLookupByLibrary.simpleMessage(
            "Make sure your phone\'s GPS and location services are turned on. This can help improve the accuracy of the compass by providing additional data."),
        "enable_location_permission": MessageLookupByLibrary.simpleMessage(
            "Allow location access to continue"),
        "enable_location_title":
            MessageLookupByLibrary.simpleMessage("Enable Location Services"),
        "enter_location":
            MessageLookupByLibrary.simpleMessage("Enter your location"),
        "evening_adhkar":
            MessageLookupByLibrary.simpleMessage("Evening Athkar"),
        "every_day": MessageLookupByLibrary.simpleMessage("Every day"),
        "facing_qibla":
            MessageLookupByLibrary.simpleMessage("Facing the qibla"),
        "fajr": MessageLookupByLibrary.simpleMessage("Fajr"),
        "flat_phone_body": MessageLookupByLibrary.simpleMessage(
            "For the most accurate reading, hold your phone flat in your hand, parallel to the ground. Tilting the phone can affect the compass reading."),
        "flat_phone_title":
            MessageLookupByLibrary.simpleMessage("Hold Your Phone Flat"),
        "full_screen_off": MessageLookupByLibrary.simpleMessage(
            "Allow full-screen alerts so the adhan screen can show"),
        "general_Adhkar":
            MessageLookupByLibrary.simpleMessage("General Athkar"),
        "gps": MessageLookupByLibrary.simpleMessage("GPS"),
        "gps_off": MessageLookupByLibrary.simpleMessage(
            "Turn on location services to find the qibla"),
        "gps_subtitle":
            MessageLookupByLibrary.simpleMessage("Use your current location"),
        "hajj_adhkar":
            MessageLookupByLibrary.simpleMessage("Hajj and Umrah Athkar"),
        "high_latitude": MessageLookupByLibrary.simpleMessage("High latitudes"),
        "high_latitude_hint": MessageLookupByLibrary.simpleMessage(
            "For places where twilight lasts all night in summer."),
        "hijri_adjust_hint": MessageLookupByLibrary.simpleMessage(
            "To shift the date by a day, choose astronomical calculation."),
        "hijri_adjustment":
            MessageLookupByLibrary.simpleMessage("Shift by days"),
        "hijri_date": MessageLookupByLibrary.simpleMessage("Hijri date"),
        "hizb": MessageLookupByLibrary.simpleMessage("Hizb"),
        "home_adhkar": MessageLookupByLibrary.simpleMessage(
            "Athkar for Entering and Leaving the House"),
        "imsak": MessageLookupByLibrary.simpleMessage("Imsak"),
        "in_adhkar_text": MessageLookupByLibrary.simpleMessage("In the athkar"),
        "isha": MessageLookupByLibrary.simpleMessage("Isha"),
        "keep_from_magnetic_body": MessageLookupByLibrary.simpleMessage(
            "Avoid using your phone\'s compass near large metal objects, electrical equipment, or magnets, as these can interfere with the accuracy of the compass."),
        "keep_from_magnetic_title": MessageLookupByLibrary.simpleMessage(
            "Keep Away from Magnetic Interference"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "last_read": MessageLookupByLibrary.simpleMessage("Last read"),
        "last_third": MessageLookupByLibrary.simpleMessage("Last third"),
        "lat_angle_based": MessageLookupByLibrary.simpleMessage("Angle based"),
        "lat_middle_night":
            MessageLookupByLibrary.simpleMessage("Middle of the night"),
        "lat_one_seventh":
            MessageLookupByLibrary.simpleMessage("One seventh of the night"),
        "location_failed": MessageLookupByLibrary.simpleMessage(
            "Couldn\'t find your location"),
        "location_needed": MessageLookupByLibrary.simpleMessage(
            "Add your location to see prayer times"),
        "location_subtitle": MessageLookupByLibrary.simpleMessage(
            "To get accurate prayer times"),
        "location_title":
            MessageLookupByLibrary.simpleMessage("Enter Your Location"),
        "maghrib": MessageLookupByLibrary.simpleMessage("Maghrib"),
        "manual_subtitle":
            MessageLookupByLibrary.simpleMessage("Pick your city / wilaya"),
        "manually": MessageLookupByLibrary.simpleMessage("Manually"),
        "masjid_time":
            MessageLookupByLibrary.simpleMessage("Time to go to the Masjid"),
        "meal_adhkar": MessageLookupByLibrary.simpleMessage(
            "Athkar for Food, Drink, and Guests"),
        "meccan": MessageLookupByLibrary.simpleMessage("Meccan"),
        "medinan": MessageLookupByLibrary.simpleMessage("Medinan"),
        "midnight": MessageLookupByLibrary.simpleMessage("Midnight"),
        "minute_short": MessageLookupByLibrary.simpleMessage("min"),
        "morning_adhkar":
            MessageLookupByLibrary.simpleMessage("Morning Athkar"),
        "mosque_adhkar": MessageLookupByLibrary.simpleMessage("Mosque Athkar"),
        "nav_adhkar": MessageLookupByLibrary.simpleMessage("Athkar"),
        "nav_prayers": MessageLookupByLibrary.simpleMessage("Prayers"),
        "nav_qibla": MessageLookupByLibrary.simpleMessage("Qibla"),
        "nav_quran": MessageLookupByLibrary.simpleMessage("Quran"),
        "next_prayer_in": m5,
        "no_bookmarks":
            MessageLookupByLibrary.simpleMessage("No bookmarks yet"),
        "no_internet": MessageLookupByLibrary.simpleMessage(
            "No connection. Try again when you\'re online."),
        "no_results": MessageLookupByLibrary.simpleMessage("No results"),
        "notifications_off": MessageLookupByLibrary.simpleMessage(
            "Allow notifications so the adhan can ring"),
        "occasion_arafah":
            MessageLookupByLibrary.simpleMessage("Day of Arafah"),
        "occasion_ashura": MessageLookupByLibrary.simpleMessage("Ashura"),
        "occasion_eid_adha":
            MessageLookupByLibrary.simpleMessage("Eid al-Adha"),
        "occasion_eid_fitr":
            MessageLookupByLibrary.simpleMessage("Eid al-Fitr"),
        "occasion_in_days": m6,
        "occasion_isra_miraj":
            MessageLookupByLibrary.simpleMessage("Isra and Mi\'raj"),
        "occasion_laylat_al_qadr":
            MessageLookupByLibrary.simpleMessage("Laylat al-Qadr"),
        "occasion_mawlid":
            MessageLookupByLibrary.simpleMessage("Mawlid an-Nabi"),
        "occasion_mid_shaban":
            MessageLookupByLibrary.simpleMessage("Mid-Sha\'ban"),
        "occasion_new_year":
            MessageLookupByLibrary.simpleMessage("Islamic New Year"),
        "occasion_ramadan":
            MessageLookupByLibrary.simpleMessage("First day of Ramadan"),
        "open_adhkar": MessageLookupByLibrary.simpleMessage("Open Athkar"),
        "open_settings": MessageLookupByLibrary.simpleMessage("Open settings"),
        "page": MessageLookupByLibrary.simpleMessage("Page"),
        "pages_read": m7,
        "pick_adhan": MessageLookupByLibrary.simpleMessage("Pick Adhan"),
        "pick_city": MessageLookupByLibrary.simpleMessage("Pick Your City"),
        "pick_country":
            MessageLookupByLibrary.simpleMessage("Pick Your Country"),
        "pick_location":
            MessageLookupByLibrary.simpleMessage("Pick Your Location"),
        "pick_state": MessageLookupByLibrary.simpleMessage("Pick Your State"),
        "prayer_adhkar": MessageLookupByLibrary.simpleMessage("Prayer Athkar"),
        "prayer_settings":
            MessageLookupByLibrary.simpleMessage("Prayer settings"),
        "prayer_times_failed":
            MessageLookupByLibrary.simpleMessage("Couldn\'t load prayer times"),
        "prophet_dua": MessageLookupByLibrary.simpleMessage("Prophet\'s Duaa"),
        "prophets_dua": MessageLookupByLibrary.simpleMessage("Prophets\' Duaa"),
        "qibla_direction":
            MessageLookupByLibrary.simpleMessage("Qibla direction"),
        "qiblah": MessageLookupByLibrary.simpleMessage("El Qiblah"),
        "quran_dua": MessageLookupByLibrary.simpleMessage("Quranic Duaa"),
        "relocate_auto":
            MessageLookupByLibrary.simpleMessage("Detect automatically"),
        "relocate_body": m8,
        "relocate_body_unknown": m9,
        "relocate_manual":
            MessageLookupByLibrary.simpleMessage("Choose manually"),
        "relocate_title":
            MessageLookupByLibrary.simpleMessage("Have you moved?"),
        "reminder_after": m10,
        "reminder_before": m11,
        "reminder_title": m12,
        "reminders": MessageLookupByLibrary.simpleMessage("Reminders"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "reset_progress":
            MessageLookupByLibrary.simpleMessage("Reset reading progress"),
        "reset_progress_body": MessageLookupByLibrary.simpleMessage(
            "This clears the pages marked as read. Your bookmarks are kept."),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saved_alarms": MessageLookupByLibrary.simpleMessage("Saved alarms"),
        "search_adhkar": MessageLookupByLibrary.simpleMessage("Search athkar"),
        "search_surah": MessageLookupByLibrary.simpleMessage("Search surah"),
        "sensor_not_supported": MessageLookupByLibrary.simpleMessage(
            "Your device has no compass sensor"),
        "set_new_alarm": MessageLookupByLibrary.simpleMessage("Set new alarm"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "settings_saved":
            MessageLookupByLibrary.simpleMessage("Prayer times updated"),
        "sleep_adhkar": MessageLookupByLibrary.simpleMessage("Sleeping Athkar"),
        "state": MessageLookupByLibrary.simpleMessage("State"),
        "stop_adhan": MessageLookupByLibrary.simpleMessage("Stop Adhan"),
        "sun_rise": MessageLookupByLibrary.simpleMessage("Sunrise"),
        "sun_rising": MessageLookupByLibrary.simpleMessage("Sun is Rising"),
        "surah": MessageLookupByLibrary.simpleMessage("Surah"),
        "tagline_adhkar": MessageLookupByLibrary.simpleMessage(
            "Surely in the remembrance of Allah do hearts find rest. — Ar-Ra’d 13:28"),
        "tagline_prayers": MessageLookupByLibrary.simpleMessage(
            "Establish prayer for My remembrance. — Ta-Ha 20:14"),
        "tagline_qibla": MessageLookupByLibrary.simpleMessage(
            "Turn your face toward the Sacred Mosque. — Al-Baqarah 2:144"),
        "tagline_quran": MessageLookupByLibrary.simpleMessage(
            "Indeed, this Quran guides to what is most upright. — Al-⁠Isra 17:9"),
        "tasbeeh": MessageLookupByLibrary.simpleMessage("Tasbeehs"),
        "today": MessageLookupByLibrary.simpleMessage("Today"),
        "try_again": MessageLookupByLibrary.simpleMessage("Try again"),
        "verse_count": m13,
        "wait_please":
            MessageLookupByLibrary.simpleMessage("This might take a moment"),
        "wake_up_adhkar":
            MessageLookupByLibrary.simpleMessage("Waking Up Athkar"),
        "wc_adhkar": MessageLookupByLibrary.simpleMessage(
            "Athkar for Entering and Leaving the Bathroom"),
        "wudu_adhkar": MessageLookupByLibrary.simpleMessage("Wudu Athkar")
      };
}

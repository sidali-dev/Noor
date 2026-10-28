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

  static String m0(count) => "${count} athkar";

  static String m1(hours, minutes) => "${hours}h ${minutes}m";

  static String m2(minutes) => "${minutes}m";

  static String m3(prayer, time) => "${prayer} in ${time}";

  static String m4(read, total) => "${read} of ${total} pages";

  static String m5(city, shift, saved) =>
      "Your network suggests you\'re near ${city}. Prayer times there differ by about ${shift} from ${saved}.";

  static String m6(shift, saved) =>
      "Your network suggests you\'re somewhere else. Prayer times there differ by about ${shift} from ${saved}.";

  static String m7(minutes, prayer) => "${minutes} min since ${prayer}";

  static String m8(minutes, prayer) => "${minutes} min until ${prayer}";

  static String m9(prayer) => "${prayer} reminder";

  static String m10(count) => "${count} verses";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add_location": MessageLookupByLibrary.simpleMessage(
      "Please add your location",
    ),
    "adhan_adhkar": MessageLookupByLibrary.simpleMessage(
      "Athkar for Hearing the Adhan",
    ),
    "adhan_asr": MessageLookupByLibrary.simpleMessage("Adhan el Asr"),
    "adhan_chourouk": MessageLookupByLibrary.simpleMessage(
      "It\'s Chourouk Time",
    ),
    "adhan_dhuhr": MessageLookupByLibrary.simpleMessage("Adhan el Dhuhr"),
    "adhan_fajr": MessageLookupByLibrary.simpleMessage("Adhan el Fajr"),
    "adhan_isha": MessageLookupByLibrary.simpleMessage("Adhan el Isha"),
    "adhan_maghrib": MessageLookupByLibrary.simpleMessage("Adhan el Maghrib"),
    "adhkar": MessageLookupByLibrary.simpleMessage("Athkar"),
    "adhkar_count": m0,
    "adhkar_subtitle": MessageLookupByLibrary.simpleMessage(
      "Peace for the heart, calm for the soul",
    ),
    "after_adhan": MessageLookupByLibrary.simpleMessage("after adhan"),
    "after_prayer_adhkar": MessageLookupByLibrary.simpleMessage(
      "After Prayer Athkar",
    ),
    "alarm_set_for": MessageLookupByLibrary.simpleMessage("Alarm set for"),
    "asr": MessageLookupByLibrary.simpleMessage("Asr"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "before_adhan": MessageLookupByLibrary.simpleMessage("before adhan"),
    "bookmark": MessageLookupByLibrary.simpleMessage("Bookmark"),
    "bookmarks": MessageLookupByLibrary.simpleMessage("Bookmarks"),
    "calibrate": MessageLookupByLibrary.simpleMessage("Calibrate"),
    "calibrate_step_1": MessageLookupByLibrary.simpleMessage(
      "Move your phone in a slow figure-8 a few times.",
    ),
    "calibrate_step_2": MessageLookupByLibrary.simpleMessage(
      "Keep away from metal, magnets and speakers.",
    ),
    "calibrate_step_3": MessageLookupByLibrary.simpleMessage(
      "Hold the phone flat, then check the arrow again.",
    ),
    "calibrate_title": MessageLookupByLibrary.simpleMessage(
      "Calibrate the compass",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "chikh_afassy_1": MessageLookupByLibrary.simpleMessage(
      "Adhan Sheikh Alafasy 1",
    ),
    "chikh_elkourdi": MessageLookupByLibrary.simpleMessage(
      "Adhan Sheikh Ahmed Elkourdi",
    ),
    "chikh_elmajali": MessageLookupByLibrary.simpleMessage(
      "Adhan Sheikh Hamza Elmajali",
    ),
    "chikh_nafees": MessageLookupByLibrary.simpleMessage(
      "Adhan Sheikh Ahmad Alnafees",
    ),
    "chilh_afassy_2": MessageLookupByLibrary.simpleMessage(
      "Adhan Sheikh Alafasy 2",
    ),
    "city": MessageLookupByLibrary.simpleMessage("City"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "comprehensive_duaa": MessageLookupByLibrary.simpleMessage(
      "Comprehensive Duaa",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirm_location": MessageLookupByLibrary.simpleMessage(
      "Confirm Location",
    ),
    "continue_reading": MessageLookupByLibrary.simpleMessage(
      "Continue Reading",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "dhuhr": MessageLookupByLibrary.simpleMessage("Dhuhr"),
    "distance_to_kaaba": MessageLookupByLibrary.simpleMessage(
      "Distance to the Kaaba",
    ),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "duration_hm": m1,
    "duration_m": m2,
    "enable_location": MessageLookupByLibrary.simpleMessage(
      "Please Enable The GPS Signal",
    ),
    "enable_location_body": MessageLookupByLibrary.simpleMessage(
      "Make sure your phone\'s GPS and location services are turned on. This can help improve the accuracy of the compass by providing additional data.",
    ),
    "enable_location_permission": MessageLookupByLibrary.simpleMessage(
      "Please Enable Location Permission",
    ),
    "enable_location_title": MessageLookupByLibrary.simpleMessage(
      "Enable Location Services",
    ),
    "enter_location": MessageLookupByLibrary.simpleMessage(
      "Enter Your Location",
    ),
    "evening_adhkar": MessageLookupByLibrary.simpleMessage("Evening Athkar"),
    "facing_qibla": MessageLookupByLibrary.simpleMessage("Facing the qibla"),
    "fajr": MessageLookupByLibrary.simpleMessage("Fajr"),
    "flat_phone_body": MessageLookupByLibrary.simpleMessage(
      "For the most accurate reading, hold your phone flat in your hand, parallel to the ground. Tilting the phone can affect the compass reading.",
    ),
    "flat_phone_title": MessageLookupByLibrary.simpleMessage(
      "Hold Your Phone Flat",
    ),
    "general_Adhkar": MessageLookupByLibrary.simpleMessage("General Athkar"),
    "gps": MessageLookupByLibrary.simpleMessage("GPS"),
    "gps_subtitle": MessageLookupByLibrary.simpleMessage(
      "Use your current location",
    ),
    "hajj_adhkar": MessageLookupByLibrary.simpleMessage(
      "Hajj and Umrah Athkar",
    ),
    "hizb": MessageLookupByLibrary.simpleMessage("Hizb"),
    "home_adhkar": MessageLookupByLibrary.simpleMessage(
      "Athkar for Entering and Leaving the House",
    ),
    "in_adhkar_text": MessageLookupByLibrary.simpleMessage("In the athkar"),
    "info": MessageLookupByLibrary.simpleMessage("Info"),
    "isha": MessageLookupByLibrary.simpleMessage("Isha"),
    "its": MessageLookupByLibrary.simpleMessage("it\'s"),
    "keep_from_magnetic_body": MessageLookupByLibrary.simpleMessage(
      "Avoid using your phone\'s compass near large metal objects, electrical equipment, or magnets, as these can interfere with the accuracy of the compass.",
    ),
    "keep_from_magnetic_title": MessageLookupByLibrary.simpleMessage(
      "Keep Away from Magnetic Interference",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "last_read": MessageLookupByLibrary.simpleMessage("Last Read"),
    "location_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t find your location",
    ),
    "location_subtitle": MessageLookupByLibrary.simpleMessage(
      "To get accurate prayer times",
    ),
    "location_title": MessageLookupByLibrary.simpleMessage(
      "Enter Your Location",
    ),
    "maghrib": MessageLookupByLibrary.simpleMessage("Maghrib"),
    "manual_subtitle": MessageLookupByLibrary.simpleMessage(
      "Pick your city / wilaya",
    ),
    "manually": MessageLookupByLibrary.simpleMessage("Manually"),
    "masjid_time": MessageLookupByLibrary.simpleMessage(
      "Time to go to the Masjid",
    ),
    "meal_adhkar": MessageLookupByLibrary.simpleMessage(
      "Athkar for Food, Drink, and Guests",
    ),
    "meccan": MessageLookupByLibrary.simpleMessage("Meccan"),
    "medinan": MessageLookupByLibrary.simpleMessage("Medinan"),
    "minute_short": MessageLookupByLibrary.simpleMessage("min"),
    "morning_adhkar": MessageLookupByLibrary.simpleMessage("Morning Athkar"),
    "mosque_adhkar": MessageLookupByLibrary.simpleMessage("Mosque Athkar"),
    "nav_adhkar": MessageLookupByLibrary.simpleMessage("Athkar"),
    "nav_prayers": MessageLookupByLibrary.simpleMessage("Prayers"),
    "nav_qibla": MessageLookupByLibrary.simpleMessage("Qibla"),
    "nav_quran": MessageLookupByLibrary.simpleMessage("Quran"),
    "next_prayer": MessageLookupByLibrary.simpleMessage("Next"),
    "next_prayer_in": m3,
    "no_bookmarks": MessageLookupByLibrary.simpleMessage("No Bookmarks"),
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "No Internet Connection",
    ),
    "no_results": MessageLookupByLibrary.simpleMessage("No results"),
    "noor": MessageLookupByLibrary.simpleMessage("Noor Imene"),
    "open_adhkar": MessageLookupByLibrary.simpleMessage("Open Athkar"),
    "open_settings": MessageLookupByLibrary.simpleMessage("Open settings"),
    "page": MessageLookupByLibrary.simpleMessage("Page"),
    "pages_read": m4,
    "pick_adhan": MessageLookupByLibrary.simpleMessage("Pick Adhan"),
    "pick_city": MessageLookupByLibrary.simpleMessage("Pick Your City"),
    "pick_country": MessageLookupByLibrary.simpleMessage("Pick Your Country"),
    "pick_location": MessageLookupByLibrary.simpleMessage("Pick Your Location"),
    "pick_state": MessageLookupByLibrary.simpleMessage("Pick Your State"),
    "prayer_adhkar": MessageLookupByLibrary.simpleMessage("Prayer Athkar"),
    "prophet_dua": MessageLookupByLibrary.simpleMessage("Prophet\'s Duaa"),
    "prophets_dua": MessageLookupByLibrary.simpleMessage("Prophets\' Duaa"),
    "qibla_direction": MessageLookupByLibrary.simpleMessage("Qibla direction"),
    "qiblah": MessageLookupByLibrary.simpleMessage("El Qiblah"),
    "qiblah_is_at": MessageLookupByLibrary.simpleMessage("The Qiblah is at"),
    "quran_dua": MessageLookupByLibrary.simpleMessage("Quranic Duaa"),
    "quran_subtitle": MessageLookupByLibrary.simpleMessage(
      "God\'s words, a light for your life",
    ),
    "quran_title": MessageLookupByLibrary.simpleMessage("The Noble Quran"),
    "reading_progress": MessageLookupByLibrary.simpleMessage(
      "Reading progress",
    ),
    "relocate_auto": MessageLookupByLibrary.simpleMessage(
      "Detect automatically",
    ),
    "relocate_body": m5,
    "relocate_body_unknown": m6,
    "relocate_manual": MessageLookupByLibrary.simpleMessage("Choose manually"),
    "relocate_title": MessageLookupByLibrary.simpleMessage("Have you moved?"),
    "reminder_after": m7,
    "reminder_before": m8,
    "reminder_title": m9,
    "reminders": MessageLookupByLibrary.simpleMessage("Reminders"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "repetition": MessageLookupByLibrary.simpleMessage("Repetition"),
    "reset_progress": MessageLookupByLibrary.simpleMessage(
      "Reset reading progress",
    ),
    "reset_progress_body": MessageLookupByLibrary.simpleMessage(
      "This clears the pages marked as read. Your bookmarks are kept.",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "search_adhkar": MessageLookupByLibrary.simpleMessage("Search athkar"),
    "search_surah": MessageLookupByLibrary.simpleMessage("Search surah"),
    "sensor_not_supported": MessageLookupByLibrary.simpleMessage(
      "Your Device Does Not Support The Sensor",
    ),
    "set_new_alarm": MessageLookupByLibrary.simpleMessage("set new alarm"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "sleep_adhkar": MessageLookupByLibrary.simpleMessage("Sleeping Athkar"),
    "state": MessageLookupByLibrary.simpleMessage("State"),
    "stop_adhan": MessageLookupByLibrary.simpleMessage("Stop Adhan"),
    "sun_rise": MessageLookupByLibrary.simpleMessage("Sunrise"),
    "sun_rising": MessageLookupByLibrary.simpleMessage("Sun is Rising"),
    "surah": MessageLookupByLibrary.simpleMessage("Surah"),
    "tagline_adhkar": MessageLookupByLibrary.simpleMessage(
      "Surely in the remembrance of Allah do hearts find rest. — Ar-Ra’d 13:28",
    ),
    "tagline_prayers": MessageLookupByLibrary.simpleMessage(
      "Establish prayer for My remembrance. — Ta-Ha 20:14",
    ),
    "tagline_qibla": MessageLookupByLibrary.simpleMessage(
      "Turn your face toward the Sacred Mosque. — Al-Baqarah 2:144",
    ),
    "tagline_quran": MessageLookupByLibrary.simpleMessage(
      "Indeed, this Quran guides to what is most upright. — Al-Isra 17:9",
    ),
    "tasbeeh": MessageLookupByLibrary.simpleMessage("Tasbeehs"),
    "tips": MessageLookupByLibrary.simpleMessage("Tips"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "try_again": MessageLookupByLibrary.simpleMessage("Try again"),
    "verse_count": m10,
    "wait_please": MessageLookupByLibrary.simpleMessage(
      "This might take a moment",
    ),
    "wake_up_adhkar": MessageLookupByLibrary.simpleMessage("Waking Up Athkar"),
    "wc_adhkar": MessageLookupByLibrary.simpleMessage(
      "Athkar for Entering and Leaving the Bathroom",
    ),
    "wudu_adhkar": MessageLookupByLibrary.simpleMessage("Wudu Athkar"),
    "year_ended": MessageLookupByLibrary.simpleMessage(
      "The days of the year are over",
    ),
  };
}

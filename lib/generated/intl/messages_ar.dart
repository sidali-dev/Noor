// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(count) => "${count} ذكر";

  static String m1(hours, minutes) => "${hours}س ${minutes}د";

  static String m2(minutes) => "${minutes}د";

  static String m3(prayer, time) => "${prayer} بعد ${time}";

  static String m4(read, total) => "${read} من ${total} صفحة";

  static String m5(city, shift, saved) =>
      "تشير شبكتك إلى أنك قرب ${city}. تختلف أوقات الصلاة هناك بنحو ${shift} عن ${saved}.";

  static String m6(shift, saved) =>
      "تشير شبكتك إلى أنك في مكان آخر. تختلف أوقات الصلاة هناك بنحو ${shift} عن ${saved}.";

  static String m7(minutes, prayer) => "مرت ${minutes} د على ${prayer}";

  static String m8(minutes, prayer) => "تبقى ${minutes} د على ${prayer}";

  static String m9(prayer) => "تنبيه ${prayer}";

  static String m10(count) => "${count} آية";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add_location": MessageLookupByLibrary.simpleMessage("الرجاء إضافة موقعك"),
    "adhan_adhkar": MessageLookupByLibrary.simpleMessage("أذكار سماع الآذان"),
    "adhan_asr": MessageLookupByLibrary.simpleMessage("أذان العصر"),
    "adhan_chourouk": MessageLookupByLibrary.simpleMessage("وقت الشروق"),
    "adhan_dhuhr": MessageLookupByLibrary.simpleMessage("أذان الظهر"),
    "adhan_fajr": MessageLookupByLibrary.simpleMessage("أذان الفجر"),
    "adhan_isha": MessageLookupByLibrary.simpleMessage("أذان العشاء"),
    "adhan_maghrib": MessageLookupByLibrary.simpleMessage("أذان المغرب"),
    "adhkar": MessageLookupByLibrary.simpleMessage("الأذكار"),
    "adhkar_count": m0,
    "adhkar_subtitle": MessageLookupByLibrary.simpleMessage(
      "راحة للقلوب .. وطمأنينة للنفوس",
    ),
    "after_adhan": MessageLookupByLibrary.simpleMessage("بعد الأذان"),
    "after_prayer_adhkar": MessageLookupByLibrary.simpleMessage(
      "أذكار بعد الصلاة",
    ),
    "alarm_set_for": MessageLookupByLibrary.simpleMessage("تم ضبط المنبه لـ"),
    "asr": MessageLookupByLibrary.simpleMessage("العصر"),
    "back": MessageLookupByLibrary.simpleMessage("رجوع"),
    "before_adhan": MessageLookupByLibrary.simpleMessage("قبل الأذان"),
    "bookmark": MessageLookupByLibrary.simpleMessage("علامة"),
    "bookmarks": MessageLookupByLibrary.simpleMessage("علامات الحفظ"),
    "calibrate": MessageLookupByLibrary.simpleMessage("معايرة"),
    "calibrate_step_1": MessageLookupByLibrary.simpleMessage(
      "حرّك هاتفك ببطء على شكل الرقم 8 عدة مرات.",
    ),
    "calibrate_step_2": MessageLookupByLibrary.simpleMessage(
      "ابتعد عن المعادن والمغناطيس ومكبرات الصوت.",
    ),
    "calibrate_step_3": MessageLookupByLibrary.simpleMessage(
      "أمسك الهاتف أفقيًا ثم تحقق من السهم مجددًا.",
    ),
    "calibrate_title": MessageLookupByLibrary.simpleMessage("معايرة البوصلة"),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "chikh_afassy_1": MessageLookupByLibrary.simpleMessage(
      "أذان الشيخ العفاسي 1",
    ),
    "chikh_elkourdi": MessageLookupByLibrary.simpleMessage(
      "أذان الشيخ أحمد الكردي",
    ),
    "chikh_elmajali": MessageLookupByLibrary.simpleMessage(
      "أذان الشيخ حمزة المجالي",
    ),
    "chikh_nafees": MessageLookupByLibrary.simpleMessage(
      "أذان الشيخ أحمد النفيس",
    ),
    "chilh_afassy_2": MessageLookupByLibrary.simpleMessage(
      "أذان الشيخ العفاسي 2",
    ),
    "city": MessageLookupByLibrary.simpleMessage("المدينة"),
    "close": MessageLookupByLibrary.simpleMessage("إغلاق"),
    "comprehensive_duaa": MessageLookupByLibrary.simpleMessage("جوامع الدعاء"),
    "confirm": MessageLookupByLibrary.simpleMessage("ثبت"),
    "confirm_location": MessageLookupByLibrary.simpleMessage("تأكيد الموقع"),
    "continue_reading": MessageLookupByLibrary.simpleMessage("أكمل القراءة"),
    "country": MessageLookupByLibrary.simpleMessage("البلد"),
    "dark_mode": MessageLookupByLibrary.simpleMessage("الوضع المظلم"),
    "dhuhr": MessageLookupByLibrary.simpleMessage("الظهر"),
    "distance_to_kaaba": MessageLookupByLibrary.simpleMessage(
      "المسافة إلى الكعبة",
    ),
    "done": MessageLookupByLibrary.simpleMessage("تم"),
    "duration_hm": m1,
    "duration_m": m2,
    "enable_location": MessageLookupByLibrary.simpleMessage(
      "يرجى تفعيل إشارة الموقع",
    ),
    "enable_location_body": MessageLookupByLibrary.simpleMessage(
      "تأكد من تشغيل نظام تحديد المواقع وخدمات الموقع على هاتفك. يمكن أن يساعد ذلك في تحسين دقة البوصلة من خلال توفير بيانات إضافية.",
    ),
    "enable_location_permission": MessageLookupByLibrary.simpleMessage(
      "يرجى تفعيل إذن الموقع",
    ),
    "enable_location_title": MessageLookupByLibrary.simpleMessage(
      "تمكين خدمات الموقع",
    ),
    "enter_location": MessageLookupByLibrary.simpleMessage("أضف موقعك"),
    "evening_adhkar": MessageLookupByLibrary.simpleMessage("اذكار المساء"),
    "facing_qibla": MessageLookupByLibrary.simpleMessage("أنت متجه نحو القبلة"),
    "fajr": MessageLookupByLibrary.simpleMessage("الفجر"),
    "flat_phone_body": MessageLookupByLibrary.simpleMessage(
      "للحصول على القراءة الأكثر دقة، امسك هاتفك بشكل مسطح في يدك، بحيث يكون موازيًا للأرض. يمكن أن يؤثر إمالة الهاتف على قراءة البوصلة.",
    ),
    "flat_phone_title": MessageLookupByLibrary.simpleMessage(
      "امسك هاتفك بشكل مسطح",
    ),
    "general_Adhkar": MessageLookupByLibrary.simpleMessage("أذكار متفرقة"),
    "gps": MessageLookupByLibrary.simpleMessage("GPS"),
    "gps_subtitle": MessageLookupByLibrary.simpleMessage("استخدم موقعك الحالي"),
    "hajj_adhkar": MessageLookupByLibrary.simpleMessage("أذكار الحج والعمرة"),
    "hizb": MessageLookupByLibrary.simpleMessage("حزب"),
    "home_adhkar": MessageLookupByLibrary.simpleMessage(
      "أذكار دخول وخروج المنزل",
    ),
    "in_adhkar_text": MessageLookupByLibrary.simpleMessage("في نصوص الأذكار"),
    "info": MessageLookupByLibrary.simpleMessage("معلومات"),
    "isha": MessageLookupByLibrary.simpleMessage("العشاء"),
    "its": MessageLookupByLibrary.simpleMessage("إنها"),
    "keep_from_magnetic_body": MessageLookupByLibrary.simpleMessage(
      "تجنب استخدام بوصلة هاتفك بالقرب من الأجسام المعدنية الكبيرة، أو المعدات الكهربائية، أو المغناطيسات، لأن ذلك يمكن أن يؤثر على دقة البوصلة.",
    ),
    "keep_from_magnetic_title": MessageLookupByLibrary.simpleMessage(
      "ابتعد عن التداخل المغناطيسي",
    ),
    "language": MessageLookupByLibrary.simpleMessage("اللغة"),
    "last_read": MessageLookupByLibrary.simpleMessage("آخر قراءة"),
    "location_failed": MessageLookupByLibrary.simpleMessage("تعذر تحديد موقعك"),
    "location_subtitle": MessageLookupByLibrary.simpleMessage(
      "للحصول على مواقيت صلاة دقيقة",
    ),
    "location_title": MessageLookupByLibrary.simpleMessage("حدّد موقعك"),
    "maghrib": MessageLookupByLibrary.simpleMessage("المغرب"),
    "manual_subtitle": MessageLookupByLibrary.simpleMessage(
      "اختر مدينتك / ولايتك",
    ),
    "manually": MessageLookupByLibrary.simpleMessage("يدوياً"),
    "masjid_time": MessageLookupByLibrary.simpleMessage(
      "حان وقت الذهاب إلى المسجد",
    ),
    "meal_adhkar": MessageLookupByLibrary.simpleMessage(
      "أذكار الطعام والشراب والضيف",
    ),
    "meccan": MessageLookupByLibrary.simpleMessage("مكية"),
    "medinan": MessageLookupByLibrary.simpleMessage("مدنية"),
    "minute_short": MessageLookupByLibrary.simpleMessage("د"),
    "morning_adhkar": MessageLookupByLibrary.simpleMessage("اذكار الصباح"),
    "mosque_adhkar": MessageLookupByLibrary.simpleMessage("أذكار المسجد"),
    "nav_adhkar": MessageLookupByLibrary.simpleMessage("الأذكار"),
    "nav_prayers": MessageLookupByLibrary.simpleMessage("الصلاة"),
    "nav_qibla": MessageLookupByLibrary.simpleMessage("القبلة"),
    "nav_quran": MessageLookupByLibrary.simpleMessage("القرآن"),
    "next_prayer": MessageLookupByLibrary.simpleMessage("التالية"),
    "next_prayer_in": m3,
    "no_bookmarks": MessageLookupByLibrary.simpleMessage("لا علامات حفظ"),
    "no_internet": MessageLookupByLibrary.simpleMessage(
      "لا يوجد اتصال بالإنترنت",
    ),
    "no_results": MessageLookupByLibrary.simpleMessage("لا نتائج"),
    "noor": MessageLookupByLibrary.simpleMessage("نور الإيمان"),
    "open_adhkar": MessageLookupByLibrary.simpleMessage("إفتح الأذكار"),
    "open_settings": MessageLookupByLibrary.simpleMessage("افتح الإعدادات"),
    "page": MessageLookupByLibrary.simpleMessage("الصفحة"),
    "pages_read": m4,
    "pick_adhan": MessageLookupByLibrary.simpleMessage("اختر الأذان"),
    "pick_city": MessageLookupByLibrary.simpleMessage("اختر مدينتك"),
    "pick_country": MessageLookupByLibrary.simpleMessage("اختر بلدك"),
    "pick_location": MessageLookupByLibrary.simpleMessage("اختر موقعك"),
    "pick_state": MessageLookupByLibrary.simpleMessage("اختر ولايتك"),
    "prayer_adhkar": MessageLookupByLibrary.simpleMessage("أذكار الصلاة"),
    "prophet_dua": MessageLookupByLibrary.simpleMessage("أدعية النبي"),
    "prophets_dua": MessageLookupByLibrary.simpleMessage("أدعية الأنبياء"),
    "qibla_direction": MessageLookupByLibrary.simpleMessage("اتجاه القبلة"),
    "qiblah": MessageLookupByLibrary.simpleMessage("القبلة"),
    "qiblah_is_at": MessageLookupByLibrary.simpleMessage("اتجاه القبلة هو"),
    "quran_dua": MessageLookupByLibrary.simpleMessage("أدعية قرئانية"),
    "quran_subtitle": MessageLookupByLibrary.simpleMessage(
      "كلام الله .. نورًا لحياتك",
    ),
    "quran_title": MessageLookupByLibrary.simpleMessage("القرآن الكريم"),
    "reading_progress": MessageLookupByLibrary.simpleMessage("تقدم القراءة"),
    "relocate_auto": MessageLookupByLibrary.simpleMessage("تحديد تلقائي"),
    "relocate_body": m5,
    "relocate_body_unknown": m6,
    "relocate_manual": MessageLookupByLibrary.simpleMessage("اختيار يدوي"),
    "relocate_title": MessageLookupByLibrary.simpleMessage("هل غيّرت مكانك؟"),
    "reminder_after": m7,
    "reminder_before": m8,
    "reminder_title": m9,
    "reminders": MessageLookupByLibrary.simpleMessage("التنبيهات"),
    "remove": MessageLookupByLibrary.simpleMessage("إزالة"),
    "repetition": MessageLookupByLibrary.simpleMessage("التكرار"),
    "reset_progress": MessageLookupByLibrary.simpleMessage(
      "إعادة ضبط تقدم القراءة",
    ),
    "reset_progress_body": MessageLookupByLibrary.simpleMessage(
      "يمسح هذا الصفحات المحددة كمقروءة. تبقى علامات الحفظ.",
    ),
    "save": MessageLookupByLibrary.simpleMessage("حفظ"),
    "search_adhkar": MessageLookupByLibrary.simpleMessage("ابحث في الأذكار"),
    "search_surah": MessageLookupByLibrary.simpleMessage("ابحث عن سورة"),
    "sensor_not_supported": MessageLookupByLibrary.simpleMessage(
      "جهازك لا يدعم المستشعر",
    ),
    "set_new_alarm": MessageLookupByLibrary.simpleMessage("ضبط التنبيه"),
    "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "sleep_adhkar": MessageLookupByLibrary.simpleMessage("أذكار النوم"),
    "state": MessageLookupByLibrary.simpleMessage("الولاية"),
    "stop_adhan": MessageLookupByLibrary.simpleMessage("إيقاف الأذان"),
    "sun_rise": MessageLookupByLibrary.simpleMessage("الشروق"),
    "sun_rising": MessageLookupByLibrary.simpleMessage("الشمس تشرق"),
    "surah": MessageLookupByLibrary.simpleMessage("سورة"),
    "tagline_adhkar": MessageLookupByLibrary.simpleMessage(
      "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ — الرعد 28",
    ),
    "tagline_prayers": MessageLookupByLibrary.simpleMessage(
      "وَأَقِمِ الصَّلَاةَ لِذِكْرِي — طه 14",
    ),
    "tagline_qibla": MessageLookupByLibrary.simpleMessage(
      "فَوَلِّ وَجْهَكَ شَطْرَ الْمَسْجِدِ الْحَرَامِ — البقرة 144",
    ),
    "tagline_quran": MessageLookupByLibrary.simpleMessage(
      "إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ — الإسراء 9",
    ),
    "tasbeeh": MessageLookupByLibrary.simpleMessage("تسابيح"),
    "tips": MessageLookupByLibrary.simpleMessage("نصائح"),
    "today": MessageLookupByLibrary.simpleMessage("اليوم"),
    "try_again": MessageLookupByLibrary.simpleMessage("أعد المحاولة"),
    "verse_count": m10,
    "wait_please": MessageLookupByLibrary.simpleMessage("لحظة من فضلك "),
    "wake_up_adhkar": MessageLookupByLibrary.simpleMessage("أذكار الاستيقاظ"),
    "wc_adhkar": MessageLookupByLibrary.simpleMessage(
      "أذكار دخول وخروج الخلاء",
    ),
    "wudu_adhkar": MessageLookupByLibrary.simpleMessage("أذكار الوضوء"),
    "year_ended": MessageLookupByLibrary.simpleMessage("انتهت ايام السنة"),
  };
}

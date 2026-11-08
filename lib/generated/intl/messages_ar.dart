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

  static String m0(prayer) => "حان وقت ${prayer}";

  static String m1(count) => "${count} ذكر";

  static String m2(name) => "الجهة الأقرب: ${name}";

  static String m3(hours, minutes) => "${hours}س ${minutes}د";

  static String m4(minutes) => "${minutes}د";

  static String m5(prayer, time) => "${prayer} بعد ${time}";

  static String m6(name, days) =>
      "${Intl.plural(days, one: '${name} غداً', two: '${name} بعد يومين', few: '${name} بعد ${days} أيام', many: '${name} بعد ${days} يوماً', other: '${name} بعد ${days} يوم')}";

  static String m7(read, total) => "${read} من ${total} صفحة";

  static String m8(city, shift, saved) =>
      "تشير شبكتك إلى أنك قرب ${city}. تختلف أوقات الصلاة هناك بنحو ${shift} عن ${saved}.";

  static String m9(shift, saved) =>
      "تشير شبكتك إلى أنك في مكان آخر. تختلف أوقات الصلاة هناك بنحو ${shift} عن ${saved}.";

  static String m10(minutes, prayer) => "مرت ${minutes} د على ${prayer}";

  static String m11(minutes, prayer) => "تبقى ${minutes} د على ${prayer}";

  static String m12(prayer) => "تنبيه ${prayer}";

  static String m13(count) => "${count} آية";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_location": MessageLookupByLibrary.simpleMessage("إضافة الموقع"),
        "adhan_adhkar":
            MessageLookupByLibrary.simpleMessage("أذكار سماع الآذان"),
        "adhan_asr": MessageLookupByLibrary.simpleMessage("أذان العصر"),
        "adhan_chourouk": MessageLookupByLibrary.simpleMessage("وقت الشروق"),
        "adhan_dhuhr": MessageLookupByLibrary.simpleMessage("أذان الظهر"),
        "adhan_disabled":
            MessageLookupByLibrary.simpleMessage("تم إيقاف الأذان"),
        "adhan_enabled":
            MessageLookupByLibrary.simpleMessage("تم تفعيل الأذان"),
        "adhan_fajr": MessageLookupByLibrary.simpleMessage("أذان الفجر"),
        "adhan_isha": MessageLookupByLibrary.simpleMessage("أذان العشاء"),
        "adhan_maghrib": MessageLookupByLibrary.simpleMessage("أذان المغرب"),
        "adhan_now": m0,
        "adhkar": MessageLookupByLibrary.simpleMessage("الأذكار"),
        "adhkar_count": m1,
        "adjust_times": MessageLookupByLibrary.simpleMessage("تعديل الأوقات"),
        "adjust_times_hint": MessageLookupByLibrary.simpleMessage(
            "قدّم أو أخّر أي صلاة بدقائق لتوافق مسجدك."),
        "after_adhan": MessageLookupByLibrary.simpleMessage("بعد الأذان"),
        "after_prayer_adhkar":
            MessageLookupByLibrary.simpleMessage("أذكار بعد الصلاة"),
        "alarm_deleted": MessageLookupByLibrary.simpleMessage("تم حذف المنبه"),
        "alarm_saved": MessageLookupByLibrary.simpleMessage("تم حفظ المنبه"),
        "alarms_off": MessageLookupByLibrary.simpleMessage(
            "اسمح بالمنبهات والتذكيرات ليرنّ الأذان في وقته"),
        "asma_al_husna":
            MessageLookupByLibrary.simpleMessage("أسماء الله الحسنى"),
        "asma_failed":
            MessageLookupByLibrary.simpleMessage("تعذر تحميل الأسماء"),
        "asma_subtitle":
            MessageLookupByLibrary.simpleMessage("تسعة وتسعون اسماً"),
        "asr": MessageLookupByLibrary.simpleMessage("العصر"),
        "asr_hanafi": MessageLookupByLibrary.simpleMessage("الحنفي"),
        "asr_hint": MessageLookupByLibrary.simpleMessage(
            "الشافعية والمالكية والحنابلة على وقت الجمهور. والعصر عند الحنفية متأخر، حين يصير ظل الشيء مثليه."),
        "asr_standard": MessageLookupByLibrary.simpleMessage("الجمهور"),
        "asr_time": MessageLookupByLibrary.simpleMessage("وقت العصر"),
        "automatic": MessageLookupByLibrary.simpleMessage("تلقائي"),
        "automatic_meta":
            MessageLookupByLibrary.simpleMessage("الجهة الأقرب إلى موقعك"),
        "automatic_method_meta": m2,
        "back": MessageLookupByLibrary.simpleMessage("رجوع"),
        "before_adhan": MessageLookupByLibrary.simpleMessage("قبل الأذان"),
        "bookmark": MessageLookupByLibrary.simpleMessage("علامة"),
        "bookmarks": MessageLookupByLibrary.simpleMessage("علامات الحفظ"),
        "calculation_method":
            MessageLookupByLibrary.simpleMessage("طريقة الحساب"),
        "calibrate": MessageLookupByLibrary.simpleMessage("معايرة"),
        "calibrate_step_1": MessageLookupByLibrary.simpleMessage(
            "حرّك هاتفك ببطء على شكل الرقم 8 عدة مرات."),
        "calibrate_step_2": MessageLookupByLibrary.simpleMessage(
            "ابتعد عن المعادن والمغناطيس ومكبرات الصوت."),
        "calibrate_step_3": MessageLookupByLibrary.simpleMessage(
            "أمسك الهاتف أفقيًا ثم تحقق من السهم مجددًا."),
        "calibrate_title":
            MessageLookupByLibrary.simpleMessage("معايرة البوصلة"),
        "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "chikh_afassy_1":
            MessageLookupByLibrary.simpleMessage("أذان الشيخ العفاسي 1"),
        "chikh_elkourdi":
            MessageLookupByLibrary.simpleMessage("أذان الشيخ أحمد الكردي"),
        "chikh_elmajali":
            MessageLookupByLibrary.simpleMessage("أذان الشيخ حمزة المجالي"),
        "chikh_nafees":
            MessageLookupByLibrary.simpleMessage("أذان الشيخ أحمد النفيس"),
        "chilh_afassy_2":
            MessageLookupByLibrary.simpleMessage("أذان الشيخ العفاسي 2"),
        "city": MessageLookupByLibrary.simpleMessage("المدينة"),
        "close": MessageLookupByLibrary.simpleMessage("إغلاق"),
        "compass_error":
            MessageLookupByLibrary.simpleMessage("البوصلة لا تستجيب"),
        "comprehensive_duaa":
            MessageLookupByLibrary.simpleMessage("جوامع الدعاء"),
        "confirm": MessageLookupByLibrary.simpleMessage("ثبت"),
        "confirm_location":
            MessageLookupByLibrary.simpleMessage("تأكيد الموقع"),
        "continue_reading":
            MessageLookupByLibrary.simpleMessage("أكمل القراءة"),
        "country": MessageLookupByLibrary.simpleMessage("البلد"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("الوضع المظلم"),
        "dhuhr": MessageLookupByLibrary.simpleMessage("الظهر"),
        "distance_to_kaaba":
            MessageLookupByLibrary.simpleMessage("المسافة إلى الكعبة"),
        "done": MessageLookupByLibrary.simpleMessage("تم"),
        "duration_hm": m3,
        "duration_m": m4,
        "edit": MessageLookupByLibrary.simpleMessage("تعديل"),
        "enable_location_body": MessageLookupByLibrary.simpleMessage(
            "تأكد من تشغيل نظام تحديد المواقع وخدمات الموقع على هاتفك. يمكن أن يساعد ذلك في تحسين دقة البوصلة من خلال توفير بيانات إضافية."),
        "enable_location_permission": MessageLookupByLibrary.simpleMessage(
            "اسمح بالوصول إلى موقعك للمتابعة"),
        "enable_location_title":
            MessageLookupByLibrary.simpleMessage("تمكين خدمات الموقع"),
        "enter_location": MessageLookupByLibrary.simpleMessage("أضف موقعك"),
        "evening_adhkar": MessageLookupByLibrary.simpleMessage("اذكار المساء"),
        "every_day": MessageLookupByLibrary.simpleMessage("كل يوم"),
        "facing_qibla":
            MessageLookupByLibrary.simpleMessage("أنت متجه نحو القبلة"),
        "fajr": MessageLookupByLibrary.simpleMessage("الفجر"),
        "flat_phone_body": MessageLookupByLibrary.simpleMessage(
            "للحصول على القراءة الأكثر دقة، امسك هاتفك بشكل مسطح في يدك، بحيث يكون موازيًا للأرض. يمكن أن يؤثر إمالة الهاتف على قراءة البوصلة."),
        "flat_phone_title":
            MessageLookupByLibrary.simpleMessage("امسك هاتفك بشكل مسطح"),
        "full_screen_off": MessageLookupByLibrary.simpleMessage(
            "اسمح بالتنبيهات بملء الشاشة لتظهر شاشة الأذان"),
        "general_Adhkar": MessageLookupByLibrary.simpleMessage("أذكار متفرقة"),
        "gps": MessageLookupByLibrary.simpleMessage("GPS"),
        "gps_off": MessageLookupByLibrary.simpleMessage(
            "شغّل خدمة الموقع لتحديد القبلة"),
        "gps_subtitle":
            MessageLookupByLibrary.simpleMessage("استخدم موقعك الحالي"),
        "hajj_adhkar":
            MessageLookupByLibrary.simpleMessage("أذكار الحج والعمرة"),
        "high_latitude":
            MessageLookupByLibrary.simpleMessage("خطوط العرض العليا"),
        "high_latitude_hint": MessageLookupByLibrary.simpleMessage(
            "للأماكن التي يستمر فيها الشفق طوال الليل صيفاً."),
        "hijri_adjust_hint": MessageLookupByLibrary.simpleMessage(
            "لتعديل التاريخ بيوم، اختر الحساب الفلكي."),
        "hijri_adjustment":
            MessageLookupByLibrary.simpleMessage("تعديل بالأيام"),
        "hijri_date": MessageLookupByLibrary.simpleMessage("التاريخ الهجري"),
        "hizb": MessageLookupByLibrary.simpleMessage("حزب"),
        "home_adhkar":
            MessageLookupByLibrary.simpleMessage("أذكار دخول وخروج المنزل"),
        "imsak": MessageLookupByLibrary.simpleMessage("الإمساك"),
        "in_adhkar_text":
            MessageLookupByLibrary.simpleMessage("في نصوص الأذكار"),
        "isha": MessageLookupByLibrary.simpleMessage("العشاء"),
        "keep_from_magnetic_body": MessageLookupByLibrary.simpleMessage(
            "تجنب استخدام بوصلة هاتفك بالقرب من الأجسام المعدنية الكبيرة، أو المعدات الكهربائية، أو المغناطيسات، لأن ذلك يمكن أن يؤثر على دقة البوصلة."),
        "keep_from_magnetic_title":
            MessageLookupByLibrary.simpleMessage("ابتعد عن التداخل المغناطيسي"),
        "language": MessageLookupByLibrary.simpleMessage("اللغة"),
        "last_read": MessageLookupByLibrary.simpleMessage("آخر قراءة"),
        "last_third": MessageLookupByLibrary.simpleMessage("الثلث الأخير"),
        "lat_angle_based": MessageLookupByLibrary.simpleMessage("حسب الزاوية"),
        "lat_middle_night": MessageLookupByLibrary.simpleMessage("منتصف الليل"),
        "lat_one_seventh": MessageLookupByLibrary.simpleMessage("سُبع الليل"),
        "location_failed":
            MessageLookupByLibrary.simpleMessage("تعذر تحديد موقعك"),
        "location_needed": MessageLookupByLibrary.simpleMessage(
            "أضف موقعك لتظهر أوقات الصلاة"),
        "location_subtitle": MessageLookupByLibrary.simpleMessage(
            "للحصول على مواقيت صلاة دقيقة"),
        "location_title": MessageLookupByLibrary.simpleMessage("حدّد موقعك"),
        "maghrib": MessageLookupByLibrary.simpleMessage("المغرب"),
        "manual_subtitle":
            MessageLookupByLibrary.simpleMessage("اختر مدينتك / ولايتك"),
        "manually": MessageLookupByLibrary.simpleMessage("يدوياً"),
        "masjid_time":
            MessageLookupByLibrary.simpleMessage("حان وقت الذهاب إلى المسجد"),
        "meal_adhkar":
            MessageLookupByLibrary.simpleMessage("أذكار الطعام والشراب والضيف"),
        "meccan": MessageLookupByLibrary.simpleMessage("مكية"),
        "medinan": MessageLookupByLibrary.simpleMessage("مدنية"),
        "midnight": MessageLookupByLibrary.simpleMessage("منتصف الليل"),
        "minute_short": MessageLookupByLibrary.simpleMessage("د"),
        "morning_adhkar": MessageLookupByLibrary.simpleMessage("اذكار الصباح"),
        "mosque_adhkar": MessageLookupByLibrary.simpleMessage("أذكار المسجد"),
        "nav_adhkar": MessageLookupByLibrary.simpleMessage("الأذكار"),
        "nav_prayers": MessageLookupByLibrary.simpleMessage("الصلاة"),
        "nav_qibla": MessageLookupByLibrary.simpleMessage("القبلة"),
        "nav_quran": MessageLookupByLibrary.simpleMessage("القرآن"),
        "next_prayer_in": m5,
        "no_bookmarks":
            MessageLookupByLibrary.simpleMessage("لا علامات حفظ بعد"),
        "no_internet": MessageLookupByLibrary.simpleMessage(
            "لا يوجد اتصال. أعد المحاولة عند عودة الإنترنت."),
        "no_results": MessageLookupByLibrary.simpleMessage("لا نتائج"),
        "notifications_off": MessageLookupByLibrary.simpleMessage(
            "اسمح بالإشعارات ليصلك الأذان"),
        "occasion_arafah": MessageLookupByLibrary.simpleMessage("يوم عرفة"),
        "occasion_ashura": MessageLookupByLibrary.simpleMessage("عاشوراء"),
        "occasion_eid_adha": MessageLookupByLibrary.simpleMessage("عيد الأضحى"),
        "occasion_eid_fitr": MessageLookupByLibrary.simpleMessage("عيد الفطر"),
        "occasion_in_days": m6,
        "occasion_isra_miraj":
            MessageLookupByLibrary.simpleMessage("الإسراء والمعراج"),
        "occasion_laylat_al_qadr":
            MessageLookupByLibrary.simpleMessage("ليلة القدر"),
        "occasion_mawlid":
            MessageLookupByLibrary.simpleMessage("المولد النبوي"),
        "occasion_mid_shaban":
            MessageLookupByLibrary.simpleMessage("ليلة النصف من شعبان"),
        "occasion_new_year":
            MessageLookupByLibrary.simpleMessage("رأس السنة الهجرية"),
        "occasion_ramadan":
            MessageLookupByLibrary.simpleMessage("أول أيام رمضان"),
        "open_adhkar": MessageLookupByLibrary.simpleMessage("إفتح الأذكار"),
        "open_settings": MessageLookupByLibrary.simpleMessage("افتح الإعدادات"),
        "page": MessageLookupByLibrary.simpleMessage("الصفحة"),
        "pages_read": m7,
        "pick_adhan": MessageLookupByLibrary.simpleMessage("اختر الأذان"),
        "pick_city": MessageLookupByLibrary.simpleMessage("اختر مدينتك"),
        "pick_country": MessageLookupByLibrary.simpleMessage("اختر بلدك"),
        "pick_location": MessageLookupByLibrary.simpleMessage("اختر موقعك"),
        "pick_state": MessageLookupByLibrary.simpleMessage("اختر ولايتك"),
        "prayer_adhkar": MessageLookupByLibrary.simpleMessage("أذكار الصلاة"),
        "prayer_settings":
            MessageLookupByLibrary.simpleMessage("إعدادات الصلاة"),
        "prayer_times_failed":
            MessageLookupByLibrary.simpleMessage("تعذر تحميل أوقات الصلاة"),
        "prophet_dua": MessageLookupByLibrary.simpleMessage("أدعية النبي"),
        "prophets_dua": MessageLookupByLibrary.simpleMessage("أدعية الأنبياء"),
        "qibla_direction": MessageLookupByLibrary.simpleMessage("اتجاه القبلة"),
        "qiblah": MessageLookupByLibrary.simpleMessage("القبلة"),
        "quran_dua": MessageLookupByLibrary.simpleMessage("أدعية قرئانية"),
        "relocate_auto": MessageLookupByLibrary.simpleMessage("تحديد تلقائي"),
        "relocate_body": m8,
        "relocate_body_unknown": m9,
        "relocate_manual": MessageLookupByLibrary.simpleMessage("اختيار يدوي"),
        "relocate_title":
            MessageLookupByLibrary.simpleMessage("هل غيّرت مكانك؟"),
        "reminder_after": m10,
        "reminder_before": m11,
        "reminder_title": m12,
        "reminders": MessageLookupByLibrary.simpleMessage("التنبيهات"),
        "remove": MessageLookupByLibrary.simpleMessage("إزالة"),
        "reset": MessageLookupByLibrary.simpleMessage("إعادة الضبط"),
        "reset_progress":
            MessageLookupByLibrary.simpleMessage("إعادة ضبط تقدم القراءة"),
        "reset_progress_body": MessageLookupByLibrary.simpleMessage(
            "يمسح هذا الصفحات المحددة كمقروءة. تبقى علامات الحفظ."),
        "save": MessageLookupByLibrary.simpleMessage("حفظ"),
        "saved_alarms":
            MessageLookupByLibrary.simpleMessage("المنبهات المحفوظة"),
        "search_adhkar":
            MessageLookupByLibrary.simpleMessage("ابحث في الأذكار"),
        "search_surah": MessageLookupByLibrary.simpleMessage("ابحث عن سورة"),
        "sensor_not_supported": MessageLookupByLibrary.simpleMessage(
            "جهازك لا يحتوي على مستشعر بوصلة"),
        "set_new_alarm": MessageLookupByLibrary.simpleMessage("ضبط التنبيه"),
        "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "settings_saved":
            MessageLookupByLibrary.simpleMessage("تم تحديث أوقات الصلاة"),
        "sleep_adhkar": MessageLookupByLibrary.simpleMessage("أذكار النوم"),
        "state": MessageLookupByLibrary.simpleMessage("الولاية"),
        "stop_adhan": MessageLookupByLibrary.simpleMessage("إيقاف الأذان"),
        "sun_rise": MessageLookupByLibrary.simpleMessage("الشروق"),
        "sun_rising": MessageLookupByLibrary.simpleMessage("الشمس تشرق"),
        "surah": MessageLookupByLibrary.simpleMessage("سورة"),
        "tagline_adhkar": MessageLookupByLibrary.simpleMessage(
            "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ — الرعد 28"),
        "tagline_prayers": MessageLookupByLibrary.simpleMessage(
            "وَأَقِمِ الصَّلَاةَ لِذِكْرِي — طه 14"),
        "tagline_qibla": MessageLookupByLibrary.simpleMessage(
            "فَوَلِّ وَجْهَكَ شَطْرَ الْمَسْجِدِ الْحَرَامِ — البقرة 144"),
        "tagline_quran": MessageLookupByLibrary.simpleMessage(
            "إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ — الإسراء 9"),
        "tasbeeh": MessageLookupByLibrary.simpleMessage("تسابيح"),
        "today": MessageLookupByLibrary.simpleMessage("اليوم"),
        "try_again": MessageLookupByLibrary.simpleMessage("أعد المحاولة"),
        "verse_count": m13,
        "wait_please": MessageLookupByLibrary.simpleMessage("لحظة من فضلك "),
        "wake_up_adhkar":
            MessageLookupByLibrary.simpleMessage("أذكار الاستيقاظ"),
        "wc_adhkar":
            MessageLookupByLibrary.simpleMessage("أذكار دخول وخروج الخلاء"),
        "wudu_adhkar": MessageLookupByLibrary.simpleMessage("أذكار الوضوء")
      };
}

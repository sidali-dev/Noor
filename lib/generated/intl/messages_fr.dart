// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) => "${count} athkar";

  static String m1(hours, minutes) => "${hours} h ${minutes} min";

  static String m2(minutes) => "${minutes} min";

  static String m3(prayer, time) => "${prayer} dans ${time}";

  static String m4(read, total) => "${read} sur ${total} pages";

  static String m5(minutes, prayer) => "${minutes} min depuis ${prayer}";

  static String m6(minutes, prayer) =>
      "Il reste ${minutes} min avant ${prayer}";

  static String m7(prayer) => "Rappel ${prayer}";

  static String m8(count) => "${count} versets";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_location": MessageLookupByLibrary.simpleMessage(
          "Veuillez ajouter votre emplacement",
        ),
        "adhan_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar pour entendre l\'Adhan",
        ),
        "adhan_asr": MessageLookupByLibrary.simpleMessage("Adhan el Asr"),
        "adhan_chourouk": MessageLookupByLibrary.simpleMessage(
          "C\'est l\'heure du Chourouk",
        ),
        "adhan_dhuhr": MessageLookupByLibrary.simpleMessage("Adhan el Dhuhr"),
        "adhan_fajr": MessageLookupByLibrary.simpleMessage("Adhan el Fajr"),
        "adhan_isha": MessageLookupByLibrary.simpleMessage("Adhan el Isha"),
        "adhan_maghrib":
            MessageLookupByLibrary.simpleMessage("Adhan el Maghrib"),
        "adhkar": MessageLookupByLibrary.simpleMessage("Athkar"),
        "adhkar_count": m0,
        "adhkar_subtitle": MessageLookupByLibrary.simpleMessage(
          "Le repos du cœur, l\'apaisement de l\'âme",
        ),
        "after_adhan": MessageLookupByLibrary.simpleMessage("après l\'adhan"),
        "after_prayer_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar après la prière",
        ),
        "alarm_set_for":
            MessageLookupByLibrary.simpleMessage("Alarme réglée pour"),
        "asr": MessageLookupByLibrary.simpleMessage("Asr"),
        "back": MessageLookupByLibrary.simpleMessage("Retour"),
        "before_adhan": MessageLookupByLibrary.simpleMessage("avant l\'adhan"),
        "bookmark": MessageLookupByLibrary.simpleMessage("Marque-page"),
        "bookmarks": MessageLookupByLibrary.simpleMessage("Signets"),
        "calibrate": MessageLookupByLibrary.simpleMessage("Calibrer"),
        "calibrate_step_1": MessageLookupByLibrary.simpleMessage(
          "Déplacez lentement votre téléphone en forme de 8 plusieurs fois.",
        ),
        "calibrate_step_2": MessageLookupByLibrary.simpleMessage(
          "Éloignez-vous des métaux, aimants et haut-parleurs.",
        ),
        "calibrate_step_3": MessageLookupByLibrary.simpleMessage(
          "Tenez le téléphone à plat puis vérifiez à nouveau la flèche.",
        ),
        "calibrate_title": MessageLookupByLibrary.simpleMessage(
          "Calibrer la boussole",
        ),
        "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
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
        "city": MessageLookupByLibrary.simpleMessage("Ville"),
        "close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "comprehensive_duaa":
            MessageLookupByLibrary.simpleMessage("Dua complet"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
        "save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "confirm_location": MessageLookupByLibrary.simpleMessage(
          "Confirmer la position",
        ),
        "continue_reading": MessageLookupByLibrary.simpleMessage(
          "Continuer la lecture",
        ),
        "country": MessageLookupByLibrary.simpleMessage("Pays"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Mode Sombre"),
        "dhuhr": MessageLookupByLibrary.simpleMessage("Dhuhr"),
        "distance_to_kaaba": MessageLookupByLibrary.simpleMessage(
          "Distance jusqu\'à la Kaaba",
        ),
        "done": MessageLookupByLibrary.simpleMessage("Terminé"),
        "duration_hm": m1,
        "duration_m": m2,
        "enable_location": MessageLookupByLibrary.simpleMessage(
          "Veuillez activer le signal GPS",
        ),
        "enable_location_body": MessageLookupByLibrary.simpleMessage(
          "Assurez-vous que le GPS et les services de localisation de votre téléphone sont activés. Cela peut aider à améliorer la précision de la boussole en fournissant des données supplémentaires.",
        ),
        "enable_location_permission": MessageLookupByLibrary.simpleMessage(
          "Veuillez activer l\'autorisation de localisation",
        ),
        "enable_location_title": MessageLookupByLibrary.simpleMessage(
          "Activez les services de localisation",
        ),
        "enter_location": MessageLookupByLibrary.simpleMessage(
          "Entrez votre emplacement",
        ),
        "evening_adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar du soir"),
        "fajr": MessageLookupByLibrary.simpleMessage("Fajr"),
        "flat_phone_body": MessageLookupByLibrary.simpleMessage(
          "Pour une lecture la plus précise possible, tenez votre téléphone à plat dans votre main, parallèle au sol. L\'inclinaison du téléphone peut affecter la lecture de la boussole.",
        ),
        "flat_phone_title": MessageLookupByLibrary.simpleMessage(
          "Tenez votre téléphone à plat",
        ),
        "general_Adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar généraux"),
        "gps": MessageLookupByLibrary.simpleMessage("GPS"),
        "gps_subtitle": MessageLookupByLibrary.simpleMessage(
          "Utiliser votre position actuelle",
        ),
        "hajj_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar du Hajj et de la Omra",
        ),
        "hizb": MessageLookupByLibrary.simpleMessage("Hizb"),
        "home_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar pour entrer et sortir de la maison",
        ),
        "in_adhkar_text":
            MessageLookupByLibrary.simpleMessage("Dans les athkar"),
        "info": MessageLookupByLibrary.simpleMessage("Informations"),
        "isha": MessageLookupByLibrary.simpleMessage("Isha"),
        "its": MessageLookupByLibrary.simpleMessage("c\'est"),
        "keep_from_magnetic_body": MessageLookupByLibrary.simpleMessage(
          "Évitez d\'utiliser la boussole de votre téléphone près de grands objets métalliques, d\'équipements électriques ou d\'aimants, car cela peut interférer avec la précision de la boussole.",
        ),
        "keep_from_magnetic_title": MessageLookupByLibrary.simpleMessage(
          "Éloignez-vous des interférences magnétiques",
        ),
        "language": MessageLookupByLibrary.simpleMessage("Langue"),
        "last_read": MessageLookupByLibrary.simpleMessage("Dernière lecture"),
        "location_failed": MessageLookupByLibrary.simpleMessage(
          "Impossible de trouver votre position",
        ),
        "location_subtitle": MessageLookupByLibrary.simpleMessage(
          "Pour des horaires de prière précis",
        ),
        "location_title": MessageLookupByLibrary.simpleMessage(
          "Indiquez votre position",
        ),
        "maghrib": MessageLookupByLibrary.simpleMessage("Maghrib"),
        "manual_subtitle": MessageLookupByLibrary.simpleMessage(
          "Choisissez votre ville / wilaya",
        ),
        "manually": MessageLookupByLibrary.simpleMessage("Manuellement"),
        "masjid_time": MessageLookupByLibrary.simpleMessage(
          "Temps d\'aller à la mosquée",
        ),
        "meal_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar pour la nourriture, les boissons et les invités",
        ),
        "meccan": MessageLookupByLibrary.simpleMessage("Mecquoise"),
        "medinan": MessageLookupByLibrary.simpleMessage("Médinoise"),
        "minute_short": MessageLookupByLibrary.simpleMessage("min"),
        "morning_adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar du matin"),
        "mosque_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar de la mosquée",
        ),
        "nav_adhkar": MessageLookupByLibrary.simpleMessage("Athkar"),
        "nav_prayers": MessageLookupByLibrary.simpleMessage("Prières"),
        "nav_qibla": MessageLookupByLibrary.simpleMessage("Qibla"),
        "nav_quran": MessageLookupByLibrary.simpleMessage("Coran"),
        "next_prayer": MessageLookupByLibrary.simpleMessage("Prochaine"),
        "next_prayer_in": m3,
        "no_bookmarks": MessageLookupByLibrary.simpleMessage("Pas de signets"),
        "no_internet": MessageLookupByLibrary.simpleMessage(
          "Pas de connexion Internet",
        ),
        "no_results": MessageLookupByLibrary.simpleMessage("Aucun résultat"),
        "noor": MessageLookupByLibrary.simpleMessage("Noor Imene"),
        "open_adhkar": MessageLookupByLibrary.simpleMessage("Ouvrir Athkar"),
        "open_settings": MessageLookupByLibrary.simpleMessage(
          "Ouvrir les réglages",
        ),
        "page": MessageLookupByLibrary.simpleMessage("Page"),
        "pages_read": m4,
        "pick_adhan": MessageLookupByLibrary.simpleMessage("Choisissez Adhan"),
        "pick_city":
            MessageLookupByLibrary.simpleMessage("Choisissez votre ville"),
        "pick_country": MessageLookupByLibrary.simpleMessage(
          "Choisissez votre pays",
        ),
        "pick_location": MessageLookupByLibrary.simpleMessage(
          "Choisissez votre emplacement",
        ),
        "pick_state":
            MessageLookupByLibrary.simpleMessage("Choisissez votre état"),
        "prayer_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar de la prière",
        ),
        "prophet_dua": MessageLookupByLibrary.simpleMessage("Dua du Prophète"),
        "prophets_dua":
            MessageLookupByLibrary.simpleMessage("Dua des Prophètes"),
        "qibla_direction": MessageLookupByLibrary.simpleMessage(
          "Direction de la Qibla",
        ),
        "qiblah": MessageLookupByLibrary.simpleMessage("La Qiblah"),
        "qiblah_is_at": MessageLookupByLibrary.simpleMessage("La Qiblah est à"),
        "quran_dua": MessageLookupByLibrary.simpleMessage("Dua du Coran"),
        "quran_subtitle": MessageLookupByLibrary.simpleMessage(
          "La parole de Dieu, lumière de votre vie",
        ),
        "quran_title": MessageLookupByLibrary.simpleMessage("Le Noble Coran"),
        "reading_progress": MessageLookupByLibrary.simpleMessage(
          "Progression de lecture",
        ),
        "reminder_after": m5,
        "reminder_before": m6,
        "reminder_title": m7,
        "reminders": MessageLookupByLibrary.simpleMessage("Rappels"),
        "remove": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "repetition": MessageLookupByLibrary.simpleMessage("Répétition"),
        "reset_progress": MessageLookupByLibrary.simpleMessage(
          "Réinitialiser la progression",
        ),
        "reset_progress_body": MessageLookupByLibrary.simpleMessage(
          "Cela efface les pages lues. Vos signets sont conservés.",
        ),
        "search_adhkar": MessageLookupByLibrary.simpleMessage(
          "Rechercher des athkar",
        ),
        "search_surah": MessageLookupByLibrary.simpleMessage(
          "Rechercher une sourate",
        ),
        "sensor_not_supported": MessageLookupByLibrary.simpleMessage(
          "Votre appareil ne prend pas en charge le capteur",
        ),
        "set_new_alarm":
            MessageLookupByLibrary.simpleMessage("définir une alarme"),
        "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "sleep_adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar du coucher"),
        "state": MessageLookupByLibrary.simpleMessage("État"),
        "stop_adhan": MessageLookupByLibrary.simpleMessage("Arrêter l\'Adhan"),
        "sun_rise": MessageLookupByLibrary.simpleMessage("Lever du soleil"),
        "sun_rising": MessageLookupByLibrary.simpleMessage("Le soleil se lève"),
        "surah": MessageLookupByLibrary.simpleMessage("Sourate"),
        "tagline_adhkar": MessageLookupByLibrary.simpleMessage(
          "C’est par l’évocation d’Allah que les cœurs s’apaisent. — Ar-Ra’d 13:28",
        ),
        "tagline_prayers": MessageLookupByLibrary.simpleMessage(
          "Accomplis la prière pour te souvenir de Moi. — Ta-Ha 20:14",
        ),
        "tagline_qibla": MessageLookupByLibrary.simpleMessage(
          "Tourne ton visage vers la Mosquée sacrée. — Al-Baqara 2:144",
        ),
        "tagline_quran": MessageLookupByLibrary.simpleMessage(
          "Ce Coran guide vers ce qu’il y a de plus droit. — Al-Isra 17:9",
        ),
        "tasbeeh": MessageLookupByLibrary.simpleMessage("Tasbeehs"),
        "tips": MessageLookupByLibrary.simpleMessage("Conseils"),
        "today": MessageLookupByLibrary.simpleMessage("Aujourd\'hui"),
        "try_again": MessageLookupByLibrary.simpleMessage("Réessayer"),
        "verse_count": m8,
        "wait_please": MessageLookupByLibrary.simpleMessage(
          "Cela peut prendre un moment",
        ),
        "wake_up_adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar du réveil"),
        "wc_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar pour entrer et sortir des toilettes",
        ),
        "wudu_adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar des ablutions"),
        "year_ended": MessageLookupByLibrary.simpleMessage(
          "Les jours de l\'année sont terminés",
        ),
      };
}

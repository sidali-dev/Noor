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

  static String m0(prayer) => "C\'est l\'heure de ${prayer}";

  static String m1(count) => "${count} athkar";

  static String m2(name) => "Autorité la plus proche : ${name}";

  static String m3(hours, minutes) => "${hours} h ${minutes} min";

  static String m4(minutes) => "${minutes} min";

  static String m5(prayer, time) => "${prayer} dans ${time}";

  static String m6(name, days) =>
      "${Intl.plural(days, one: '${name} demain', other: '${name} dans ${days} jours')}";

  static String m7(read, total) => "${read} sur ${total} pages";

  static String m8(city, shift, saved) =>
      "Votre réseau indique que vous êtes près de ${city}. Les heures de prière y diffèrent d\'environ ${shift} de celles de ${saved}.";

  static String m9(shift, saved) =>
      "Votre réseau indique que vous êtes ailleurs. Les heures de prière y diffèrent d\'environ ${shift} de celles de ${saved}.";

  static String m10(minutes, prayer) => "${minutes} min depuis ${prayer}";

  static String m11(minutes, prayer) =>
      "Il reste ${minutes} min avant ${prayer}";

  static String m12(prayer) => "Rappel ${prayer}";

  static String m13(count) => "${count} versets";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_location": MessageLookupByLibrary.simpleMessage(
          "Ajouter un emplacement",
        ),
        "adhan_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar pour entendre l\'Adhan",
        ),
        "adhan_asr": MessageLookupByLibrary.simpleMessage("Adhan el Asr"),
        "adhan_chourouk": MessageLookupByLibrary.simpleMessage(
          "C\'est l\'heure du Chourouk",
        ),
        "adhan_dhuhr": MessageLookupByLibrary.simpleMessage("Adhan el Dhuhr"),
        "adhan_disabled":
            MessageLookupByLibrary.simpleMessage("Adhan désactivé"),
        "adhan_enabled": MessageLookupByLibrary.simpleMessage("Adhan activé"),
        "adhan_fajr": MessageLookupByLibrary.simpleMessage("Adhan el Fajr"),
        "adhan_isha": MessageLookupByLibrary.simpleMessage("Adhan el Isha"),
        "adhan_maghrib":
            MessageLookupByLibrary.simpleMessage("Adhan el Maghrib"),
        "adhan_now": m0,
        "adhkar": MessageLookupByLibrary.simpleMessage("Athkar"),
        "adhkar_count": m1,
        "adhkar_subtitle": MessageLookupByLibrary.simpleMessage(
          "Le repos du cœur, l\'apaisement de l\'âme",
        ),
        "adjust_times":
            MessageLookupByLibrary.simpleMessage("Ajuster les heures"),
        "adjust_times_hint": MessageLookupByLibrary.simpleMessage(
          "Décalez une prière de quelques minutes pour suivre votre mosquée.",
        ),
        "after_adhan": MessageLookupByLibrary.simpleMessage("après l\'adhan"),
        "after_prayer_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar après la prière",
        ),
        "alarm_deleted":
            MessageLookupByLibrary.simpleMessage("Alarme supprimée"),
        "alarm_saved":
            MessageLookupByLibrary.simpleMessage("Alarme enregistrée"),
        "alarm_set_for":
            MessageLookupByLibrary.simpleMessage("Alarme réglée pour"),
        "alarms_off": MessageLookupByLibrary.simpleMessage(
          "Autorisez les alarmes et rappels pour que l\'adhan sonne à l\'heure",
        ),
        "asma_al_husna": MessageLookupByLibrary.simpleMessage(
          "Les beaux noms d\'Allah",
        ),
        "asma_failed": MessageLookupByLibrary.simpleMessage(
          "Impossible de charger les noms",
        ),
        "asma_subtitle": MessageLookupByLibrary.simpleMessage(
          "Les 99 noms d\'Allah",
        ),
        "asr": MessageLookupByLibrary.simpleMessage("Asr"),
        "asr_hanafi": MessageLookupByLibrary.simpleMessage("Hanafite"),
        "asr_hint": MessageLookupByLibrary.simpleMessage(
          "Chaféites, malikites et hanbalites suivent l\'heure standard. L\'Asr hanafite est plus tard, quand l\'ombre fait deux fois la longueur de l\'objet.",
        ),
        "asr_standard": MessageLookupByLibrary.simpleMessage("Standard"),
        "asr_time": MessageLookupByLibrary.simpleMessage("Heure d\'Asr"),
        "automatic": MessageLookupByLibrary.simpleMessage("Automatique"),
        "automatic_meta": MessageLookupByLibrary.simpleMessage(
          "L\'autorité la plus proche de votre position",
        ),
        "automatic_method_meta": m2,
        "back": MessageLookupByLibrary.simpleMessage("Retour"),
        "before_adhan": MessageLookupByLibrary.simpleMessage("avant l\'adhan"),
        "bookmark": MessageLookupByLibrary.simpleMessage("Marque-page"),
        "bookmarks": MessageLookupByLibrary.simpleMessage("Signets"),
        "calculation_method": MessageLookupByLibrary.simpleMessage(
          "Méthode de calcul",
        ),
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
        "compass_error": MessageLookupByLibrary.simpleMessage(
          "La boussole ne répond pas",
        ),
        "comprehensive_duaa":
            MessageLookupByLibrary.simpleMessage("Dua complet"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
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
        "duration_hm": m3,
        "duration_m": m4,
        "edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "edit_alarm":
            MessageLookupByLibrary.simpleMessage("Modifier l\'alarme"),
        "enable_location": MessageLookupByLibrary.simpleMessage(
          "Veuillez activer le signal GPS",
        ),
        "enable_location_body": MessageLookupByLibrary.simpleMessage(
          "Assurez-vous que le GPS et les services de localisation de votre téléphone sont activés. Cela peut aider à améliorer la précision de la boussole en fournissant des données supplémentaires.",
        ),
        "enable_location_permission": MessageLookupByLibrary.simpleMessage(
          "Autorisez l\'accès à la position pour continuer",
        ),
        "enable_location_title": MessageLookupByLibrary.simpleMessage(
          "Activez les services de localisation",
        ),
        "enter_location": MessageLookupByLibrary.simpleMessage(
          "Entrez votre emplacement",
        ),
        "evening_adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar du soir"),
        "every_day": MessageLookupByLibrary.simpleMessage("Tous les jours"),
        "facing_qibla": MessageLookupByLibrary.simpleMessage("Face à la qibla"),
        "fajr": MessageLookupByLibrary.simpleMessage("Fajr"),
        "flat_phone_body": MessageLookupByLibrary.simpleMessage(
          "Pour une lecture la plus précise possible, tenez votre téléphone à plat dans votre main, parallèle au sol. L\'inclinaison du téléphone peut affecter la lecture de la boussole.",
        ),
        "flat_phone_title": MessageLookupByLibrary.simpleMessage(
          "Tenez votre téléphone à plat",
        ),
        "full_screen_off": MessageLookupByLibrary.simpleMessage(
          "Autorisez les alertes plein écran pour que l\'écran de l\'adhan s\'affiche",
        ),
        "general_Adhkar":
            MessageLookupByLibrary.simpleMessage("Athkar généraux"),
        "gps": MessageLookupByLibrary.simpleMessage("GPS"),
        "gps_off": MessageLookupByLibrary.simpleMessage(
          "Activez la localisation pour trouver la qibla",
        ),
        "gps_subtitle": MessageLookupByLibrary.simpleMessage(
          "Utiliser votre position actuelle",
        ),
        "hajj_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar du Hajj et de la Omra",
        ),
        "high_latitude":
            MessageLookupByLibrary.simpleMessage("Hautes latitudes"),
        "high_latitude_hint": MessageLookupByLibrary.simpleMessage(
          "Pour les régions où le crépuscule dure toute la nuit en été.",
        ),
        "hijri_adjust_hint": MessageLookupByLibrary.simpleMessage(
          "Pour décaler la date d\'un jour, choisissez le calcul astronomique.",
        ),
        "hijri_adjustment": MessageLookupByLibrary.simpleMessage(
          "Décaler de jours",
        ),
        "hijri_date": MessageLookupByLibrary.simpleMessage("Date de l\'Hégire"),
        "hizb": MessageLookupByLibrary.simpleMessage("Hizb"),
        "home_adhkar": MessageLookupByLibrary.simpleMessage(
          "Athkar pour entrer et sortir de la maison",
        ),
        "imsak": MessageLookupByLibrary.simpleMessage("Imsak"),
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
        "last_third": MessageLookupByLibrary.simpleMessage("Dernier tiers"),
        "lat_angle_based":
            MessageLookupByLibrary.simpleMessage("Selon l\'angle"),
        "lat_middle_night": MessageLookupByLibrary.simpleMessage(
          "Milieu de la nuit",
        ),
        "lat_one_seventh": MessageLookupByLibrary.simpleMessage(
          "Un septième de la nuit",
        ),
        "location_failed": MessageLookupByLibrary.simpleMessage(
          "Impossible de trouver votre position",
        ),
        "location_needed": MessageLookupByLibrary.simpleMessage(
          "Ajoutez votre position pour voir les horaires",
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
        "midnight": MessageLookupByLibrary.simpleMessage("Minuit"),
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
        "next_prayer_in": m5,
        "no_bookmarks": MessageLookupByLibrary.simpleMessage(
          "Aucun signet pour l\'instant",
        ),
        "no_internet": MessageLookupByLibrary.simpleMessage(
          "Pas de connexion. Réessayez une fois en ligne.",
        ),
        "no_results": MessageLookupByLibrary.simpleMessage("Aucun résultat"),
        "notifications_off": MessageLookupByLibrary.simpleMessage(
          "Autorisez les notifications pour que l\'adhan puisse sonner",
        ),
        "occasion_arafah":
            MessageLookupByLibrary.simpleMessage("Jour d\'Arafat"),
        "occasion_ashura": MessageLookupByLibrary.simpleMessage("Achoura"),
        "occasion_eid_adha":
            MessageLookupByLibrary.simpleMessage("Aïd al-Adha"),
        "occasion_eid_fitr":
            MessageLookupByLibrary.simpleMessage("Aïd al-Fitr"),
        "occasion_in_days": m6,
        "occasion_isra_miraj": MessageLookupByLibrary.simpleMessage(
          "Isra et Miraj",
        ),
        "occasion_laylat_al_qadr": MessageLookupByLibrary.simpleMessage(
          "Laylat al-Qadr",
        ),
        "occasion_mawlid": MessageLookupByLibrary.simpleMessage("Mawlid"),
        "occasion_mid_shaban":
            MessageLookupByLibrary.simpleMessage("Mi-Chaabane"),
        "occasion_new_year": MessageLookupByLibrary.simpleMessage(
          "Nouvel An de l\'Hégire",
        ),
        "occasion_ramadan": MessageLookupByLibrary.simpleMessage(
          "Premier jour du Ramadan",
        ),
        "open_adhkar": MessageLookupByLibrary.simpleMessage("Ouvrir Athkar"),
        "open_settings": MessageLookupByLibrary.simpleMessage(
          "Ouvrir les réglages",
        ),
        "page": MessageLookupByLibrary.simpleMessage("Page"),
        "pages_read": m7,
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
        "prayer_settings": MessageLookupByLibrary.simpleMessage(
          "Réglages des prières",
        ),
        "prayer_times_failed": MessageLookupByLibrary.simpleMessage(
          "Impossible de charger les horaires",
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
        "relocate_auto": MessageLookupByLibrary.simpleMessage(
          "Détecter automatiquement",
        ),
        "relocate_body": m8,
        "relocate_body_unknown": m9,
        "relocate_manual": MessageLookupByLibrary.simpleMessage(
          "Choisir manuellement",
        ),
        "relocate_title": MessageLookupByLibrary.simpleMessage(
          "Avez-vous changé de lieu ?",
        ),
        "reminder_after": m10,
        "reminder_before": m11,
        "reminder_title": m12,
        "reminders": MessageLookupByLibrary.simpleMessage("Rappels"),
        "remove": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "repetition": MessageLookupByLibrary.simpleMessage("Répétition"),
        "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "reset_progress": MessageLookupByLibrary.simpleMessage(
          "Réinitialiser la progression",
        ),
        "reset_progress_body": MessageLookupByLibrary.simpleMessage(
          "Cela efface les pages lues. Vos signets sont conservés.",
        ),
        "save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "saved_alarms": MessageLookupByLibrary.simpleMessage(
          "Alarmes enregistrées",
        ),
        "search_adhkar": MessageLookupByLibrary.simpleMessage(
          "Rechercher des athkar",
        ),
        "search_surah": MessageLookupByLibrary.simpleMessage(
          "Rechercher une sourate",
        ),
        "sensor_not_supported": MessageLookupByLibrary.simpleMessage(
          "Votre appareil n\'a pas de capteur de boussole",
        ),
        "set_new_alarm":
            MessageLookupByLibrary.simpleMessage("Définir une alarme"),
        "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "settings_saved": MessageLookupByLibrary.simpleMessage(
          "Horaires mis à jour",
        ),
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
          "Ce Coran guide vers ce qu’il y a de plus droit. — Al-⁠Isra 17:9",
        ),
        "tasbeeh": MessageLookupByLibrary.simpleMessage("Tasbeehs"),
        "tips": MessageLookupByLibrary.simpleMessage("Conseils"),
        "today": MessageLookupByLibrary.simpleMessage("Aujourd\'hui"),
        "try_again": MessageLookupByLibrary.simpleMessage("Réessayer"),
        "verse_count": m13,
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
      };
}

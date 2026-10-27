import 'package:flutter/material.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';

class AdhanTexts {
  final S s;

  AdhanTexts(this.s);

  static Future<AdhanTexts> load([String? languageCode]) async {
    final lang = languageCode ?? AppPrefs.languageCode;
    final s = await S.load(Locale(lang));
    return AdhanTexts(s);
  }

  String prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return s.fajr;
      case Prayer.chourouk:
        return s.sun_rise;
      case Prayer.dhuhr:
        return s.dhuhr;
      case Prayer.asr:
        return s.asr;
      case Prayer.maghrib:
        return s.maghrib;
      case Prayer.isha:
        return s.isha;
    }
  }

  String adhanTitle(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return s.adhan_fajr;
      case Prayer.chourouk:
        return s.adhan_chourouk;
      case Prayer.dhuhr:
        return s.adhan_dhuhr;
      case Prayer.asr:
        return s.adhan_asr;
      case Prayer.maghrib:
        return s.adhan_maghrib;
      case Prayer.isha:
        return s.adhan_isha;
    }
  }

  String adhanBody(Prayer prayer) {
    if (prayer == Prayer.chourouk) {
      return s.sun_rising;
    }
    return s.masjid_time;
  }

  String get stopAdhan => s.stop_adhan;

  String reminderTitle(Prayer prayer) => s.reminder_title(prayerName(prayer));

  String reminderBody(Prayer prayer, int minutes) {
    final name = prayerName(prayer);
    if (minutes < 0) {
      return s.reminder_before(minutes.abs(), name);
    } else {
      return s.reminder_after(minutes.abs(), name);
    }
  }
}

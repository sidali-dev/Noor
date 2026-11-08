import 'package:noor/features/adhan/models/prayer.dart';

/// A choice the AlAdhan API takes, named in the app's three languages.
class ApiOption<T> {
  final T value;
  final String en;
  final String fr;
  final String ar;

  const ApiOption(this.value, this.en, this.fr, this.ar);

  String name(String languageCode) => switch (languageCode) {
        'ar' => ar,
        'fr' => fr,
        _ => en,
      };
}

/// Calculation methods (`method`), as listed by `/v1/methods`. 99 (custom
/// angles) is left out: it needs its own angle settings.
const List<ApiOption<int>> calculationMethods = [
  ApiOption(3, 'Muslim World League', 'Ligue islamique mondiale',
      'رابطة العالم الإسلامي'),
  ApiOption(4, 'Umm Al-Qura University, Makkah',
      'Université Umm Al-Qura, La Mecque', 'جامعة أم القرى، مكة المكرمة'),
  ApiOption(
      5,
      'Egyptian General Authority of Survey',
      'Autorité générale égyptienne d\'arpentage',
      'الهيئة المصرية العامة للمساحة'),
  ApiOption(19, 'Algeria', 'Algérie', 'الجزائر'),
  ApiOption(21, 'Morocco', 'Maroc', 'المغرب'),
  ApiOption(18, 'Tunisia', 'Tunisie', 'تونس'),
  ApiOption(23, 'Ministry of Awqaf, Jordan', 'Ministère des Awqaf, Jordanie',
      'وزارة الأوقاف والشؤون والمقدسات الإسلامية، الأردن'),
  ApiOption(8, 'Gulf Region', 'Région du Golfe', 'منطقة الخليج'),
  ApiOption(9, 'Kuwait', 'Koweït', 'الكويت'),
  ApiOption(10, 'Qatar', 'Qatar', 'قطر'),
  ApiOption(16, 'Dubai (experimental)', 'Dubaï (expérimental)', 'دبي (تجريبي)'),
  ApiOption(13, 'Diyanet İşleri Başkanlığı, Turkey', 'Diyanet, Turquie',
      'رئاسة الشؤون الدينية، تركيا'),
  ApiOption(
      12,
      'Union of Islamic Organisations of France',
      'Union des organisations islamiques de France',
      'اتحاد المنظمات الإسلامية في فرنسا'),
  ApiOption(22, 'Islamic Community of Lisbon',
      'Communauté islamique de Lisbonne', 'الجماعة الإسلامية في لشبونة'),
  ApiOption(
      14,
      'Spiritual Administration of Muslims of Russia',
      'Administration spirituelle des musulmans de Russie',
      'الإدارة الدينية لمسلمي روسيا'),
  ApiOption(
      2,
      'Islamic Society of North America',
      'Société islamique d\'Amérique du Nord',
      'الجمعية الإسلامية لأمريكا الشمالية'),
  ApiOption(
      15,
      'Moonsighting Committee Worldwide',
      'Comité mondial d\'observation du croissant',
      'لجنة رؤية الهلال العالمية'),
  ApiOption(
      1,
      'University of Islamic Sciences, Karachi',
      'Université des sciences islamiques, Karachi',
      'جامعة العلوم الإسلامية، كراتشي'),
  ApiOption(11, 'Majlis Ugama Islam Singapura', 'Majlis Ugama Islam Singapura',
      'مجلس الشؤون الإسلامية، سنغافورة'),
  ApiOption(17, 'JAKIM, Malaysia', 'JAKIM, Malaisie',
      'إدارة التنمية الإسلامية، ماليزيا'),
  ApiOption(20, 'KEMENAG, Indonesia', 'KEMENAG, Indonésie',
      'وزارة الشؤون الدينية، إندونيسيا'),
  ApiOption(
      7,
      'Institute of Geophysics, University of Tehran',
      'Institut de géophysique, Université de Téhéran',
      'معهد الجيوفيزياء، جامعة طهران'),
  ApiOption(0, 'Shia Ithna-Ashari (Jafari)', 'Chiite duodécimain (Jafari)',
      'الشيعة الإثنا عشرية (الجعفري)'),
];

/// Hijri calendar methods (`calendarMethod`); the API defaults to HJCoSA.
const List<ApiOption<String>> hijriMethods = [
  ApiOption(
      'HJCoSA',
      'High Judicial Council of Saudi Arabia',
      'Haut Conseil judiciaire d\'Arabie saoudite',
      'المجلس الأعلى للقضاء السعودي'),
  ApiOption('UAQ', 'Umm al-Qura', 'Umm al-Qura', 'أم القرى'),
  ApiOption('DIYANET', 'Diyanet, Turkey', 'Diyanet, Turquie',
      'رئاسة الشؤون الدينية، تركيا'),
  ApiOption('MATHEMATICAL', 'Astronomical calculation', 'Calcul astronomique',
      'الحساب الفلكي'),
];

const String defaultHijriMethod = 'HJCoSA';

/// The only Hijri method the API lets the user shift by whole days.
const String adjustableHijriMethod = 'MATHEMATICAL';

/// How the prayer calendar is calculated. The defaults ask the API for what
/// it picks on its own, so a user who never opens the settings keeps the
/// times they had.
class PrayerSettings {
  /// Null: the API picks the authority nearest the location.
  final int? method;

  /// 0 Shafi'i, Maliki and Hanbali; 1 Hanafi (a later Asr).
  final int school;

  /// `latitudeAdjustmentMethod`: 1 middle of the night, 2 one seventh,
  /// 3 angle based. Null: the API's own choice.
  final int? highLatitude;

  /// Minutes added to each prayer, keyed by [Prayer.key].
  final Map<String, int> tune;

  final String hijriMethod;

  /// Days, only sent with [adjustableHijriMethod].
  final int hijriAdjustment;

  const PrayerSettings({
    this.method,
    this.school = 0,
    this.highLatitude,
    this.tune = const {},
    this.hijriMethod = defaultHijriMethod,
    this.hijriAdjustment = 0,
  });

  static const int tuneLimit = 30;
  static const int hijriAdjustmentLimit = 2;

  int tuneFor(Prayer prayer) => tune[prayer.key] ?? 0;

  bool get isDefault => this == const PrayerSettings();

  PrayerSettings copyWith({
    int? Function()? method,
    int? school,
    int? Function()? highLatitude,
    Map<String, int>? tune,
    String? hijriMethod,
    int? hijriAdjustment,
  }) =>
      PrayerSettings(
        method: method != null ? method() : this.method,
        school: school ?? this.school,
        highLatitude: highLatitude != null ? highLatitude() : this.highLatitude,
        tune: tune ?? this.tune,
        hijriMethod: hijriMethod ?? this.hijriMethod,
        hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
      );

  PrayerSettings withTune(Prayer prayer, int minutes) => copyWith(
        tune: {...tune, prayer.key: minutes}..removeWhere((_, m) => m == 0),
      );

  /// The calendar endpoints' query parameters; empty for the defaults.
  Map<String, String> query() {
    String t(Prayer p) => '${tuneFor(p)}';
    final tuned = tune.values.any((m) => m != 0);
    return {
      if (method != null) 'method': '$method',
      if (school != 0) 'school': '$school',
      if (highLatitude != null) 'latitudeAdjustmentMethod': '$highLatitude',
      // Imsak,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Sunset,Isha,Midnight. Imsak
      // follows Fajr so it stays the same margin before it.
      if (tuned)
        'tune': [
          t(Prayer.fajr),
          t(Prayer.fajr),
          t(Prayer.chourouk),
          t(Prayer.dhuhr),
          t(Prayer.asr),
          t(Prayer.maghrib),
          '0',
          t(Prayer.isha),
          '0',
        ].join(','),
      if (hijriMethod != defaultHijriMethod) 'calendarMethod': hijriMethod,
      if (hijriMethod == adjustableHijriMethod && hijriAdjustment != 0)
        'adjustment': '$hijriAdjustment',
    };
  }

  Map<String, dynamic> toJson() => {
        if (method != null) 'method': method,
        'school': school,
        if (highLatitude != null) 'highLatitude': highLatitude,
        'tune': tune,
        'hijriMethod': hijriMethod,
        'hijriAdjustment': hijriAdjustment,
      };

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    int? asInt(Object? v) => v is num ? v.toInt() : null;
    final rawTune = json['tune'];
    return PrayerSettings(
      method: asInt(json['method']),
      school: asInt(json['school']) ?? 0,
      highLatitude: asInt(json['highLatitude']),
      tune: {
        if (rawTune is Map)
          for (final e in rawTune.entries)
            if (e.value is num && e.value != 0)
              '${e.key}': (e.value as num).toInt(),
      },
      hijriMethod: json['hijriMethod'] is String
          ? json['hijriMethod'] as String
          : defaultHijriMethod,
      hijriAdjustment: asInt(json['hijriAdjustment']) ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerSettings &&
      other.method == method &&
      other.school == school &&
      other.highLatitude == highLatitude &&
      other.hijriMethod == hijriMethod &&
      other.hijriAdjustment == hijriAdjustment &&
      other.tune.length == tune.length &&
      tune.entries.every((e) => other.tune[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
      method,
      school,
      highLatitude,
      hijriMethod,
      hijriAdjustment,
      Object.hashAllUnordered(
          tune.entries.map((e) => Object.hash(e.key, e.value))));
}

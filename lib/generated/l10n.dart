// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message(
      'Dark Mode',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Pick Your Location`
  String get pick_location {
    return Intl.message(
      'Pick Your Location',
      name: 'pick_location',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message(
      'Country',
      name: 'country',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get state {
    return Intl.message(
      'State',
      name: 'state',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `Pick Your Country`
  String get pick_country {
    return Intl.message(
      'Pick Your Country',
      name: 'pick_country',
      desc: '',
      args: [],
    );
  }

  /// `Pick Your State`
  String get pick_state {
    return Intl.message(
      'Pick Your State',
      name: 'pick_state',
      desc: '',
      args: [],
    );
  }

  /// `Pick Your City`
  String get pick_city {
    return Intl.message(
      'Pick Your City',
      name: 'pick_city',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Please add your location`
  String get add_location {
    return Intl.message(
      'Please add your location',
      name: 'add_location',
      desc: '',
      args: [],
    );
  }

  /// `Fajr`
  String get fajr {
    return Intl.message(
      'Fajr',
      name: 'fajr',
      desc: '',
      args: [],
    );
  }

  /// `Dhuhr`
  String get dhuhr {
    return Intl.message(
      'Dhuhr',
      name: 'dhuhr',
      desc: '',
      args: [],
    );
  }

  /// `Asr`
  String get asr {
    return Intl.message(
      'Asr',
      name: 'asr',
      desc: '',
      args: [],
    );
  }

  /// `Maghrib`
  String get maghrib {
    return Intl.message(
      'Maghrib',
      name: 'maghrib',
      desc: '',
      args: [],
    );
  }

  /// `Isha`
  String get isha {
    return Intl.message(
      'Isha',
      name: 'isha',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Location`
  String get enter_location {
    return Intl.message(
      'Enter Your Location',
      name: 'enter_location',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get no_internet {
    return Intl.message(
      'No Internet Connection',
      name: 'no_internet',
      desc: '',
      args: [],
    );
  }

  /// `Sunrise`
  String get sun_rise {
    return Intl.message(
      'Sunrise',
      name: 'sun_rise',
      desc: '',
      args: [],
    );
  }

  /// `This might take a moment`
  String get wait_please {
    return Intl.message(
      'This might take a moment',
      name: 'wait_please',
      desc: '',
      args: [],
    );
  }

  /// `The days of the year are over`
  String get year_ended {
    return Intl.message(
      'The days of the year are over',
      name: 'year_ended',
      desc: '',
      args: [],
    );
  }

  /// `Adhan el Fajr`
  String get adhan_fajr {
    return Intl.message(
      'Adhan el Fajr',
      name: 'adhan_fajr',
      desc: '',
      args: [],
    );
  }

  /// `It's Chourouk Time `
  String get adhan_chourouk {
    return Intl.message(
      'It\'s Chourouk Time ',
      name: 'adhan_chourouk',
      desc: '',
      args: [],
    );
  }

  /// `Adhan el Dhuhr`
  String get adhan_dhuhr {
    return Intl.message(
      'Adhan el Dhuhr',
      name: 'adhan_dhuhr',
      desc: '',
      args: [],
    );
  }

  /// `Adhan el Asr`
  String get adhan_asr {
    return Intl.message(
      'Adhan el Asr',
      name: 'adhan_asr',
      desc: '',
      args: [],
    );
  }

  /// `Adhan el Maghrib`
  String get adhan_maghrib {
    return Intl.message(
      'Adhan el Maghrib',
      name: 'adhan_maghrib',
      desc: '',
      args: [],
    );
  }

  /// `Adhan el Isha`
  String get adhan_isha {
    return Intl.message(
      'Adhan el Isha',
      name: 'adhan_isha',
      desc: '',
      args: [],
    );
  }

  /// `Time to go to the Masjid`
  String get masjid_time {
    return Intl.message(
      'Time to go to the Masjid',
      name: 'masjid_time',
      desc: '',
      args: [],
    );
  }

  /// `Sun is Rising`
  String get sun_rising {
    return Intl.message(
      'Sun is Rising',
      name: 'sun_rising',
      desc: '',
      args: [],
    );
  }

  /// `it's`
  String get its {
    return Intl.message(
      'it\'s',
      name: 'its',
      desc: '',
      args: [],
    );
  }

  /// `Noor`
  String get noor {
    return Intl.message(
      'Noor',
      name: 'noor',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Open Adhkar`
  String get open_adhkar {
    return Intl.message(
      'Open Adhkar',
      name: 'open_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Pick Adhan`
  String get pick_adhan {
    return Intl.message(
      'Pick Adhan',
      name: 'pick_adhan',
      desc: '',
      args: [],
    );
  }

  /// `Adhan Sheikh Ahmad Alnafees`
  String get chikh_nafees {
    return Intl.message(
      'Adhan Sheikh Ahmad Alnafees',
      name: 'chikh_nafees',
      desc: '',
      args: [],
    );
  }

  /// `Adhan Sheikh Alafasy 1`
  String get chikh_afassy_1 {
    return Intl.message(
      'Adhan Sheikh Alafasy 1',
      name: 'chikh_afassy_1',
      desc: '',
      args: [],
    );
  }

  /// `Adhan Sheikh Alafasy 2`
  String get chilh_afassy_2 {
    return Intl.message(
      'Adhan Sheikh Alafasy 2',
      name: 'chilh_afassy_2',
      desc: '',
      args: [],
    );
  }

  /// `Adhan Sheikh Ahmed Elkourdi`
  String get chikh_elkourdi {
    return Intl.message(
      'Adhan Sheikh Ahmed Elkourdi',
      name: 'chikh_elkourdi',
      desc: '',
      args: [],
    );
  }

  /// `Adhan Sheikh Hamza Elmajali`
  String get chikh_elmajali {
    return Intl.message(
      'Adhan Sheikh Hamza Elmajali',
      name: 'chikh_elmajali',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `El Qiblah`
  String get qiblah {
    return Intl.message(
      'El Qiblah',
      name: 'qiblah',
      desc: '',
      args: [],
    );
  }

  /// `Please Enable The GPS Signal`
  String get enable_location {
    return Intl.message(
      'Please Enable The GPS Signal',
      name: 'enable_location',
      desc: '',
      args: [],
    );
  }

  /// `Please Enable Location Permission`
  String get enable_location_permission {
    return Intl.message(
      'Please Enable Location Permission',
      name: 'enable_location_permission',
      desc: '',
      args: [],
    );
  }

  /// `The Qiblah is at`
  String get qiblah_is_at {
    return Intl.message(
      'The Qiblah is at',
      name: 'qiblah_is_at',
      desc: '',
      args: [],
    );
  }

  /// `Your Device Does Not Support The Sensor`
  String get sensor_not_supported {
    return Intl.message(
      'Your Device Does Not Support The Sensor',
      name: 'sensor_not_supported',
      desc: '',
      args: [],
    );
  }

  /// `Manually`
  String get manually {
    return Intl.message(
      'Manually',
      name: 'manually',
      desc: '',
      args: [],
    );
  }

  /// `GPS`
  String get gps {
    return Intl.message(
      'GPS',
      name: 'gps',
      desc: '',
      args: [],
    );
  }

  /// `Hold Your Phone Flat`
  String get flat_phone_title {
    return Intl.message(
      'Hold Your Phone Flat',
      name: 'flat_phone_title',
      desc: '',
      args: [],
    );
  }

  /// `For the most accurate reading, hold your phone flat in your hand, parallel to the ground. Tilting the phone can affect the compass reading.`
  String get flat_phone_body {
    return Intl.message(
      'For the most accurate reading, hold your phone flat in your hand, parallel to the ground. Tilting the phone can affect the compass reading.',
      name: 'flat_phone_body',
      desc: '',
      args: [],
    );
  }

  /// `Keep Away from Magnetic Interference`
  String get keep_from_magnetic_title {
    return Intl.message(
      'Keep Away from Magnetic Interference',
      name: 'keep_from_magnetic_title',
      desc: '',
      args: [],
    );
  }

  /// `Avoid using your phone's compass near large metal objects, electrical equipment, or magnets, as these can interfere with the accuracy of the compass.`
  String get keep_from_magnetic_body {
    return Intl.message(
      'Avoid using your phone\'s compass near large metal objects, electrical equipment, or magnets, as these can interfere with the accuracy of the compass.',
      name: 'keep_from_magnetic_body',
      desc: '',
      args: [],
    );
  }

  /// `Enable Location Services`
  String get enable_location_title {
    return Intl.message(
      'Enable Location Services',
      name: 'enable_location_title',
      desc: '',
      args: [],
    );
  }

  /// `Make sure your phone's GPS and location services are turned on. This can help improve the accuracy of the compass by providing additional data.`
  String get enable_location_body {
    return Intl.message(
      'Make sure your phone\'s GPS and location services are turned on. This can help improve the accuracy of the compass by providing additional data.',
      name: 'enable_location_body',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get tips {
    return Intl.message(
      'Tips',
      name: 'tips',
      desc: '',
      args: [],
    );
  }

  /// `Continue Reading`
  String get continue_reading {
    return Intl.message(
      'Continue Reading',
      name: 'continue_reading',
      desc: '',
      args: [],
    );
  }

  /// `Last Read`
  String get last_read {
    return Intl.message(
      'Last Read',
      name: 'last_read',
      desc: '',
      args: [],
    );
  }

  /// `Hizb`
  String get hizb {
    return Intl.message(
      'Hizb',
      name: 'hizb',
      desc: '',
      args: [],
    );
  }

  /// `El Adhkar`
  String get adhkar {
    return Intl.message(
      'El Adhkar',
      name: 'adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Surah`
  String get surah {
    return Intl.message(
      'Surah',
      name: 'surah',
      desc: '',
      args: [],
    );
  }

  /// `Morning Adhkar`
  String get morning_adhkar {
    return Intl.message(
      'Morning Adhkar',
      name: 'morning_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Evening Adhkar`
  String get evening_adhkar {
    return Intl.message(
      'Evening Adhkar',
      name: 'evening_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Prayer Adhkar`
  String get prayer_adhkar {
    return Intl.message(
      'Prayer Adhkar',
      name: 'prayer_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Mosque Adhkar`
  String get mosque_adhkar {
    return Intl.message(
      'Mosque Adhkar',
      name: 'mosque_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Waking Up Adhkar`
  String get wake_up_adhkar {
    return Intl.message(
      'Waking Up Adhkar',
      name: 'wake_up_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Sleeping Adhkar`
  String get sleep_adhkar {
    return Intl.message(
      'Sleeping Adhkar',
      name: 'sleep_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `After Prayer Adhkar`
  String get after_prayer_adhkar {
    return Intl.message(
      'After Prayer Adhkar',
      name: 'after_prayer_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Tasbeehs`
  String get tasbeeh {
    return Intl.message(
      'Tasbeehs',
      name: 'tasbeeh',
      desc: '',
      args: [],
    );
  }

  /// `Prophet's Duaa`
  String get prophet_dua {
    return Intl.message(
      'Prophet\'s Duaa',
      name: 'prophet_dua',
      desc: '',
      args: [],
    );
  }

  /// `Quranic Duaa`
  String get quran_dua {
    return Intl.message(
      'Quranic Duaa',
      name: 'quran_dua',
      desc: '',
      args: [],
    );
  }

  /// `Prophets' Duaa`
  String get prophets_dua {
    return Intl.message(
      'Prophets\' Duaa',
      name: 'prophets_dua',
      desc: '',
      args: [],
    );
  }

  /// `General Adhkar`
  String get general_Adhkar {
    return Intl.message(
      'General Adhkar',
      name: 'general_Adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Adhkar for Hearing the Adhan`
  String get adhan_adhkar {
    return Intl.message(
      'Adhkar for Hearing the Adhan',
      name: 'adhan_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Comprehensive Duaa`
  String get comprehensive_duaa {
    return Intl.message(
      'Comprehensive Duaa',
      name: 'comprehensive_duaa',
      desc: '',
      args: [],
    );
  }

  /// `Wudu Adhkar`
  String get wudu_adhkar {
    return Intl.message(
      'Wudu Adhkar',
      name: 'wudu_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Adhkar for Entering and Leaving the House`
  String get home_adhkar {
    return Intl.message(
      'Adhkar for Entering and Leaving the House',
      name: 'home_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Adhkar for Entering and Leaving the Bathroom`
  String get wc_adhkar {
    return Intl.message(
      'Adhkar for Entering and Leaving the Bathroom',
      name: 'wc_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Adhkar for Food, Drink, and Guests`
  String get meal_adhkar {
    return Intl.message(
      'Adhkar for Food, Drink, and Guests',
      name: 'meal_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Hajj and Umrah Adhkar`
  String get hajj_adhkar {
    return Intl.message(
      'Hajj and Umrah Adhkar',
      name: 'hajj_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Repetition`
  String get repetition {
    return Intl.message(
      'Repetition',
      name: 'repetition',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarks`
  String get bookmarks {
    return Intl.message(
      'Bookmarks',
      name: 'bookmarks',
      desc: '',
      args: [],
    );
  }

  /// `Page`
  String get page {
    return Intl.message(
      'Page',
      name: 'page',
      desc: '',
      args: [],
    );
  }

  /// `No Bookmarks`
  String get no_bookmarks {
    return Intl.message(
      'No Bookmarks',
      name: 'no_bookmarks',
      desc: '',
      args: [],
    );
  }

  /// `Stop Adhan`
  String get stop_adhan {
    return Intl.message(
      'Stop Adhan',
      name: 'stop_adhan',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

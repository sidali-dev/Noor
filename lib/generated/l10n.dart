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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Info`
  String get info {
    return Intl.message('Info', name: 'info', desc: '', args: []);
  }

  /// `Bookmark`
  String get bookmark {
    return Intl.message('Bookmark', name: 'bookmark', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message('Dark Mode', name: 'dark_mode', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
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
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `State`
  String get state {
    return Intl.message('State', name: 'state', desc: '', args: []);
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
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
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
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
    return Intl.message('Fajr', name: 'fajr', desc: '', args: []);
  }

  /// `Dhuhr`
  String get dhuhr {
    return Intl.message('Dhuhr', name: 'dhuhr', desc: '', args: []);
  }

  /// `Asr`
  String get asr {
    return Intl.message('Asr', name: 'asr', desc: '', args: []);
  }

  /// `Maghrib`
  String get maghrib {
    return Intl.message('Maghrib', name: 'maghrib', desc: '', args: []);
  }

  /// `Isha`
  String get isha {
    return Intl.message('Isha', name: 'isha', desc: '', args: []);
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
    return Intl.message('Sunrise', name: 'sun_rise', desc: '', args: []);
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

  /// `It's Chourouk Time`
  String get adhan_chourouk {
    return Intl.message(
      'It\'s Chourouk Time',
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
    return Intl.message('Adhan el Asr', name: 'adhan_asr', desc: '', args: []);
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
    return Intl.message('it\'s', name: 'its', desc: '', args: []);
  }

  /// `Noor Imene`
  String get noor {
    return Intl.message('Noor Imene', name: 'noor', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Open Athkar`
  String get open_adhkar {
    return Intl.message('Open Athkar', name: 'open_adhkar', desc: '', args: []);
  }

  /// `Pick Adhan`
  String get pick_adhan {
    return Intl.message('Pick Adhan', name: 'pick_adhan', desc: '', args: []);
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
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `El Qiblah`
  String get qiblah {
    return Intl.message('El Qiblah', name: 'qiblah', desc: '', args: []);
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
    return Intl.message('Manually', name: 'manually', desc: '', args: []);
  }

  /// `GPS`
  String get gps {
    return Intl.message('GPS', name: 'gps', desc: '', args: []);
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
    return Intl.message('Tips', name: 'tips', desc: '', args: []);
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
    return Intl.message('Last Read', name: 'last_read', desc: '', args: []);
  }

  /// `Hizb`
  String get hizb {
    return Intl.message('Hizb', name: 'hizb', desc: '', args: []);
  }

  /// `Athkar`
  String get adhkar {
    return Intl.message('Athkar', name: 'adhkar', desc: '', args: []);
  }

  /// `Surah`
  String get surah {
    return Intl.message('Surah', name: 'surah', desc: '', args: []);
  }

  /// `Morning Athkar`
  String get morning_adhkar {
    return Intl.message(
      'Morning Athkar',
      name: 'morning_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Evening Athkar`
  String get evening_adhkar {
    return Intl.message(
      'Evening Athkar',
      name: 'evening_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Prayer Athkar`
  String get prayer_adhkar {
    return Intl.message(
      'Prayer Athkar',
      name: 'prayer_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Mosque Athkar`
  String get mosque_adhkar {
    return Intl.message(
      'Mosque Athkar',
      name: 'mosque_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Waking Up Athkar`
  String get wake_up_adhkar {
    return Intl.message(
      'Waking Up Athkar',
      name: 'wake_up_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Sleeping Athkar`
  String get sleep_adhkar {
    return Intl.message(
      'Sleeping Athkar',
      name: 'sleep_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `After Prayer Athkar`
  String get after_prayer_adhkar {
    return Intl.message(
      'After Prayer Athkar',
      name: 'after_prayer_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Tasbeehs`
  String get tasbeeh {
    return Intl.message('Tasbeehs', name: 'tasbeeh', desc: '', args: []);
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
    return Intl.message('Quranic Duaa', name: 'quran_dua', desc: '', args: []);
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

  /// `General Athkar`
  String get general_Adhkar {
    return Intl.message(
      'General Athkar',
      name: 'general_Adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Athkar for Hearing the Adhan`
  String get adhan_adhkar {
    return Intl.message(
      'Athkar for Hearing the Adhan',
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

  /// `Wudu Athkar`
  String get wudu_adhkar {
    return Intl.message('Wudu Athkar', name: 'wudu_adhkar', desc: '', args: []);
  }

  /// `Athkar for Entering and Leaving the House`
  String get home_adhkar {
    return Intl.message(
      'Athkar for Entering and Leaving the House',
      name: 'home_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Athkar for Entering and Leaving the Bathroom`
  String get wc_adhkar {
    return Intl.message(
      'Athkar for Entering and Leaving the Bathroom',
      name: 'wc_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Athkar for Food, Drink, and Guests`
  String get meal_adhkar {
    return Intl.message(
      'Athkar for Food, Drink, and Guests',
      name: 'meal_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Hajj and Umrah Athkar`
  String get hajj_adhkar {
    return Intl.message(
      'Hajj and Umrah Athkar',
      name: 'hajj_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Repetition`
  String get repetition {
    return Intl.message('Repetition', name: 'repetition', desc: '', args: []);
  }

  /// `Bookmarks`
  String get bookmarks {
    return Intl.message('Bookmarks', name: 'bookmarks', desc: '', args: []);
  }

  /// `Page`
  String get page {
    return Intl.message('Page', name: 'page', desc: '', args: []);
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
    return Intl.message('Stop Adhan', name: 'stop_adhan', desc: '', args: []);
  }

  /// `set new alarm`
  String get set_new_alarm {
    return Intl.message(
      'set new alarm',
      name: 'set_new_alarm',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get minute_short {
    return Intl.message('min', name: 'minute_short', desc: '', args: []);
  }

  /// `Alarm set for`
  String get alarm_set_for {
    return Intl.message(
      'Alarm set for',
      name: 'alarm_set_for',
      desc: '',
      args: [],
    );
  }

  /// `before adhan`
  String get before_adhan {
    return Intl.message(
      'before adhan',
      name: 'before_adhan',
      desc: '',
      args: [],
    );
  }

  /// `after adhan`
  String get after_adhan {
    return Intl.message('after adhan', name: 'after_adhan', desc: '', args: []);
  }

  /// `Quran`
  String get nav_quran {
    return Intl.message('Quran', name: 'nav_quran', desc: '', args: []);
  }

  /// `Prayers`
  String get nav_prayers {
    return Intl.message('Prayers', name: 'nav_prayers', desc: '', args: []);
  }

  /// `Athkar`
  String get nav_adhkar {
    return Intl.message('Athkar', name: 'nav_adhkar', desc: '', args: []);
  }

  /// `Qibla`
  String get nav_qibla {
    return Intl.message('Qibla', name: 'nav_qibla', desc: '', args: []);
  }

  /// `Peace for the heart, calm for the soul`
  String get adhkar_subtitle {
    return Intl.message(
      'Peace for the heart, calm for the soul',
      name: 'adhkar_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `The Noble Quran`
  String get quran_title {
    return Intl.message(
      'The Noble Quran',
      name: 'quran_title',
      desc: '',
      args: [],
    );
  }

  /// `God's words, a light for your life`
  String get quran_subtitle {
    return Intl.message(
      'God\'s words, a light for your life',
      name: 'quran_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} verses`
  String verse_count(int count) {
    return Intl.message(
      '$count verses',
      name: 'verse_count',
      desc: '',
      args: [count],
    );
  }

  /// `{count} athkar`
  String adhkar_count(int count) {
    return Intl.message(
      '$count athkar',
      name: 'adhkar_count',
      desc: '',
      args: [count],
    );
  }

  /// `Meccan`
  String get meccan {
    return Intl.message('Meccan', name: 'meccan', desc: '', args: []);
  }

  /// `Medinan`
  String get medinan {
    return Intl.message('Medinan', name: 'medinan', desc: '', args: []);
  }

  /// `Qibla direction`
  String get qibla_direction {
    return Intl.message(
      'Qibla direction',
      name: 'qibla_direction',
      desc: '',
      args: [],
    );
  }

  /// `Distance to the Kaaba`
  String get distance_to_kaaba {
    return Intl.message(
      'Distance to the Kaaba',
      name: 'distance_to_kaaba',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next_prayer {
    return Intl.message('Next', name: 'next_prayer', desc: '', args: []);
  }

  /// `{prayer} in {time}`
  String next_prayer_in(String prayer, String time) {
    return Intl.message(
      '$prayer in $time',
      name: 'next_prayer_in',
      desc: '',
      args: [prayer, time],
    );
  }

  /// `{hours}h {minutes}m`
  String duration_hm(int hours, int minutes) {
    return Intl.message(
      '${hours}h ${minutes}m',
      name: 'duration_hm',
      desc: '',
      args: [hours, minutes],
    );
  }

  /// `{minutes}m`
  String duration_m(int minutes) {
    return Intl.message(
      '${minutes}m',
      name: 'duration_m',
      desc: '',
      args: [minutes],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Try again`
  String get try_again {
    return Intl.message('Try again', name: 'try_again', desc: '', args: []);
  }

  /// `Open settings`
  String get open_settings {
    return Intl.message(
      'Open settings',
      name: 'open_settings',
      desc: '',
      args: [],
    );
  }

  /// `Reminders`
  String get reminders {
    return Intl.message('Reminders', name: 'reminders', desc: '', args: []);
  }

  /// `Couldn't find your location`
  String get location_failed {
    return Intl.message(
      'Couldn\'t find your location',
      name: 'location_failed',
      desc: '',
      args: [],
    );
  }

  /// `{prayer} reminder`
  String reminder_title(String prayer) {
    return Intl.message(
      '$prayer reminder',
      name: 'reminder_title',
      desc: '',
      args: [prayer],
    );
  }

  /// `{minutes} min until {prayer}`
  String reminder_before(int minutes, String prayer) {
    return Intl.message(
      '$minutes min until $prayer',
      name: 'reminder_before',
      desc: '',
      args: [minutes, prayer],
    );
  }

  /// `{minutes} min since {prayer}`
  String reminder_after(int minutes, String prayer) {
    return Intl.message(
      '$minutes min since $prayer',
      name: 'reminder_after',
      desc: '',
      args: [minutes, prayer],
    );
  }

  /// `Search athkar`
  String get search_adhkar {
    return Intl.message(
      'Search athkar',
      name: 'search_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Search surah`
  String get search_surah {
    return Intl.message(
      'Search surah',
      name: 'search_surah',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get no_results {
    return Intl.message('No results', name: 'no_results', desc: '', args: []);
  }

  /// `In the athkar`
  String get in_adhkar_text {
    return Intl.message(
      'In the athkar',
      name: 'in_adhkar_text',
      desc: '',
      args: [],
    );
  }

  /// `Reading progress`
  String get reading_progress {
    return Intl.message(
      'Reading progress',
      name: 'reading_progress',
      desc: '',
      args: [],
    );
  }

  /// `{read} of {total} pages`
  String pages_read(int read, int total) {
    return Intl.message(
      '$read of $total pages',
      name: 'pages_read',
      desc: '',
      args: [read, total],
    );
  }

  /// `Reset reading progress`
  String get reset_progress {
    return Intl.message(
      'Reset reading progress',
      name: 'reset_progress',
      desc: '',
      args: [],
    );
  }

  /// `This clears the pages marked as read. Your bookmarks are kept.`
  String get reset_progress_body {
    return Intl.message(
      'This clears the pages marked as read. Your bookmarks are kept.',
      name: 'reset_progress_body',
      desc: '',
      args: [],
    );
  }

  /// `Establish prayer for My remembrance. — Ta-Ha 20:14`
  String get tagline_prayers {
    return Intl.message(
      'Establish prayer for My remembrance. — Ta-Ha 20:14',
      name: 'tagline_prayers',
      desc: '',
      args: [],
    );
  }

  /// `Turn your face toward the Sacred Mosque. — Al-Baqarah 2:144`
  String get tagline_qibla {
    return Intl.message(
      'Turn your face toward the Sacred Mosque. — Al-Baqarah 2:144',
      name: 'tagline_qibla',
      desc: '',
      args: [],
    );
  }

  /// `Indeed, this Quran guides to what is most upright. — Al-Isra 17:9`
  String get tagline_quran {
    return Intl.message(
      'Indeed, this Quran guides to what is most upright. — Al-Isra 17:9',
      name: 'tagline_quran',
      desc: '',
      args: [],
    );
  }

  /// `Surely in the remembrance of Allah do hearts find rest. — Ar-Ra’d 13:28`
  String get tagline_adhkar {
    return Intl.message(
      'Surely in the remembrance of Allah do hearts find rest. — Ar-Ra’d 13:28',
      name: 'tagline_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Location`
  String get location_title {
    return Intl.message(
      'Enter Your Location',
      name: 'location_title',
      desc: '',
      args: [],
    );
  }

  /// `To get accurate prayer times`
  String get location_subtitle {
    return Intl.message(
      'To get accurate prayer times',
      name: 'location_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Use your current location`
  String get gps_subtitle {
    return Intl.message(
      'Use your current location',
      name: 'gps_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Pick your city / wilaya`
  String get manual_subtitle {
    return Intl.message(
      'Pick your city / wilaya',
      name: 'manual_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Location`
  String get confirm_location {
    return Intl.message(
      'Confirm Location',
      name: 'confirm_location',
      desc: '',
      args: [],
    );
  }

  /// `Calibrate`
  String get calibrate {
    return Intl.message('Calibrate', name: 'calibrate', desc: '', args: []);
  }

  /// `Calibrate the compass`
  String get calibrate_title {
    return Intl.message(
      'Calibrate the compass',
      name: 'calibrate_title',
      desc: '',
      args: [],
    );
  }

  /// `Move your phone in a slow figure-8 a few times.`
  String get calibrate_step_1 {
    return Intl.message(
      'Move your phone in a slow figure-8 a few times.',
      name: 'calibrate_step_1',
      desc: '',
      args: [],
    );
  }

  /// `Keep away from metal, magnets and speakers.`
  String get calibrate_step_2 {
    return Intl.message(
      'Keep away from metal, magnets and speakers.',
      name: 'calibrate_step_2',
      desc: '',
      args: [],
    );
  }

  /// `Hold the phone flat, then check the arrow again.`
  String get calibrate_step_3 {
    return Intl.message(
      'Hold the phone flat, then check the arrow again.',
      name: 'calibrate_step_3',
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

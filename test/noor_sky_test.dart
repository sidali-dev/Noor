import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/features/adhan/models/sub_models/timings.dart';
import 'package:noor/core/widgets/noor_sky.dart';
import 'package:noor/core/services/app_prefs.dart';
import 'package:noor/core/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Timings _timings({String fajr = '06:10 (CET)', String isha = '19:40 (CET)'}) =>
    Timings(
      fajr: fajr,
      sunrise: '07:40 (CET)',
      dhuhr: '12:45 (CET)',
      asr: '15:20 (CET)',
      sunset: '17:50 (CET)',
      maghrib: '17:50 (CET)',
      isha: isha,
      imsak: '06:00 (CET)',
      midnight: '00:15 (CET)',
      firstthird: '22:00 (CET)',
      lastthird: '02:30 (CET)',
    );

DateTime _at(int hour, int minute) => DateTime(2026, 11, 4, hour, minute);

void main() {
  test('the nearest prayer wins, by the real times', () {
    expect(skyFor(_at(14, 0), _timings()), NoorSky.dhuhr); // 75 vs 80
    expect(skyFor(_at(14, 5), _timings()), NoorSky.asr); // 80 vs 75
    expect(skyFor(_at(18, 40), _timings()), NoorSky.maghrib); // 50 vs 60
    expect(skyFor(_at(18, 50), _timings()), NoorSky.isha); // 60 vs 50
  });

  test('the distance wraps across midnight', () {
    // At 00:10 fajr (00:40) is 30 min ahead, isha (23:30) 40 min back across
    // midnight.
    final t = _timings(fajr: '00:40 (CET)', isha: '23:30 (CET)');
    expect(skyFor(_at(0, 10), t), NoorSky.fajr);
    expect(skyFor(_at(23, 50), t), NoorSky.isha); // 20 vs 50
    expect(skyFor(_at(0, 10), _timings(fajr: '04:30 (CET)', isha: '23:30 (CET)')),
        NoorSky.isha); // 40 back across midnight vs 260
  });

  test('without timings the nominal times stand in', () {
    expect(skyFor(_at(5, 0), null), NoorSky.fajr);
    expect(skyFor(_at(12, 30), null), NoorSky.dhuhr);
    expect(skyFor(_at(15, 30), null), NoorSky.asr);
    expect(skyFor(_at(18, 30), null), NoorSky.maghrib);
    expect(skyFor(_at(20, 0), null), NoorSky.isha);
    expect(skyFor(_at(0, 29), null), NoorSky.isha); // 269 vs 271
    expect(skyFor(_at(0, 31), null), NoorSky.fajr); // 271 vs 269
  });

  test('a time that does not parse falls back to its nominal', () {
    // The bad fajr counts as 05:00, so 05:10 is still fajr, not isha at 19:40.
    expect(skyFor(_at(5, 10), _timings(fajr: 'n/a')), NoorSky.fajr);
  });

  // Keep the only read of noorSkyNow in this file here: it picks once, on first read.
  test('noorSkyNow reads the calendar the controller saves', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await SharedPrefService.init();

    final now = DateTime.now();
    // A sky the nominal times would not choose now, so only the saved times can pick it.
    final want = NoorSky.values[(skyFor(now, null).index + 1) % NoorSky.values.length];
    String away(NoorSky sky) {
      final t = now.add(Duration(hours: 4 * ((sky.index - want.index) % NoorSky.values.length)));
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} (CET)';
    }

    final day = {
      'timings': {
        'Fajr': away(NoorSky.fajr),
        'Sunrise': '07:40 (CET)',
        'Dhuhr': away(NoorSky.dhuhr),
        'Asr': away(NoorSky.asr),
        'Sunset': '17:50 (CET)',
        'Maghrib': away(NoorSky.maghrib),
        'Isha': away(NoorSky.isha),
        'Imsak': '06:00 (CET)',
        'Midnight': '00:15 (CET)',
        'Firstthird': '22:00 (CET)',
        'Lastthird': '02:30 (CET)',
      },
      'date': {
        'readable': '1 Nov 2026',
        'timestamp': '1000',
        'gregorian': {
          'date': '1',
          'weekday': {'en': 'Monday'},
        },
        'hijri': {
          'date': '1',
          'weekday': {'en': 'Al Ithnin', 'ar': 'x'},
        },
      },
    };
    // Encoded the way AdhanController saves it.
    await AppPrefs.setPrayerYearJson(
        now.year,
        jsonEncode(PrayerTime.fromJson({
          'code': 200,
          'status': 'OK',
          'data': {'${now.month}': List.filled(now.day, day)},
        })));

    expect(noorSkyNow.value, want);
  });
}

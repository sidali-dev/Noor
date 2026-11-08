import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/adhan/models/datum.dart';
import 'package:noor/features/adhan/models/islamic_occasion.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_settings.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:noor/core/services/api/prayer_api.dart';
import 'package:noor/features/duaa/models/asma_al_husna.dart';

Datum _day(String hijri) => Datum.fromJson({
      'timings': {
        'Fajr': '05:00',
        'Sunrise': '06:30',
        'Dhuhr': '12:30',
        'Asr': '16:00',
        'Sunset': '18:50',
        'Maghrib': '19:00',
        'Isha': '20:30',
        'Imsak': '04:50',
        'Midnight': '00:00',
        'Firstthird': '22:00',
        'Lastthird': '02:00',
      },
      'date': {
        'readable': '1 Jan 2027',
        'timestamp': '1700000000',
        'gregorian': {
          'date': '01-01-2027',
          'weekday': {'en': 'Friday'},
        },
        'hijri': {
          'date': hijri,
          'weekday': {'en': 'Al Juma', 'ar': 'الجمعة'},
        },
      },
    });

void main() {
  group('times', () {
    test('an ISO time is the same instant in any phone time zone', () {
      final t = AdhanScheduler.parseTiming(
          DateTime(2026, 3, 1), '2026-03-01T05:53:00+01:00')!;
      expect(t.toUtc(), DateTime.utc(2026, 3, 1, 4, 53));
    });

    test('a plain "HH:mm (TZ)" time falls on the given day', () {
      expect(AdhanScheduler.parseTiming(DateTime(2026, 3, 1), '05:53 (CET)'),
          DateTime(2026, 3, 1, 5, 53));
      expect(AdhanScheduler.parseTiming(DateTime(2026, 3, 1), 'nope'), isNull);
    });

    test('clockOf shows the place\'s own wall clock', () {
      expect(AdhanScheduler.clockOf('2026-03-01T05:53:00+01:00'), '05:53');
      expect(AdhanScheduler.clockOf('05:53 (CET)'), '05:53');
    });
  });

  group('PrayerSettings', () {
    test('the defaults send nothing, so untouched users keep their times', () {
      expect(const PrayerSettings().query(), isEmpty);
      expect(const PrayerSettings().isDefault, isTrue);
    });

    test('tune follows the API order, Imsak with Fajr', () {
      final s = const PrayerSettings()
          .withTune(Prayer.fajr, 2)
          .withTune(Prayer.isha, -3)
          .withTune(Prayer.maghrib, 1);
      expect(s.query()['tune'], '2,2,0,0,0,1,0,-3,0');
    });

    test('a zero minute adjustment is dropped', () {
      final s = const PrayerSettings()
          .withTune(Prayer.asr, 5)
          .withTune(Prayer.asr, 0);
      expect(s.tune, isEmpty);
      expect(s, const PrayerSettings());
    });

    test('Hijri adjustment is sent only with the mathematical method', () {
      const uaq = PrayerSettings(hijriMethod: 'UAQ', hijriAdjustment: 1);
      expect(uaq.query(), {'calendarMethod': 'UAQ'});
      const math = PrayerSettings(
          hijriMethod: adjustableHijriMethod, hijriAdjustment: -1);
      expect(math.query(),
          {'calendarMethod': adjustableHijriMethod, 'adjustment': '-1'});
    });

    test('method, school and high latitude', () {
      const s = PrayerSettings(method: 3, school: 1, highLatitude: 2);
      expect(s.query(), {
        'method': '3',
        'school': '1',
        'latitudeAdjustmentMethod': '2',
      });
    });

    test('JSON round trip', () {
      final s = const PrayerSettings(
        method: 19,
        school: 1,
        highLatitude: 3,
        hijriMethod: adjustableHijriMethod,
        hijriAdjustment: 2,
      ).withTune(Prayer.dhuhr, 4);
      final back = PrayerSettings.fromJson(s.toJson());
      expect(back, s);
      expect(back.hashCode, s.hashCode);
    });

    test('every method id is unique and 99 (custom) is left out', () {
      final ids = calculationMethods.map((m) => m.value).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, isNot(contains(99)));
    });
  });

  group('PrayerApi', () {
    test('by coordinates when GPS gave them, ISO times always', () {
      final uri = PrayerApi.calendarUri(2027,
          country: 'Algeria',
          city: 'Algiers',
          coordinates: (latitude: 36.753768, longitude: 3.0587561),
          settings: const PrayerSettings(method: 19));
      expect(uri.path, '/v1/calendar/2027');
      expect(uri.queryParameters, {
        'latitude': '36.7538',
        'longitude': '3.0588',
        'method': '19',
        'iso8601': 'true',
      });
    });

    test('by city otherwise', () {
      final uri = PrayerApi.calendarUri(2027,
          country: 'Algeria',
          city: 'Algiers',
          settings: const PrayerSettings());
      expect(uri.path, '/v1/calendarByCity/2027');
      expect(uri.queryParameters['city'], 'Algiers');
      expect(uri.queryParameters['country'], 'Algeria');
    });

    test('the source is the same across years and changes with settings', () {
      Uri at(int year, PrayerSettings s) => PrayerApi.calendarUri(year,
          country: 'Algeria', city: 'Algiers', settings: s);
      const a = PrayerSettings();
      const b = PrayerSettings(school: 1);
      expect(PrayerApi.sourceOf(at(2026, a)), PrayerApi.sourceOf(at(2027, a)));
      expect(PrayerApi.sourceOf(at(2026, a)),
          isNot(PrayerApi.sourceOf(at(2026, b))));
    });
  });

  group('IslamicOccasion', () {
    test('reads the API Hijri date', () {
      expect(IslamicOccasion.onHijri('10-12-1448'), IslamicOccasion.eidAdha);
      expect(IslamicOccasion.onHijri('01-10-1448'), IslamicOccasion.eidFitr);
      expect(IslamicOccasion.onHijri('02-10-1448'), isNull);
      expect(IslamicOccasion.onHijri('garbage'), isNull);
    });

    test('next counts days to the first occasion ahead', () {
      final from = DateTime(2027, 1, 1);
      // 1 Ramadan falls five days after [from].
      Datum? datumFor(DateTime d) {
        final offset = d.difference(from).inDays;
        return _day(
            offset < 5 ? '${24 + offset}-08-1448' : '0${offset - 4}-09-1448');
      }

      final next = IslamicOccasion.next(from, datumFor)!;
      expect(next.occasion, IslamicOccasion.ramadan);
      expect(next.days, 5);
    });

    test('stops at the end of the cached calendars', () {
      final from = DateTime(2027, 1, 1);
      final next = IslamicOccasion.next(
        from,
        (d) => d.difference(from).inDays <= 3 ? _day('02-02-1448') : null,
      );
      expect(next, isNull);
    });
  });

  group('AsmaAlHusna', () {
    Map<String, dynamic> name(int n) => {
          'name': 'اسم $n',
          'transliteration': 'Name $n',
          'number': n,
          'en': {'meaning': 'Meaning $n'},
        };

    test('parses all 99, in order', () {
      final names = AsmaAlHusna.parse([for (var i = 99; i >= 1; i--) name(i)]);
      expect(names.length, 99);
      expect(names.first.number, 1);
      expect(names.first.meaning, 'Meaning 1');
      expect(names.last.transliteration, 'Name 99');
    });

    test('an incomplete reply is refused rather than cached', () {
      expect(() => AsmaAlHusna.parse([name(1)]), throwsA(anything));
    });
  });
}

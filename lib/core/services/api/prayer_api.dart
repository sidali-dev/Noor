import 'package:noor/features/adhan/models/prayer_settings.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/core/services/http_service.dart';
import 'package:noor/core/services/app_prefs.dart';

typedef Coordinates = ({double latitude, double longitude});

/// The AlAdhan prayer calendar for a year, for a place and [PrayerSettings].
class PrayerApi {
  PrayerApi._();

  /// By coordinates when GPS gave them, which skips the API's geocoding of a
  /// city name; by city otherwise. Times come as ISO 8601 with their offset,
  /// so they mean the same instant whatever the phone's time zone.
  static Uri calendarUri(
    int year, {
    required String country,
    required String city,
    Coordinates? coordinates,
    required PrayerSettings settings,
  }) {
    final byCoordinates = coordinates != null;
    return Uri.https(
      'api.aladhan.com',
      byCoordinates ? '/v1/calendar/$year' : '/v1/calendarByCity/$year',
      {
        if (byCoordinates) ...{
          // About 10 m: as precise as prayer times can use.
          'latitude': coordinates.latitude.toStringAsFixed(4),
          'longitude': coordinates.longitude.toStringAsFixed(4),
        } else ...{
          'city': city,
          'country': country,
        },
        ...settings.query(),
        'iso8601': 'true',
      },
    );
  }

  /// [uri] without its year: the same for every year of one place and one
  /// set of settings.
  static String sourceOf(Uri uri) =>
      '${uri.path.replaceFirst(RegExp(r'/\d+$'), '')}?${uri.query}';

  /// What a calendar fetched now for the saved place and settings would
  /// carry as its [PrayerTime.source].
  static String currentSource() => sourceOf(calendarUri(
        0,
        country: AppPrefs.country,
        city: AppPrefs.city,
        coordinates: AppPrefs.coordinates,
        settings: AppPrefs.prayerSettings,
      ));

  /// Anything left out is read from the saved location and settings.
  static Future<PrayerTime> fetchYear(
    int year, {
    String? country,
    String? city,
    Coordinates? coordinates,
    bool useSavedCoordinates = true,
    PrayerSettings? settings,
  }) async {
    final uri = calendarUri(
      year,
      country: country ?? AppPrefs.country,
      city: city ?? AppPrefs.city,
      coordinates:
          coordinates ?? (useSavedCoordinates ? AppPrefs.coordinates : null),
      settings: settings ?? AppPrefs.prayerSettings,
    );
    final pt = PrayerTime.fromJson(await HttpService.getJson(uri));
    pt.source = sourceOf(uri);
    return pt;
  }
}

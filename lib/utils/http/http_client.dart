import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class NoInternetException implements Exception {
  final String message;
  const NoInternetException([this.message = 'No internet connection']);

  @override
  String toString() => 'NoInternetException: $message';
}

class PrayerApiException implements Exception {
  final int statusCode;
  final String? message;

  const PrayerApiException(this.statusCode, [this.message]);

  @override
  String toString() =>
      'PrayerApiException(statusCode: $statusCode, message: $message)';
}

class SHttpHelper {
  static const Duration _timeout = Duration(seconds: 15);

  /// Helper method to make a GET request to the AlAdhan calendarByCity API.
  /// Callers must pass raw (unencoded) strings for [country] and [city].
  static Future<Map<String, dynamic>> get(
      String country, String city, String year) async {
    final uri = Uri.https('api.aladhan.com', '/v1/calendarByCity/$year', {
      'city': city,
      'country': country,
    });

    http.Response response;
    try {
      response = await http.get(uri).timeout(_timeout);
    } on SocketException catch (e) {
      throw NoInternetException(e.message);
    } on TimeoutException catch (e) {
      throw NoInternetException(e.message ?? 'Request timed out');
    } on http.ClientException catch (e) {
      throw NoInternetException(e.message);
    }

    if (response.statusCode != 200) {
      throw PrayerApiException(response.statusCode);
    }

    final dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
      throw PrayerApiException(response.statusCode, 'Invalid JSON');
    }

    if (body is! Map<String, dynamic>) {
      throw PrayerApiException(response.statusCode, 'Malformed response');
    }

    if (body['code'] != 200) {
      final code =
          body['code'] is int ? body['code'] as int : response.statusCode;
      throw PrayerApiException(code, body['status']?.toString());
    }

    return body;
  }
}

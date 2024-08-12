import 'dart:convert';
import 'package:http/http.dart' as http;

class SHttpHelper {
  static const String _baseUrl = 'https://api.aladhan.com/v1/calendarByCity';

  // Helper method to make a GET request
  static Future<Map<String, dynamic>> get(
      String country, String city, String year) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/$year?city=$city&country=$country'));
    return _handleResponse(response);
  }

  // Handle the HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'check http_client,\nFailed to load data: ${response.statusCode}');
    }
  }
}

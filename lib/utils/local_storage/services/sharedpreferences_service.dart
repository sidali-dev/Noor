import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static SharedPreferences? _prefs;
  SharedPrefService._();

  static final SharedPrefService instance = SharedPrefService._();

  static Future<SharedPreferences> init() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // Getters for various data types
  static String? getString(String key) {
    return _prefs!.getString(key);
  }

  static int? getInt(String key) {
    return _prefs!.getInt(key);
  }

  static bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  static double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }

  // Setters for various data types
  static Future<bool> setString(String key, String value) async {
    return _prefs!.setString(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    return _prefs!.setInt(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    return _prefs!.setBool(key, value);
  }

  static Future<bool> setDouble(String key, double value) async {
    return _prefs!.setDouble(key, value);
  }

  // Additional methods (optional)
  static Future<bool> remove(String key) async {
    return _prefs!.remove(key);
  }

  static Future<bool> clear() async {
    return _prefs!.clear();
  }
}

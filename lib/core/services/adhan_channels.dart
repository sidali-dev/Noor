import 'package:flutter/services.dart';

/// `noor/adhan`: the adhan screen's own Android activity (AdhanActivity).
abstract final class AdhanChannel {
  static const _channel = MethodChannel('noor/adhan');

  /// The alarm the activity was opened for: `id`, and the notification's
  /// `title` and `body`, which may be null.
  static Future<Map<Object?, Object?>> alarm() async =>
      await _channel.invokeMethod<Map<Object?, Object?>>('alarm') ?? const {};

  /// Called with a newer alarm while the screen is up.
  static void onAlarm(void Function(Map<Object?, Object?> alarm) handler) =>
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'alarm') {
          handler(call.arguments as Map<Object?, Object?>? ?? const {});
        }
      });

  /// Stops the adhan and closes its screen.
  static Future<void> stop() => _channel.invokeMethod('stop');

  /// Stops the adhan and opens the app on its Athkar tab.
  static Future<void> openAthkar() => _channel.invokeMethod('openAthkar');
}

/// `noor/app`: the app's own activity (MainActivity). Android only; elsewhere
/// every call answers as if there were nothing to do.
abstract final class AppChannel {
  static const _channel = MethodChannel('noor/app');

  /// The tab the app was opened on (the adhan screen's Open Athkar), once.
  static Future<int?> launchTab() async {
    try {
      return await _channel.invokeMethod<int>('launchTab');
    } on MissingPluginException {
      return null;
    }
  }

  /// Called when the running app is asked to show a tab.
  static void onOpenTab(void Function(int tab) handler) =>
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'openTab') handler(call.arguments as int);
      });

  /// Whether a ringing adhan may take the screen (Android 14 asks the user).
  static Future<bool> canUseFullScreenIntent() async {
    try {
      return await _channel.invokeMethod<bool>('canUseFullScreenIntent') ??
          true;
    } on MissingPluginException {
      return true;
    }
  }

  static Future<void> openFullScreenIntentSettings() =>
      _channel.invokeMethod('openFullScreenIntentSettings');
}

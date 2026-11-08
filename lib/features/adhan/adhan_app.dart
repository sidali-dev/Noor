import 'dart:convert';

import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/service/alarm_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:noor/features/adhan/adhan_ring_screen.dart';
import 'package:noor/features/adhan/models/adhan_ring.dart';
import 'package:noor/features/adhan/services/adhan_channels.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What `adhanMain` runs in Android's AdhanActivity: the ring screen alone, in
/// the saved theme and language. Its engine has shared_preferences and nothing
/// else, so it reads the alarm the plugin saved rather than asking the plugin.
class AdhanApp extends StatefulWidget {
  const AdhanApp({super.key});

  @override
  State<AdhanApp> createState() => _AdhanAppState();
}

class _AdhanAppState extends State<AdhanApp> {
  AdhanRing? _ring;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    AdhanChannel.onAlarm(_show);
    AdhanChannel.alarm().then(_show);
    // Over the lock screen the surface can come back from screen-off empty
    // until something changes: draw again on the way back.
    _lifecycle = AppLifecycleListener(
      onResume: () => WidgetsBinding.instance.scheduleForcedFrame(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _show(Map<Object?, Object?> alarm) async {
    final ring = await loadAdhanRing(alarm);
    if (mounted) setState(() => _ring = ring);
  }

  @override
  Widget build(BuildContext context) {
    final ring = _ring;
    return MaterialApp(
      title: 'Faith',
      debugShowCheckedModeBanner: false,
      theme: AppPrefs.isDark ? NoorTheme.dark() : NoorTheme.light(),
      locale: Locale(AppPrefs.languageCode),
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ring == null
          ? const _Ground()
          : AdhanRingScreen(
              key: ValueKey(ring.id),
              ring: ring,
              onStop: AdhanChannel.stop,
              onOpenAthkar: AdhanChannel.openAthkar,
            ),
    );
  }
}

/// The page, for the moment before the alarm is read.
class _Ground extends StatelessWidget {
  const _Ground();

  @override
  Widget build(BuildContext context) => ColoredBox(color: context.noor.paper);
}

/// The ring for [alarm] (`id`, `title`) from the activity: its saved settings
/// if the plugin still has them; with no id, the latest alarm due.
Future<AdhanRing> loadAdhanRing(Map<Object?, Object?> alarm) async {
  final prefs = await SharedPreferences.getInstance();
  // The main app's engine may have saved it after this one read the file.
  await prefs.reload();
  final id = alarm['id'] as int? ?? 0;
  final saved = [
    for (final key in prefs.getKeys())
      if (key.startsWith(AlarmStorage.prefix)) _decode(prefs.getString(key)),
  ].nonNulls;
  final now = DateTime.now();
  final settings = saved.where((a) => a.id == id).firstOrNull ??
      (id != 0
          ? null
          : (saved.where((a) => !a.dateTime.isAfter(now)).toList()
                ..sort((a, b) => b.dateTime.compareTo(a.dateTime)))
              .firstOrNull);
  return AdhanRing.of(
    id: settings?.id ?? id,
    alarmTime: settings?.dateTime ?? now,
    title: settings?.notificationSettings.title ??
        alarm['title'] as String? ??
        '',
  );
}

AlarmSettings? _decode(String? json) {
  if (json == null) return null;
  try {
    return AlarmSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

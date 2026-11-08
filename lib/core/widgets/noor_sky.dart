import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_time.dart';
import 'package:noor/features/adhan/models/sub_models/timings.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:noor/core/services/app_prefs.dart';

/// The hero's sky, one per prayer and the same in both themes, seen through the
/// tab's window.
enum NoorSky {
  fajr(Prayer.fajr, 5 * 60),
  dhuhr(Prayer.dhuhr, 12 * 60 + 30),
  asr(Prayer.asr, 15 * 60 + 30),
  maghrib(Prayer.maghrib, 18 * 60 + 30),
  isha(Prayer.isha, 20 * 60);

  const NoorSky(this.prayer, this.nominalMinute);

  final Prayer prayer;
  final int nominalMinute;

  String get asset => 'assets/images/art/sky_$name.webp';
}

/// The sky of the prayer nearest to [now], either way round the clock. Without
/// [timings], or for a time that does not parse, the nominal time stands in.
NoorSky skyFor(DateTime now, Timings? timings) {
  final at = now.hour * 60 + now.minute;
  int distance(NoorSky sky) {
    final time = timings == null
        ? null
        : AdhanScheduler.parseTiming(now, sky.prayer.timeFromTimings(timings));
    final d = (at -
            (time == null ? sky.nominalMinute : time.hour * 60 + time.minute))
        .abs();
    return math.min(d, 24 * 60 - d);
  }

  return NoorSky.values.reduce((a, b) => distance(b) < distance(a) ? b : a);
}

/// The sky right now. One value, so every tab draws the same sky: picked on
/// first read and again on app resume, so a phone left open overnight moves on.
final ValueNotifier<NoorSky> noorSkyNow = () {
  final sky = ValueNotifier(_pickSky());
  // Never disposed: it lives as long as the value it refreshes.
  AppLifecycleListener(onResume: () => sky.value = _pickSky());
  return sky;
}();

NoorSky _pickSky() {
  final now = DateTime.now();
  return skyFor(now, _savedTimings(now));
}

// From prefs, not AdhanController: finding it would start it, and its onInit
// asks for the location and may fetch.
// shortcut: decodes the saved year on every resume, keep the day's timings if
// that ever janks.
Timings? _savedTimings(DateTime d) {
  final json = AppPrefs.prayerYearJson(d.year);
  if (json == null || json.isEmpty) return null;
  try {
    return PrayerTime.fromJson(jsonDecode(json))
        .data[d.month.toString()]?[d.day - 1]
        .timings;
  } catch (_) {
    return null;
  }
}

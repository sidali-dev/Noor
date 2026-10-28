import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/generals/location_flow.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Shift, in minutes, at which the saved city's times are worth replacing.
const int driftThresholdMinutes = 5;

const Duration _timeout = Duration(seconds: 8);

// Same order as Prayer.all.
const List<String> _apiKeys = [
  'Fajr',
  'Sunrise',
  'Dhuhr',
  'Asr',
  'Maghrib',
  'Isha',
];

bool _checked = false;

/// Once per launch: if a location is saved, compares today's saved times with
/// the times at the network's (IP) location and, when they differ by
/// [driftThresholdMinutes] or more, offers to relocate. Fails silently.
Future<void> checkLocationDrift(BuildContext context) async {
  if (_checked) return;
  _checked = true;

  final saved = AppPrefs.city;
  if (saved.isEmpty) return;
  final timings = Get.find<AdhanController>().timingsFor(DateTime.now());
  if (timings == null) return;

  final ({String? city, int minutes})? drift;
  try {
    drift = await _detectDrift(
      [for (final p in Prayer.all) p.timeFromTimings(timings)],
    );
  } catch (_) {
    return;
  }

  if (drift == null || drift.minutes < driftThresholdMinutes) return;
  // Not over the ring screen or another sheet.
  if (!context.mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
    return;
  }

  final source = await showNoorSheet<LocationSource>(
    context,
    titleOf: (c) => S.of(c).relocate_title,
    builder: (c) => _DriftPrompt(
      city: drift!.city,
      minutes: drift.minutes,
      saved: saved,
    ),
  );
  if (source == null || !context.mounted) return;
  await pickLocation(context, source: source);
}

/// IP location (ipwho.is, HTTPS; ipapi.co sits behind a bot challenge), then
/// today's times there (aladhan, same default method as the saved calendar).
Future<({String? city, int minutes})?> _detectDrift(List<String> saved) async {
  final ip = await _getJson(Uri.https('ipwho.is', '/'));
  final lat = ip['latitude'], lon = ip['longitude'];
  if (lat is! num || lon is! num) return null;

  final now = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  final day = await _getJson(Uri.https(
    'api.aladhan.com',
    '/v1/timings/${two(now.day)}-${two(now.month)}-${now.year}',
    {'latitude': '$lat', 'longitude': '$lon'},
  ));
  final data = day['data'];
  final t = data is Map ? data['timings'] : null;
  if (t is! Map) return null;

  final minutes = shiftMinutes(saved, [for (final k in _apiKeys) '${t[k]}']);
  if (minutes == null) return null;
  final city = ip['city'];
  return (
    city: city is String && city.trim().isNotEmpty ? city.trim() : null,
    minutes: minutes,
  );
}

Future<Map<String, dynamic>> _getJson(Uri uri) async {
  final res = await http.get(uri).timeout(_timeout);
  if (res.statusCode != 200) throw http.ClientException('${res.statusCode}');
  final body = json.decode(res.body);
  if (body is! Map<String, dynamic>) throw const FormatException();
  return body;
}

/// Largest gap between paired "HH:mm" times (a " (TZ)" suffix is ignored),
/// wrapping at midnight. Pairs that don't parse are skipped; null if none do.
int? shiftMinutes(List<String> a, List<String> b) {
  int? max;
  for (var i = 0; i < math.min(a.length, b.length); i++) {
    final x = _minutes(a[i]), y = _minutes(b[i]);
    if (x == null || y == null) continue;
    final d = (x - y).abs();
    final wrapped = math.min(d, 24 * 60 - d);
    if (max == null || wrapped > max) max = wrapped;
  }
  return max;
}

int? _minutes(String time) {
  final parts = time.trim().split(RegExp(r'\s+')).first.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]), m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}

class _DriftPrompt extends StatelessWidget {
  final String? city;
  final int minutes;
  final String saved;

  const _DriftPrompt({
    required this.city,
    required this.minutes,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final shift = minutes >= 60
        ? s.duration_hm(minutes ~/ 60, minutes % 60)
        : s.duration_m(minutes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          city == null
              ? s.relocate_body_unknown(shift, saved)
              : s.relocate_body(city!, shift, saved),
          style: NoorText.body(context).copyWith(color: context.noor.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NoorSpace.xxl),
        NoorButton(
          label: s.relocate_auto,
          icon: const Icon(Icons.my_location_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(LocationSource.gps),
        ),
        const SizedBox(height: NoorSpace.md),
        NoorButton(
          label: s.relocate_manual,
          icon: const Icon(Icons.edit_location_alt_outlined, size: 20),
          variant: NoorButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(LocationSource.manual),
        ),
      ],
    );
  }
}

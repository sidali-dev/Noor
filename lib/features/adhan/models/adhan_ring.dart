import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';

/// What the ring screen shows for one ringing alarm: whose prayer it is and
/// the prayer's own time, which for a reminder is not the alarm's.
class AdhanRing {
  final int id;

  /// Null for an alarm id that maps to no prayer.
  final Prayer? prayer;

  /// The adhan's time. A reminder rings minutes before or after it.
  final DateTime prayerTime;

  /// The notification title, shown when there is no [prayer].
  final String title;

  const AdhanRing({
    required this.id,
    required this.prayer,
    required this.prayerTime,
    required this.title,
  });

  /// The ring for alarm [id], set for [alarmTime]. A reminder's offset comes
  /// from [reminderMinutes], by default the saved reminders.
  factory AdhanRing.of({
    required int id,
    required DateTime alarmTime,
    String title = '',
    int Function(Prayer prayer, int slot)? reminderMinutes,
  }) {
    final base = AdhanScheduler.baseOf(id);
    for (final prayer in Prayer.all) {
      if (base == prayer.adhanId) {
        return AdhanRing(
            id: id, prayer: prayer, prayerTime: alarmTime, title: title);
      }
      if (base ~/ 100 == prayer.adhanId) {
        final minutes = (reminderMinutes ?? _savedMinutes)(prayer, base % 100);
        return AdhanRing(
          id: id,
          prayer: prayer,
          prayerTime: alarmTime.subtract(Duration(minutes: minutes)),
          title: title,
        );
      }
    }
    return AdhanRing(id: id, prayer: null, prayerTime: alarmTime, title: title);
  }

  static int _savedMinutes(Prayer prayer, int slot) =>
      AdhanScheduler.reminders(prayer)
          .where((r) => r.slot == slot)
          .firstOrNull
          ?.minutes ??
      0;
}

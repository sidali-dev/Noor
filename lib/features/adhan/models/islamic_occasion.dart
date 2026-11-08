import 'package:noor/features/adhan/models/datum.dart';
import 'package:noor/generated/l10n.dart';

/// The major days of the Hijri year, read off the API's Hijri date so they
/// follow the user's calendar method. The API's own `holidays` list is not
/// used: it is mostly anniversaries of Sufi shaykhs, in English only.
enum IslamicOccasion {
  newYear(1, 1),
  ashura(1, 10),
  mawlid(3, 12),
  israMiraj(7, 27),
  midShaban(8, 15),
  ramadan(9, 1),
  laylatAlQadr(9, 27),
  eidFitr(10, 1),
  arafah(12, 9),
  eidAdha(12, 10);

  const IslamicOccasion(this.month, this.day);

  final int month;
  final int day;

  String title(S s) => switch (this) {
        newYear => s.occasion_new_year,
        ashura => s.occasion_ashura,
        mawlid => s.occasion_mawlid,
        israMiraj => s.occasion_isra_miraj,
        midShaban => s.occasion_mid_shaban,
        ramadan => s.occasion_ramadan,
        laylatAlQadr => s.occasion_laylat_al_qadr,
        eidFitr => s.occasion_eid_fitr,
        arafah => s.occasion_arafah,
        eidAdha => s.occasion_eid_adha,
      };

  /// The occasion on an API Hijri date ("DD-MM-YYYY"), if any.
  static IslamicOccasion? onHijri(String hijriDate) {
    final parts = hijriDate.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    for (final o in values) {
      if (o.month == month && o.day == day) return o;
    }
    return null;
  }

  /// The first occasion after [from], within the calendars already cached;
  /// null past their end.
  static ({IslamicOccasion occasion, int days})? next(
    DateTime from,
    Datum? Function(DateTime day) datumFor,
  ) {
    for (var i = 1; i <= 366; i++) {
      final datum = datumFor(DateTime(from.year, from.month, from.day + i));
      if (datum == null) return null;
      final occasion = onHijri(datum.date.hijri.date);
      if (occasion != null) return (occasion: occasion, days: i);
    }
    return null;
  }
}

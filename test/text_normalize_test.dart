import 'package:flutter_test/flutter_test.dart';
import 'package:noor/features/duaa/data/adhkar_search.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/utils/text_normalize.dart';

void main() {
  group('normalizeArabic', () {
    test('strips tashkeel (diacritics), dagger alef and tatweel', () {
      // Dagger alef U+0670 in الرحمن, shaddah and harakat
      const diacritized = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      expect(normalizeArabic(diacritized), 'بسم الله الرحمن الرحيم');

      // Tatweel U+0640
      const tatweel = 'كـــتـــاب';
      expect(normalizeArabic(tatweel), 'كتاب');
    });

    test('unifies alef forms (أ إ آ ٱ -> ا)', () {
      expect(normalizeArabic('أحمد'), 'احمد');
      expect(normalizeArabic('إبراهيم'), 'ابراهيم');
      expect(normalizeArabic('آدم'), 'ادم');
      expect(normalizeArabic('ٱلله'), 'الله');
    });

    test('unifies alif maqsura (ى -> ي)', () {
      expect(normalizeArabic('هدى'), 'هدي');
      expect(normalizeArabic('على'), 'علي');
      expect(normalizeArabic('مستشفى'), 'مستشفي');
    });

    test('unifies taa marbuta (ة -> ه)', () {
      expect(normalizeArabic('صلاة'), 'صلاه');
      expect(normalizeArabic('رحمة'), 'رحمه');
      expect(normalizeArabic('فاطمة'), 'فاطمه');
    });

    test('lowercases and strips common Latin accents', () {
      expect(normalizeArabic('Médine'), 'medine');
      expect(normalizeArabic('Élysée'), 'elysee');
      expect(normalizeArabic('Ça va?'), 'ca va?');
      expect(normalizeArabic('Müller'), 'muller');
      expect(normalizeArabic('CAFÉ'), 'cafe');
      expect(normalizeArabic('Noël'), 'noel');
    });
  });

  group('matchesQuery', () {
    test('matches Arabic text regardless of diacritics and letter variants', () {
      expect(matchesQuery('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'الله'), isTrue);
      expect(matchesQuery('أَسْتَغْفِرُ اللَّهَ', 'استغفر'), isTrue);
      expect(matchesQuery('الصَّلَاةُ خَيْرٌ مِنَ النَّوْمِ', 'صلاه'), isTrue);
      expect(matchesQuery('عَلَى النَّبِيِّ', 'علي'), isTrue);
    });

    test('matches Latin text with accents and case differences', () {
      expect(matchesQuery('Bienvenue à Médine', 'medine'), isTrue);
      expect(matchesQuery('Al-Madinah', 'madinah'), isTrue);
    });

    test('empty or whitespace query matches everything', () {
      expect(matchesQuery('أي نص', ''), isTrue);
      expect(matchesQuery('أي نص', '   '), isTrue);
    });

    test('returns false when no match', () {
      expect(matchesQuery('سبحان الله', 'الحمد'), isFalse);
    });
  });

  group('AdhkarSearch with injected fixture', () {
    final fixtureRows = [
      AdhkarModel(
        id: 1,
        dhikrType: 1,
        dhikrContent: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
        dhikrRepetition: 1,
      ),
      AdhkarModel(
        id: 2,
        dhikrType: 1,
        dhikrContent: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا',
        dhikrRepetition: 1,
      ),
      AdhkarModel(
        id: 3,
        dhikrType: 2,
        dhikrContent: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        dhikrRepetition: 1,
      ),
      AdhkarModel(
        id: 4,
        dhikrType: 2,
        dhikrContent: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ',
        dhikrRepetition: 3,
      ),
    ];

    test('finds diacritised Arabic content by undiacritised query', () async {
      final search = AdhkarSearch.withRows(fixtureRows);
      final hits = await search.search('اصبحنا');

      expect(hits.length, 2);
      expect(hits[0].type, 1);
      expect(hits[0].indexInType, 0);
      expect(hits[0].snippet, contains('أَصْبَحْنَا'));

      expect(hits[1].type, 1);
      expect(hits[1].indexInType, 1);
      expect(hits[1].snippet, contains('أَصْبَحْنَا'));
    });

    test('preserves indexInType per dhikr category', () async {
      final search = AdhkarSearch.withRows(fixtureRows);
      final hits = await search.search('الملك لله');

      expect(hits.length, 2);
      // First hit is in type 1, 0th item of type 1
      expect(hits[0].type, 1);
      expect(hits[0].indexInType, 0);

      // Second hit is in type 2, 0th item of type 2
      expect(hits[1].type, 2);
      expect(hits[1].indexInType, 0);
    });

    test('short queries under minQueryLength return empty list', () async {
      final search = AdhkarSearch.withRows(fixtureRows);
      expect(await search.search(''), isEmpty);
      expect(await search.search(' '), isEmpty);
      expect(await search.search('أ'), isEmpty); // 1 normalized char
    });

    test('limits hits to maxHits (20)', () async {
      final manyRows = List.generate(
        30,
        (i) => AdhkarModel(
          id: i + 1,
          dhikrType: 1,
          dhikrContent: 'ذِكْرٌ مُكَرَّرٌ رَقْم $i سُبْحَانَ اللَّهِ',
          dhikrRepetition: 1,
        ),
      );

      final search = AdhkarSearch.withRows(manyRows);
      final hits = await search.search('سبحان الله');
      expect(hits.length, AdhkarSearch.maxHits);
      expect(hits.length, 20);
    });
  });
}

import 'package:get/get.dart';
import 'package:noor/features/quran/mini%20screens/list_by_hizb.dart';
import 'package:noor/features/quran/mini%20screens/list_by_surah.dart';
import 'package:quran/quran.dart' as quran;

import '../../utils/local_storage/services/sharedpreferences_service.dart';

class QuranScreenController extends GetxController {
  Rx<int> currentIndex = 0.obs;

  final screens = const [ListBySurah(), ListByHizb()];

  Rx<String> lastReadSurah = quran
      .getSurahName(quran
          .getPageData(SharedPrefService.getInt("last_read_quran")!)
          .first["surah"])
      .obs;

  Rx<String> lastReadSurahArabic = quran
      .getSurahNameArabic(quran
          .getPageData(SharedPrefService.getInt("last_read_quran")!)
          .first["surah"])
      .obs;

  Rx<int> lastReadPageNumber = SharedPrefService.getInt("last_read_quran")!.obs;

/////////////////////////////---FUNCTIONS---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

  changeIndex(int index) {
    currentIndex.value = index;
  }

  updateLastSurahRead() {
    lastReadSurah.value = quran.getSurahName(quran
        .getPageData(SharedPrefService.getInt("last_read_quran")!)
        .first["surah"]);

    lastReadSurahArabic.value = quran.getSurahNameArabic(quran
        .getPageData(SharedPrefService.getInt("last_read_quran")!)
        .first["surah"]);
  }

  updateLastPageRead() {
    lastReadPageNumber.value = SharedPrefService.getInt("last_read_quran")!;
  }
}

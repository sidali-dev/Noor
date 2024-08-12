import 'package:get/get.dart';

class AdhkarDisplayController extends GetxController {
  RxInt pageIndex = 1.obs;

  RxInt repetition = 1.obs;

  decrementRepetition() {
    if (repetition >= 1) {
      repetition.value--;
    }
  }

  updateRepetition(int i) {
    repetition.value = i;
  }

  updatePageIndex(int i) {
    pageIndex.value = i + 1;
  }
}

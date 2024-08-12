import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

class SoundPickerController extends GetxController {
  RxBool isPlaying = false.obs;
  RxString adhanSoundName = SHelperFunctions.getAdhanChikhName().obs;
  final player = AudioPlayer();

  playOrPauseSound(String path) async {
    await player.setSource(AssetSource(path.replaceFirst("assets/", "")));

    if (isPlaying.value) {
      await player.resume();
    } else {
      await player.stop();
    }
  }

  updateAdhanName() {
    adhanSoundName.value = SHelperFunctions.getAdhanChikhName();
  }

  playOrPause() {
    isPlaying.value = !isPlaying.value;
  }
}

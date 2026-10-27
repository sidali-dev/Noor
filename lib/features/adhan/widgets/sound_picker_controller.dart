import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';

class SoundPickerController extends GetxController {
  final AudioPlayer player;
  final RxString adhanSoundName = ''.obs;
  final Rx<String?> playingPath = Rx<String?>(null);

  SoundPickerController({AudioPlayer? player})
      : player = player ?? AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    updateAdhanName();
    player.onPlayerComplete.listen((_) {
      playingPath.value = null;
    });
  }

  void updateAdhanName() {
    adhanSoundName.value = AppPrefs.adhanSoundName;
  }

  Future<void> togglePreview(String path) async {
    if (playingPath.value == path) {
      await stopPreview();
    } else {
      await player.stop();
      playingPath.value = path;
      final cleanPath =
          path.startsWith('assets/') ? path.replaceFirst('assets/', '') : path;
      await player.play(AssetSource(cleanPath));
    }
  }

  Future<void> stopPreview() async {
    playingPath.value = null;
    try {
      await player.stop().timeout(const Duration(milliseconds: 300));
    } catch (_) {}
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}

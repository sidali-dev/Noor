import 'package:get/get.dart';
import 'package:noor/core/services/app_prefs.dart';

class LocationService extends GetxService {
  final RxString country = "".obs;
  final RxString state = "".obs;
  final RxString city = "".obs;

  Future<void> insertNewLocation(
      String country, String state, String city) async {
    await AppPrefs.setLocation(country, state, city);
    this.country.value = country;
    this.state.value = state;
    this.city.value = city;
  }

  void getLocation() {
    country.value = AppPrefs.country;
    state.value = AppPrefs.state;
    city.value = AppPrefs.city;
  }
}

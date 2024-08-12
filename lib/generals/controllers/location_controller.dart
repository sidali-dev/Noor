import 'package:get/get.dart';

import '../../utils/local_storage/services/sharedpreferences_service.dart';

class LocationController extends GetxController {
  RxString country = "".obs;
  RxString state = "".obs;
  RxString city = "".obs;

  //upsert the location of the user to shared prefs
  insertNewLocation(String country, String state, String city) async {
    await SharedPrefService.setString("country", country);
    await SharedPrefService.setString("state", state);
    await SharedPrefService.setString("city", city);
  }

  //gets the user location from shared prefs
  getLocation() {
    country.value = SharedPrefService.getString("country")!;
    state.value = SharedPrefService.getString("state")!;
    city.value = SharedPrefService.getString("city")!;
  }
}

import 'dart:async';

import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class QiblaController extends GetxController {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  Stream<LocationStatus> get stream => _locationStreamController.stream;

  @override
  void onInit() async {
    super.onInit();
    await checkLocationStatus();
  }

  @override
  void onClose() async {
    await _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  restartCheckLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    _locationStreamController.sink.add(locationStatus);
  }
}

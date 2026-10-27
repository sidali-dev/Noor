import 'dart:async';

import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class QiblaController extends GetxController {
  final StreamController<LocationStatus> _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  Stream<LocationStatus> get stream => _locationStreamController.stream;

  /// Latest status, so a late listener (the broadcast stream drops events
  /// nobody listened to) doesn't wait on a spinner forever.
  LocationStatus? last;

  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  @override
  void onInit() {
    super.onInit();
    checkLocationStatus();
  }

  @override
  void onClose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.onClose();
  }

  Future<void> checkLocationStatus() async {
    try {
      final locationStatus = await FlutterQiblah.checkLocationStatus();
      if (locationStatus.enabled &&
          locationStatus.status == LocationPermission.denied) {
        await FlutterQiblah.requestPermissions();
        _emit(await FlutterQiblah.checkLocationStatus());
      } else {
        _emit(locationStatus);
      }
    } catch (e) {
      if (!_locationStreamController.isClosed) {
        _locationStreamController.sink.addError(e);
      }
    }
  }

  Future<void> restartCheckLocationStatus() async {
    try {
      _emit(await FlutterQiblah.checkLocationStatus());
    } catch (e) {
      if (!_locationStreamController.isClosed) {
        _locationStreamController.sink.addError(e);
      }
    }
  }

  void _emit(LocationStatus s) {
    last = s;
    if (!_locationStreamController.isClosed) {
      _locationStreamController.sink.add(s);
    }
  }

  Future<double?> distanceToKaabaKm() async {
    try {
      // With GPS off, getCurrentPosition pops a Play Services dialog on every call.
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      );
      final double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        kaabaLatitude,
        kaabaLongitude,
      );
      return (distanceInMeters / 1000).roundToDouble();
    } catch (_) {
      return null;
    }
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Where the compass stands: one state at a time, so the screen only maps it
/// to a view.
enum QiblaStatus {
  checking,
  sensorMissing,
  sensorError,
  gpsOff,
  denied,
  deniedForever,
  failed,
  ready,
}

class QiblaController extends GetxController with WidgetsBindingObserver {
  final status = QiblaStatus.checking.obs;

  /// Null until known, or when it can't be had; the card then hides the row.
  final distanceKm = Rxn<double>();

  bool _busy = false;

  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    refreshStatus(ask: true);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterQiblah().dispose();
    super.onClose();
  }

  // Back from system settings after enabling GPS or the permission.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshStatus();
  }

  /// Checks the sensor, GPS and permission in that order. [ask] shows the
  /// system permission prompt when it is still undecided; it never reopens
  /// once the user has chosen "don't ask again".
  Future<void> refreshStatus({bool ask = false}) async {
    if (_busy) return;
    _busy = true;
    // Keep the compass on screen while a resume re-checks behind it.
    if (status.value != QiblaStatus.ready) status.value = QiblaStatus.checking;
    try {
      status.value = await _resolve(ask);
      if (status.value == QiblaStatus.ready) await _fetchDistance();
    } catch (_) {
      status.value = QiblaStatus.failed;
    } finally {
      _busy = false;
    }
  }

  Future<QiblaStatus> _resolve(bool ask) async {
    try {
      if (await FlutterQiblah.androidDeviceSensorSupport() == false) {
        return QiblaStatus.sensorMissing;
      }
    } catch (_) {
      return QiblaStatus.sensorError;
    }
    if (!await Geolocator.isLocationServiceEnabled()) return QiblaStatus.gpsOff;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && ask) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse =>
        QiblaStatus.ready,
      LocationPermission.deniedForever => QiblaStatus.deniedForever,
      _ => QiblaStatus.denied,
    };
  }

  /// The permission view's button: ask again, or go to settings once asking
  /// no longer shows a prompt.
  Future<void> allowLocation() => status.value == QiblaStatus.deniedForever
      ? Geolocator.openAppSettings()
      : refreshStatus(ask: true);

  Future<void> _fetchDistance() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      );
      distanceKm.value = (Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                kaabaLatitude,
                kaabaLongitude,
              ) /
              1000)
          .roundToDouble();
    } catch (_) {
      distanceKm.value = null;
    }
  }
}

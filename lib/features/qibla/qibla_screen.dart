import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/qibla/qibla_controller.dart';
import 'package:noor/features/qibla/widgets/qibla_calibration_sheet.dart';
import 'package:noor/features/qibla/widgets/qibla_compass.dart';
import 'package:noor/generals/controllers/location_controller.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/location_pill.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_header.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver {
  late final QiblaController _controller;
  late final Future<bool?> _deviceSupport;
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    // Create controller once
    _controller = Get.put(QiblaController());
    WidgetsBinding.instance.addObserver(this);

    // Ensure AdhanController is registered for LocationPill
    if (!Get.isRegistered<AdhanController>()) {
      Get.put(AdhanController());
    }

    // Move LocationController.getLocation() out of build into initState
    final locationController = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());
    locationController.getLocation();

    // Check device sensor support
    _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

    // Fetch distance to Kaaba
    _fetchDistance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<QiblaController>();
    super.dispose();
  }

  // Back from system settings after enabling GPS or the permission.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.restartCheckLocationStatus();
      _fetchDistance();
    }
  }

  Future<void> _fetchDistance() async {
    final double? distance = await _controller.distanceToKaabaKm();
    if (mounted) {
      setState(() => _distanceKm = distance);
    }
  }

  Future<void> _requestPermission() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
    if (await Permission.location.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.noor.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NoorHeader(),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                NoorSpace.xl,
                NoorSpace.xs,
                NoorSpace.xl,
                NoorSpace.sm,
              ),
              child: LocationPill(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: NoorSpace.xl,
                  right: NoorSpace.xl,
                  top: NoorSpace.xs,
                  bottom: 96,
                ),
                child: FutureBuilder<bool?>(
                  future: _deviceSupport,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildCalmSpinner();
                    }

                    if (snapshot.hasError) {
                      return EmptyState(
                        icon: Icons.error_outline_rounded,
                        message: '${snapshot.error}',
                        actionLabel: S.of(context).try_again,
                        onAction: () => setState(() {}),
                      );
                    }

                    // If sensor unsupported
                    if (snapshot.data == false) {
                      return EmptyState(
                        icon: Icons.explore_off_outlined,
                        message: S.of(context).sensor_not_supported,
                        actionLabel: S.of(context).try_again,
                        onAction: () => setState(() {}),
                      );
                    }

                    // Sensor supported: stream location status
                    return StreamBuilder<LocationStatus>(
                      stream: _controller.stream,
                      initialData: _controller.last,
                      builder: (context, locationSnapshot) {
                        if (locationSnapshot.hasError) {
                          return EmptyState(
                            message: '${locationSnapshot.error}',
                            actionLabel: S.of(context).try_again,
                            onAction: () =>
                                _controller.restartCheckLocationStatus(),
                          );
                        }

                        final LocationStatus? status = locationSnapshot.data;
                        if (status == null) {
                          return _buildCalmSpinner();
                        }

                        // GPS signal is off
                        if (!status.enabled) {
                          return EmptyState(
                            icon: Icons.location_off_outlined,
                            message: S.of(context).enable_location_body,
                            actionLabel: S.of(context).open_settings,
                            // The resume observer re-checks on return.
                            onAction: Geolocator.openLocationSettings,
                          );
                        }

                        // Permission check
                        switch (status.status) {
                          case LocationPermission.always:
                          case LocationPermission.whileInUse:
                            return _buildActiveCompass();

                          case LocationPermission.denied:
                          case LocationPermission.deniedForever:
                            return EmptyState(
                              icon: Icons.location_off_outlined,
                              message: S.of(context).enable_location_permission,
                              actionLabel: status.status ==
                                      LocationPermission.deniedForever
                                  ? S.of(context).open_settings
                                  : S.of(context).try_again,
                              onAction: () async {
                                await _requestPermission();
                                await _controller.restartCheckLocationStatus();
                                _fetchDistance();
                              },
                            );

                          default:
                            return _buildCalmSpinner();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalmSpinner() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: NoorSpace.xxxl * 2),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _buildActiveCompass() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return _buildCalmSpinner();
        }

        final QiblahDirection qiblahDirection = snapshot.data!;

        return Column(
          children: [
            const SizedBox(height: NoorSpace.md),
            QiblaCompass(
              direction: qiblahDirection.direction,
              qiblah: qiblahDirection.qiblah,
            ),
            const SizedBox(height: NoorSpace.xxl),
            QiblaDirectionCard(
              offset: qiblahDirection.offset,
              distanceKm: _distanceKm,
              onCalibrate: () => showQiblaCalibrationSheet(context),
            ),
          ],
        );
      },
    );
  }
}

class QiblaDirectionCard extends StatelessWidget {
  final double offset;
  final double? distanceKm;
  final VoidCallback? onCalibrate;

  const QiblaDirectionCard({
    super.key,
    required this.offset,
    this.distanceKm,
    this.onCalibrate,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    return NoorCard(
      padding: const EdgeInsets.all(NoorSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).qibla_direction,
                      style: NoorText.rowTitle(context).copyWith(
                        color: n.muted,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: NoorSpace.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '${offset.toStringAsFixed(2)}°',
                        style: NoorText.numeral(
                          context,
                          size: 56,
                          color: n.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: NoorSpace.md),
              NoorButton(
                label: S.of(context).calibrate,
                icon: const Icon(Icons.explore_outlined, size: 20),
                variant: NoorButtonVariant.tonal,
                onPressed: onCalibrate,
              ),
            ],
          ),
          if (distanceKm != null) ...[
            Container(
              height: 1,
              color: n.line,
              margin: const EdgeInsets.symmetric(vertical: NoorSpace.md),
            ),
            Row(
              children: [
                Icon(
                  Iconsax.location,
                  size: 18,
                  color: n.muted,
                ),
                const SizedBox(width: NoorSpace.sm),
                Text(
                  S.of(context).distance_to_kaaba,
                  style: NoorText.body(context).copyWith(
                    color: n.muted,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '~ ${distanceKm!.toInt()} km',
                    style: NoorText.numeral(
                      context,
                      size: 15,
                      color: n.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
import 'package:noor/generals/widgets/loading_state.dart';
import 'package:noor/generals/widgets/location_pill.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
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

  Widget _scroll(Widget child) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: NoorSpace.s4),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    // The shell's Scaffold extends the body under the nav bar and reports its
    // height as bottom padding; nothing of ours may sit in that band.
    final navInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: context.noor.paper,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The night skyline is the hero's art; it is in NoorArt.noMirror,
          // so it keeps its place in RTL.
          NoorHero(
            art: NoorArt.qiblaSkyline,
            settings: true,
            title: S.of(context).nav_qibla,
            subtitle: S.of(context).tagline_qibla,
            overlap: const LocationPill(),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                NoorLayout.gutter(context),
                NoorSpace.s4,
                NoorLayout.gutter(context),
                navInset + NoorSpace.s4,
              ),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<bool?>(
      future: _deviceSupport,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCalmSpinner();
        }

        // No button on these two: the sensor check runs once, so a retry would
        // only rebuild the same result.
        if (snapshot.hasError) {
          return _scroll(EmptyState(
            danger: true,
            icon: NoorGlyph.alert,
            message: S.of(context).compass_error,
          ));
        }

        // If sensor unsupported
        if (snapshot.data == false) {
          return _scroll(EmptyState(
            icon: NoorGlyph.compass,
            message: S.of(context).sensor_not_supported,
          ));
        }

        // Sensor supported: stream location status
        return StreamBuilder<LocationStatus>(
          stream: _controller.stream,
          initialData: _controller.last,
          builder: (context, locationSnapshot) {
            if (locationSnapshot.hasError) {
              return _scroll(EmptyState(
                danger: true,
                icon: NoorGlyph.alert,
                message: S.of(context).location_failed,
                actionLabel: S.of(context).try_again,
                onAction: () => _controller.restartCheckLocationStatus(),
              ));
            }

            final LocationStatus? status = locationSnapshot.data;
            if (status == null) {
              return _buildCalmSpinner();
            }

            // GPS signal is off
            if (!status.enabled) {
              return _scroll(EmptyState(
                icon: Iconsax.location_slash,
                message: S.of(context).gps_off,
                actionLabel: S.of(context).open_settings,
                // The resume observer re-checks on return.
                onAction: Geolocator.openLocationSettings,
              ));
            }

            // Permission check
            switch (status.status) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return _buildActiveCompass();

              case LocationPermission.denied:
              case LocationPermission.deniedForever:
                return _scroll(EmptyState(
                  icon: Iconsax.location_slash,
                  message: S.of(context).enable_location_permission,
                  actionLabel: status.status == LocationPermission.deniedForever
                      ? S.of(context).open_settings
                      : S.of(context).try_again,
                  onAction: () async {
                    await _requestPermission();
                    await _controller.restartCheckLocationStatus();
                    _fetchDistance();
                  },
                ));

              default:
                return _buildCalmSpinner();
            }
          },
        );
      },
    );
  }

  Widget _buildCalmSpinner() => const LoadingState();

  // Below this the compass can't keep 160 dp beside the card, so scroll.
  // ponytail: fixed card-height estimate; measure the card if its content grows.
  static const double _minFit = 160 + NoorSpace.s4 + 245;

  Widget _buildActiveCompass() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return _buildCalmSpinner();
        }

        final QiblahDirection qiblahDirection = snapshot.data!;
        final compass = QiblaCompass(
          direction: qiblahDirection.direction,
          qiblah: qiblahDirection.qiblah,
        );
        final card = NoorSettle(
          child: QiblaDirectionCard(
            offset: qiblahDirection.offset,
            distanceKm: _distanceKm,
            onCalibrate: () => showQiblaCalibrationSheet(context),
          ),
        );

        return LayoutBuilder(
          builder: (context, box) {
            if (box.maxHeight < _minFit) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 160, child: compass),
                    const SizedBox(height: NoorSpace.s4),
                    card,
                  ],
                ),
              );
            }
            // The compass takes what the card leaves, so it shrinks first.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Center(child: compass)),
                const SizedBox(height: NoorSpace.s4),
                card,
              ],
            );
          },
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
    // Side by side no longer fit past about 1.5x; stack them instead.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 24;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).qibla_direction,
          style: NoorText.bodySm(context),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '${offset.toStringAsFixed(2)}°',
            textDirection: TextDirection.ltr,
            style: NoorText.numeral(
              context,
              size: 48,
              color: n.ink,
            ),
          ),
        ),
      ],
    );
    final calibrate = NoorButton(
      label: S.of(context).calibrate,
      icon: const NoorIcon(NoorGlyph.compass),
      variant: NoorButtonVariant.tonal,
      onPressed: onCalibrate,
    );
    final distanceLabel = Text(
      S.of(context).distance_to_kaaba,
      style: NoorText.bodySm(context),
    );
    final distanceValue = Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        '~ ${distanceKm?.toInt()} km',
        style: NoorText.numeral(
          context,
          size: 18,
          color: n.muted,
        ),
      ),
    );

    return NoorCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stacked) ...[
            heading,
            const SizedBox(height: NoorSpace.s3),
            calibrate,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: heading),
                const SizedBox(width: NoorSpace.s3),
                calibrate,
              ],
            ),
          if (distanceKm != null) ...[
            Container(
              height: 1,
              color: n.line,
              margin: const EdgeInsets.symmetric(vertical: NoorSpace.s3),
            ),
            Row(
              crossAxisAlignment: stacked
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.location,
                  size: 18,
                  color: n.muted,
                ),
                const SizedBox(width: NoorSpace.s2),
                Expanded(
                  child: stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [distanceLabel, distanceValue],
                        )
                      : distanceLabel,
                ),
                if (!stacked) ...[
                  const SizedBox(width: NoorSpace.s2),
                  distanceValue,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

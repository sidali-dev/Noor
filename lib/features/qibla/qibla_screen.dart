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
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
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
        padding: const EdgeInsets.only(top: NoorSpace.xl),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    // The shell's Scaffold extends the body under the nav bar and reports its
    // height as bottom padding; nothing of ours may sit in that band.
    final navInset = MediaQuery.paddingOf(context).bottom;
    // The skyline rests just above the nav bar's top edge, and the card stays
    // clear of the Kaaba.
    const footerBand = 56.0;

    return Scaffold(
      backgroundColor: context.noor.paper,
      body: Stack(
        children: [
          // Footer art, first in the stack so it sits under all content.
          // Never mirrored (NoorArt.noMirror).
          Positioned(
            left: 0,
            right: 0,
            bottom: navInset - 20,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Image.asset(
                  NoorArt.of(context, NoorArt.qiblaSkyline),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NoorHero(
                settings: true,
                title: S.of(context).nav_qibla,
                subtitle: S.of(context).tagline_qibla,
                height: 180,
                overlap: const LocationPill(),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    NoorSpace.xl,
                    NoorSpace.sm,
                    NoorSpace.xl,
                    navInset + footerBand,
                  ),
                  child: _buildBody(),
                ),
              ),
            ],
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

        if (snapshot.hasError) {
          return _scroll(EmptyState(
            icon: Icons.error_outline_rounded,
            message: '${snapshot.error}',
            actionLabel: S.of(context).try_again,
            onAction: () => setState(() {}),
          ));
        }

        // If sensor unsupported
        if (snapshot.data == false) {
          return _scroll(EmptyState(
            icon: Icons.explore_off_outlined,
            message: S.of(context).sensor_not_supported,
            actionLabel: S.of(context).try_again,
            onAction: () => setState(() {}),
          ));
        }

        // Sensor supported: stream location status
        return StreamBuilder<LocationStatus>(
          stream: _controller.stream,
          initialData: _controller.last,
          builder: (context, locationSnapshot) {
            if (locationSnapshot.hasError) {
              return _scroll(EmptyState(
                message: '${locationSnapshot.error}',
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
                icon: Icons.location_off_outlined,
                message: S.of(context).enable_location_body,
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
                  icon: Icons.location_off_outlined,
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

  Widget _buildCalmSpinner() {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  // Below this the compass can't keep 160 dp beside the card, so scroll.
  // ponytail: fixed card-height estimate; measure the card if its content grows.
  static const double _minFit = 160 + NoorSpace.lg + 200;

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
        final card = QiblaDirectionCard(
          offset: qiblahDirection.offset,
          distanceKm: _distanceKm,
          onCalibrate: () => showQiblaCalibrationSheet(context),
        );

        return LayoutBuilder(
          builder: (context, box) {
            if (box.maxHeight < _minFit) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 160, child: compass),
                    const SizedBox(height: NoorSpace.lg),
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
                const SizedBox(height: NoorSpace.lg),
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

    return NoorCard(
      padding: const EdgeInsets.all(NoorSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                      style: NoorText.meta(context),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '${offset.toStringAsFixed(2)}°',
                        style: NoorText.numeral(
                          context,
                          size: 48,
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

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/qibla/controllers/qibla_controller.dart';
import 'package:noor/features/qibla/views/widgets/qibla_calibration_sheet.dart';
import 'package:noor/features/qibla/views/widgets/qibla_compass.dart';
import 'package:noor/core/services/location_service.dart';
import 'package:noor/core/widgets/empty_state.dart';
import 'package:noor/core/widgets/loading_state.dart';
import 'package:noor/core/widgets/location_pill.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_hero.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/theme/noor_layout.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';

class QiblaView extends StatefulWidget {
  const QiblaView({super.key});

  @override
  State<QiblaView> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaView> {
  late final QiblaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(QiblaController());
    Get.find<LocationService>().getLocation();
  }

  @override
  void dispose() {
    Get.delete<QiblaController>();
    super.dispose();
  }

  // The shell's Scaffold extends the body under the nav bar and reports its
  // height as bottom padding. It goes inside the scroll view so content
  // scrolls behind the floating bar instead of being cut above it.
  double get _bottom => MediaQuery.paddingOf(context).bottom + NoorSpace.s4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.noor.paper,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: _bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The widest window, so the verse takes the first 40%.
            NoorHero(
              art: NoorArt.heroQibla,
              settings: true,
              title: S.of(context).nav_qibla,
              subtitle: S.of(context).tagline_qibla,
              textShare: 0.4,
              overlap: const LocationPill(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                NoorLayout.gutter(context),
                NoorSpace.s4,
                NoorLayout.gutter(context),
                0,
              ),
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final context = this.context;
      final c = _controller;
      switch (c.status.value) {
        case QiblaStatus.checking:
          return _buildCalmSpinner();
        // No button on these two: the sensor is checked again on resume, but a
        // retry here would only rebuild the same result.
        case QiblaStatus.sensorError:
          return EmptyState(
            danger: true,
            icon: NoorGlyph.alert,
            message: S.of(context).compass_error,
          );
        case QiblaStatus.sensorMissing:
          return EmptyState(
            icon: NoorGlyph.compass,
            message: S.of(context).sensor_not_supported,
          );
        case QiblaStatus.failed:
          return EmptyState(
            danger: true,
            icon: NoorGlyph.alert,
            message: S.of(context).location_failed,
            actionLabel: S.of(context).try_again,
            onAction: () => c.refreshStatus(ask: true),
          );
        case QiblaStatus.gpsOff:
          return EmptyState(
            icon: Iconsax.location_slash,
            message: S.of(context).gps_off,
            actionLabel: S.of(context).open_settings,
            // Resuming from settings re-checks.
            onAction: Geolocator.openLocationSettings,
          );
        case QiblaStatus.denied:
        case QiblaStatus.deniedForever:
          return EmptyState(
            icon: Iconsax.location_slash,
            message: S.of(context).enable_location_permission,
            actionLabel: c.status.value == QiblaStatus.deniedForever
                ? S.of(context).open_settings
                : S.of(context).try_again,
            onAction: c.allowLocation,
          );
        case QiblaStatus.ready:
          return _buildActiveCompass();
      }
    });
  }

  Widget _buildCalmSpinner() => const Padding(
        padding: EdgeInsets.symmetric(vertical: NoorSpace.s7),
        child: LoadingState(),
      );

  Widget _buildActiveCompass() {
    return StreamBuilder<QiblahDirection>(
      stream: _controller.direction,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            danger: true,
            icon: NoorGlyph.alert,
            message: S.of(context).compass_error,
          );
        }
        if (!snapshot.hasData) return _buildCalmSpinner();

        final QiblahDirection qiblahDirection = snapshot.data!;
        final compass = QiblaCompass(
          direction: qiblahDirection.direction,
          qiblah: qiblahDirection.qiblah,
        );
        final card = NoorSettle(
          child: Obx(() => QiblaDirectionCard(
                offset: qiblahDirection.offset,
                distanceKm: _controller.distanceKm.value,
                onCalibrate: () => showQiblaCalibrationSheet(context),
              )),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: NoorSpace.s6),
            SizedBox(height: 260, child: compass),
            const SizedBox(height: NoorSpace.s6),
            card,
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

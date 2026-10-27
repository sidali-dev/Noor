import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/widgets/location_picker_sheet.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generals/widgets/wait_dialog.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationSource { gps, manual }

Future<void> pickLocation(BuildContext context) async {
  final s = S.of(context);
  final n = context.noor;

  // 1. Choose the source first: showNoorSheet with GPS and Manual choices.
  final source = await showNoorSheet<LocationSource>(
    context,
    title: s.enter_location,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.only(top: NoorSpace.sm, bottom: NoorSpace.md),
        child: Row(
          children: [
            Expanded(
              child: NoorCard(
                onTap: () => Navigator.of(sheetContext).pop(LocationSource.gps),
                padding: const EdgeInsets.symmetric(
                  vertical: NoorSpace.xl,
                  horizontal: NoorSpace.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IconTile(
                      icon: Icons.my_location_rounded,
                      tint: NoorTint.sage,
                      size: 56,
                    ),
                    const SizedBox(height: NoorSpace.md),
                    Text(
                      s.gps,
                      style: NoorText.rowTitle(sheetContext).copyWith(
                        color: n.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: NoorSpace.md),
            Expanded(
              child: NoorCard(
                onTap: () =>
                    Navigator.of(sheetContext).pop(LocationSource.manual),
                padding: const EdgeInsets.symmetric(
                  vertical: NoorSpace.xl,
                  horizontal: NoorSpace.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IconTile(
                      icon: Icons.edit_location_alt_outlined,
                      tint: NoorTint.mint,
                      size: 56,
                    ),
                    const SizedBox(height: NoorSpace.md),
                    Text(
                      s.manually,
                      style: NoorText.rowTitle(sheetContext).copyWith(
                        color: n.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (!context.mounted || source == null) return;

  final String selectedCountry;
  final String selectedState;
  final String selectedCity;

  if (source == LocationSource.gps) {
    // 2. GPS: WaitDialog, _currentPlacemark()
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WaitDialog(),
    );

    Placemark? placemark;
    var permissionDenied = false;
    try {
      placemark = await _currentPlacemark();
    } on PermissionDeniedException {
      permissionDenied = true;
    } catch (_) {
      placemark = null;
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) return;

    if (permissionDenied) {
      await _showFailSheet(
        context,
        icon: Icons.location_off_outlined,
        message: S.of(context).enable_location_permission,
        actionLabel: S.of(context).open_settings,
        onAction: openAppSettings,
      );
      return;
    }

    // Fallbacks:
    // administrativeArea ?? subAdministrativeArea ?? locality for state;
    // locality ?? subAdministrativeArea for city
    // No `!` on placemark fields.
    String? country = placemark?.country?.trim();
    if (country != null && country.isEmpty) country = null;

    String? city = placemark?.locality?.trim();
    if (city == null || city.isEmpty) {
      city = placemark?.subAdministrativeArea?.trim();
    }
    if (city != null && city.isEmpty) city = null;

    String? state = placemark?.administrativeArea?.trim();
    if (state == null || state.isEmpty) {
      state = placemark?.subAdministrativeArea?.trim();
    }
    if (state == null || state.isEmpty) {
      state = placemark?.locality?.trim();
    }
    if (state != null && state.isEmpty) state = null;

    if (country == null || state == null || city == null) {
      await _showFailSheet(
        context,
        icon: Icons.location_off_outlined,
        message: S.of(context).location_failed,
        actionLabel: S.of(context).try_again,
        onAction: () => pickLocation(context),
      );
      return;
    }

    selectedCountry = country;
    selectedState = state;
    selectedCity = city;
  } else {
    // 3. Manual: location_picker_sheet; an empty result does nothing.
    final result = await showLocationPickerSheet(context);
    if (!context.mounted || result == null || result.isEmpty) return;

    final country = result['country']?.trim();
    final state = result['state']?.trim();
    final city = result['city']?.trim();

    if (country == null ||
        country.isEmpty ||
        state == null ||
        state.isEmpty ||
        city == null ||
        city.isEmpty) {
      return;
    }

    selectedCountry = country;
    selectedState = state;
    selectedCity = city;
  }

  if (!context.mounted) return;
  await _saveLocation(context, selectedCountry, selectedState, selectedCity);
}

/// WaitDialog, refreshAdhanData, close wait dialog; offers a retry on failure.
Future<void> _saveLocation(
  BuildContext context,
  String country,
  String state,
  String city,
) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const WaitDialog(),
  );

  Object? error;
  try {
    await Get.find<AdhanController>()
        .refreshAdhanData(country, state, city, DateTime.now().year);
  } catch (e) {
    error = e;
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (error == null || !context.mounted) return;

  await _showFailSheet(
    context,
    icon: error is NoInternetException
        ? Icons.wifi_off_rounded
        : Icons.location_off_outlined,
    message: error is NoInternetException
        ? S.of(context).no_internet
        : S.of(context).location_failed,
    actionLabel: S.of(context).try_again,
    onAction: () => _saveLocation(context, country, state, city),
  );
}

Future<void> _showFailSheet(
  BuildContext context, {
  required IconData icon,
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  return showNoorSheet(
    context,
    builder: (sheetContext) => EmptyState(
      icon: icon,
      message: message,
      actionLabel: actionLabel,
      onAction: () {
        Navigator.of(sheetContext).pop();
        onAction();
      },
    ),
  );
}

/// Current GPS position as a [Placemark]. Throws [PermissionDeniedException]
/// when permission is still missing after one request.
Future<Placemark> _currentPlacemark() async {
  var status = (await FlutterQiblah.checkLocationStatus()).status;
  if (status == LocationPermission.denied) {
    await FlutterQiblah.requestPermissions();
    status = (await FlutterQiblah.checkLocationStatus()).status;
  }
  if (status != LocationPermission.always &&
      status != LocationPermission.whileInUse) {
    throw const PermissionDeniedException('location');
  }
  final p = await Geolocator.getCurrentPosition();
  return (await placemarkFromCoordinates(p.latitude, p.longitude)).first;
}

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/widgets/location_picker_sheet.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generals/widgets/wait_dialog.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationSource { gps, manual }

/// Picks and saves a location. With [source], skips the choice sheet.
Future<void> pickLocation(BuildContext context,
    {LocationSource? source}) async {
  final s = S.of(context);

  // 1. Choose the source first: radio cards, then Confirm Location.
  source ??= await showNoorSheet<LocationSource>(
    context,
    title: s.location_title,
    builder: (_) => const _LocationChoice(),
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

class _LocationChoice extends StatefulWidget {
  const _LocationChoice();

  @override
  State<_LocationChoice> createState() => _LocationChoiceState();
}

class _LocationChoiceState extends State<_LocationChoice> {
  LocationSource? _source;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return RadioGroup<LocationSource>(
      groupValue: _source,
      onChanged: (v) => setState(() => _source = v),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.location_subtitle,
            style: NoorText.body(context).copyWith(color: context.noor.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NoorSpace.xl),
          _SourceCard(
            value: LocationSource.gps,
            icon: Icons.my_location_rounded,
            tint: NoorTint.sage,
            title: s.gps,
            subtitle: s.gps_subtitle,
            onTap: () => setState(() => _source = LocationSource.gps),
          ),
          const SizedBox(height: NoorSpace.md),
          _SourceCard(
            value: LocationSource.manual,
            icon: Icons.edit_location_alt_outlined,
            tint: NoorTint.mint,
            title: s.manually,
            subtitle: s.manual_subtitle,
            onTap: () => setState(() => _source = LocationSource.manual),
          ),
          const SizedBox(height: NoorSpace.xxl),
          NoorButton(
            label: s.confirm_location,
            onPressed: _source == null
                ? null
                : () => Navigator.of(context).pop(_source),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final LocationSource value;
  final IconData icon;
  final NoorTint tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceCard({
    required this.value,
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return NoorCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: NoorSpace.lg,
        vertical: NoorSpace.md,
      ),
      child: Row(
        children: [
          IconTile(icon: icon, tint: tint),
          const SizedBox(width: NoorSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: NoorText.rowTitle(context).copyWith(color: n.ink)),
                Text(subtitle,
                    style: NoorText.meta(context).copyWith(color: n.muted)),
              ],
            ),
          ),
          Radio<LocationSource>(value: value, activeColor: n.primary),
        ],
      ),
    );
  }
}

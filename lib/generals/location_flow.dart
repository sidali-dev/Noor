import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/widgets/location_picker_sheet.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_radio.dart';
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
        icon: Iconsax.location_slash,
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
        icon: NoorGlyph.alert,
        danger: true,
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
    icon: NoorGlyph.alert,
    danger: true,
    message: error is NoInternetException
        ? S.of(context).no_internet
        : S.of(context).prayer_times_failed,
    actionLabel: S.of(context).try_again,
    onAction: () => _saveLocation(context, country, state, city),
  );
}

Future<void> _showFailSheet(
  BuildContext context, {
  required Object icon, // IconData or NoorGlyph, as EmptyState takes
  bool danger = false,
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  return showNoorSheet(
    context,
    builder: (sheetContext) => EmptyState(
      icon: icon,
      danger: danger,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.location_subtitle,
          style: NoorText.body(context).copyWith(color: context.noor.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NoorSpace.s4),
        NoorListGroup(
          children: [
            _SourceRow(
              icon: Iconsax.gps,
              title: s.gps,
              subtitle: s.gps_subtitle,
              selected: _source == LocationSource.gps,
              onTap: () => setState(() => _source = LocationSource.gps),
            ),
            _SourceRow(
              icon: Iconsax.edit,
              title: s.manually,
              subtitle: s.manual_subtitle,
              selected: _source == LocationSource.manual,
              onTap: () => setState(() => _source = LocationSource.manual),
            ),
          ],
        ),
        const SizedBox(height: NoorSpace.s5),
        NoorButton(
          label: s.confirm_location,
          onPressed:
              _source == null ? null : () => Navigator.of(context).pop(_source),
        ),
      ],
    );
  }
}

class _SourceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SourceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: NoorListRow(
        leading: Icon(icon, size: 24, color: n.ink),
        title: title,
        meta: subtitle,
        trailing: NoorRadioMark(selected: selected),
        onTap: onTap,
        titleStyle: NoorText.heading(context).copyWith(color: n.ink),
      ),
    );
  }
}

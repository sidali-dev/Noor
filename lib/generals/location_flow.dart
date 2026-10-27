import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/widgets/location_picker_sheet.dart';
import 'package:noor/generals/widgets/check_dialog.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generals/widgets/wait_dialog.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/helpers/helper_functions.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:noor/utils/theme/noor_theme.dart';

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
                    Image.asset(
                      SImageString.location,
                      height: 56,
                      width: 56,
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
                    Image.asset(
                      SImageString.manual,
                      height: 56,
                      width: 56,
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

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  if (source == LocationSource.gps) {
    // 2. GPS: WaitDialog, SHelperFunctions.getLocation()
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WaitDialog(isDark: isDark, isRtl: isRtl),
    );

    Placemark? placemark;
    try {
      placemark = await SHelperFunctions.getLocation();
    } catch (_) {
      placemark = null;
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) return;

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
      await showDialog(
        context: context,
        builder: (c) => CheckDialog(
          title: S.of(c).location_failed,
          imagePath: SImageString.lottieError,
          color: c.noor.danger,
        ),
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

  // 4. With a result: WaitDialog, refreshAdhanData, close wait dialog.
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => WaitDialog(isDark: isDark, isRtl: isRtl),
  );

  Object? error;
  try {
    final adhanController = Get.find<AdhanController>();
    await adhanController.refreshAdhanData(
      selectedCountry,
      selectedState,
      selectedCity,
      DateTime.now().year,
    );
  } catch (e) {
    error = e;
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (!context.mounted) return;

  if (error != null) {
    if (error is NoInternetException) {
      await showDialog(
        context: context,
        builder: (c) => CheckDialog(
          title: S.of(c).no_internet,
          imagePath: SImageString.lottieNoInternet,
          color: c.noor.primary,
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (c) => CheckDialog(
          title: S.of(c).location_failed,
          imagePath: SImageString.lottieError,
          color: c.noor.danger,
        ),
      );
    }
  }
}

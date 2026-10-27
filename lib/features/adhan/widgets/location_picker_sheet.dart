import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Future<Map<String, String>?> showLocationPickerSheet(BuildContext context) {
  return showNoorSheet<Map<String, String>>(
    context,
    title: S.of(context).pick_location,
    builder: (sheetContext) => const LocationPickerSheet(),
  );
}

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  String? _country;
  String? _state;
  String? _city;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: NoorSpace.sm),
        CSCPickerPlus(
          flagState: CountryFlag.DISABLE,
          layout: Layout.vertical,
          dropdownDecoration: BoxDecoration(
            color: n.card,
            borderRadius: BorderRadius.circular(NoorRadius.input),
            border: Border.all(color: n.line, width: 1.2),
          ),
          disabledDropdownDecoration: BoxDecoration(
            color: n.isDark ? n.paper : n.line.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(NoorRadius.input),
            border: Border.all(color: n.line.withValues(alpha: 0.5), width: 1),
          ),
          dropdownHeadingStyle: NoorText.rowTitle(context).copyWith(
            color: n.ink,
          ),
          dropdownItemStyle: NoorText.body(context).copyWith(
            color: n.ink,
          ),
          selectedItemStyle: NoorText.body(context).copyWith(
            color: n.ink,
            fontWeight: FontWeight.w500,
          ),
          searchBarRadius: 36,
          dropdownDialogRadius: 24,
          countryDropdownLabel: s.pick_country,
          stateDropdownLabel: s.pick_state,
          cityDropdownLabel: s.pick_city,
          countrySearchPlaceholder: s.country,
          stateSearchPlaceholder: s.state,
          citySearchPlaceholder: s.city,
          onCountryChanged: (value) {
            setState(() {
              _country = value;
            });
          },
          onStateChanged: (value) {
            setState(() {
              _state = value ?? '';
            });
          },
          onCityChanged: (value) {
            setState(() {
              _city = value ?? '';
            });
          },
        ),
        const SizedBox(height: NoorSpace.xl),
        Row(
          children: [
            Expanded(
              child: NoorButton(
                label: s.cancel,
                variant: NoorButtonVariant.outline,
                onPressed: () {
                  Navigator.of(context).pop<Map<String, String>?>(null);
                },
              ),
            ),
            const SizedBox(width: NoorSpace.md),
            Expanded(
              child: NoorButton(
                label: s.confirm,
                variant: NoorButtonVariant.primary,
                onPressed: () {
                  final country = _country?.trim();
                  final state = _state?.trim();
                  final city = _city?.trim();

                  if (country != null &&
                      country.isNotEmpty &&
                      state != null &&
                      state.isNotEmpty &&
                      city != null &&
                      city.isNotEmpty) {
                    Navigator.of(context).pop<Map<String, String>>({
                      'country': country,
                      'state': state,
                      'city': city,
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: NoorSpace.sm),
      ],
    );
  }
}

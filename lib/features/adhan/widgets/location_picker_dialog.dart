import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/generals/widgets/icon_button.dart';

import '../../../generated/l10n.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = SHelperFunctions.isDarkMode(context);
    bool isRtl = SHelperFunctions.isRtl(context);
    String? country;
    String? state;
    String? city;
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: isDark ? Colors.black : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: SSizes.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.location),
                  const SizedBox(width: SSizes.sm),
                  Text(S.of(context).pick_location,
                      style: TextStyle(
                          fontSize:
                              isRtl ? SSizes.fontSizeLgAr : SSizes.fontSizeLg)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
              //Country Picker Widget
              child: CSCPicker(
                flagState: CountryFlag.DISABLE,
                dropdownDecoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                disabledDropdownDecoration: BoxDecoration(
                    color: isDark ? SColors.dark : SColors.lightGrey,
                    borderRadius: BorderRadius.circular(8)),
                dropdownHeadingStyle: TextStyle(
                    fontWeight: isRtl ? FontWeight.w700 : FontWeight.w700,
                    fontSize: isRtl ? SSizes.fontSizeSm : SSizes.fontSizeSm),
                searchBarRadius: 36,
                dropdownDialogRadius: 24,
                layout: Layout.vertical,
                countryDropdownLabel: S.of(context).pick_country,
                stateDropdownLabel: S.of(context).pick_state,
                cityDropdownLabel: S.of(context).pick_city,
                countrySearchPlaceholder: S.of(context).country,
                stateSearchPlaceholder: S.of(context).state,
                citySearchPlaceholder: S.of(context).city,
                onCountryChanged: (value) {
                  country = value;
                },
                onStateChanged: (value) {
                  state = value ?? "";
                },
                onCityChanged: (value) {
                  city = value ?? "";
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomIconButton(
                    isOutline: true,
                    onTap: () {
                      Get.back(result: {});
                    },
                    icon: Icons.close,
                    title: S.of(context).cancel,
                    color: SColors.primary),
                CustomIconButton(
                    isOutline: false,
                    onTap: () {
                      if (country != null &&
                          country!.isNotEmpty &&
                          state != null &&
                          state!.isNotEmpty &&
                          city != null &&
                          city!.isNotEmpty) {
                        Get.back(result: {
                          "country": country,
                          "state": state,
                          "city": city
                        });
                      }
                    },
                    icon: Icons.check,
                    title: S.of(context).confirm,
                    color: SColors.primary)
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

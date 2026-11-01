import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/generals/location_flow.dart';
import 'package:noor/generals/widgets/noor_pill.dart';
import 'package:noor/generated/l10n.dart';

/// The current place as a [NoorPill]: location icon, "Country, City" and a
/// chevron. Tapping opens the location picker.
class LocationPill extends StatelessWidget {
  const LocationPill({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<AdhanController>().locationController;

    return Obx(() {
      final country = locationController.country.value.trim();
      final city = locationController.city.value.trim();

      return NoorPill(
        icon: const Icon(Iconsax.location),
        label: (country.isNotEmpty && city.isNotEmpty)
            ? '$country, $city'
            : S.of(context).enter_location,
        onTap: () => pickLocation(context),
      );
    });
  }
}

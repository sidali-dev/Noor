import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/generals/location_flow.dart';
import 'package:noor/generals/widgets/noor_pill.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class LocationPill extends StatelessWidget {
  const LocationPill({super.key});

  @override
  Widget build(BuildContext context) {
    final adhanController = Get.find<AdhanController>();
    final locationController = adhanController.locationController;

    return Obx(() {
      final country = locationController.country.value.trim();
      final city = locationController.city.value.trim();

      final String label = (country.isNotEmpty && city.isNotEmpty)
          ? '$country, $city'
          : S.of(context).enter_location;

      return NoorPill(
        icon: Icon(
          Iconsax.location,
          size: 18,
          color: context.noor.primary,
        ),
        label: label,
        onTap: () => pickLocation(context),
      );
    });
  }
}

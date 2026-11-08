import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/controllers/adhan_controller.dart';
import 'package:noor/core/services/location_flow.dart';
import 'package:noor/core/widgets/noor_cartouche.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/app_theme.dart';

/// The current place as a [NoorCartouche]: location icon, "Country, City" and a
/// chevron. Tapping opens the location picker.
class LocationPill extends StatelessWidget {
  const LocationPill({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<AdhanController>().locationController;
    final n = context.noor;

    return Obx(() {
      final country = locationController.country.value.trim();
      final city = locationController.city.value.trim();

      return NoorCartouche(
        leading: NoorIcon(NoorGlyph.location, color: n.onWindow, size: 20),
        // chevron_right is declared matchTextDirection, so it flips in RTL.
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: n.onWindowMuted,
          size: 22,
        ),
        onTap: () => pickLocation(context),
        child: Text(
          (country.isNotEmpty && city.isNotEmpty)
              ? '$country, $city'
              : S.of(context).enter_location,
          style: NoorText.label(context).copyWith(color: n.onWindow),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    });
  }
}

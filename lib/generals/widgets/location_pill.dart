import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/generals/location_flow.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class LocationPill extends StatelessWidget {
  const LocationPill({super.key});

  @override
  Widget build(BuildContext context) {
    final adhanController = Get.find<AdhanController>();
    final locationController = adhanController.locationController;
    final n = context.noor;
    final radius = BorderRadius.circular(NoorRadius.tile);

    return Obx(() {
      final country = locationController.country.value.trim();
      final city = locationController.city.value.trim();

      final String label = (country.isNotEmpty && city.isNotEmpty)
          ? '$country, $city'
          : S.of(context).enter_location;

      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: noorShadow(context),
        ),
        child: Material(
          color: n.card,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: n.isDark ? BorderSide(color: n.line) : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => pickLocation(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NoorSpace.lg,
                  vertical: NoorSpace.sm,
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.location, size: 20, color: n.primary),
                    const SizedBox(width: NoorSpace.md),
                    Expanded(
                      child: Text(
                        label,
                        style: NoorText.body(context).copyWith(
                          fontWeight: FontWeight.w500,
                          color: n.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: NoorSpace.sm),
                    Icon(
                      Icons.chevron_right_rounded, // mirrors in RTL
                      color: n.muted,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

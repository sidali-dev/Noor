import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/generals/widgets/noor_mark.dart';
import 'package:noor/generals/widgets/settings_sheet.dart';
import 'package:noor/utils/constants/app_name.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class NoorHeader extends StatelessWidget implements PreferredSizeWidget {
  const NoorHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: Row(
          children: [
            const NoorMark(size: 28),
            const SizedBox(width: NoorSpace.sm + 2),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    kAppName,
                    style: NoorText.wordmark(context),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Iconsax.setting_4,
                color: n.ink,
                size: 22,
              ),
              onPressed: () => showSettingsSheet(context),
              splashRadius: 24,
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

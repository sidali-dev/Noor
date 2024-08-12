import 'package:flutter/material.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final bool isOutline;
  final Color color;
  const CustomIconButton(
      {super.key,
      required this.isOutline,
      required this.color,
      required this.onTap,
      required this.icon,
      required this.title});

  @override
  Widget build(BuildContext context) {
    bool isDark = SHelperFunctions.isDarkMode(context);
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            border: isOutline ? Border.all(color: color, width: 1.5) : null,
            borderRadius: BorderRadius.circular(30),
            color: isOutline ? null : color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isOutline
                    ? color
                    : isDark
                        ? Colors.white
                        : Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOutline
                      ? color
                      : isDark
                          ? Colors.white
                          : Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

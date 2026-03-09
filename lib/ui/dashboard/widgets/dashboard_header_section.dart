import 'package:flutter/material.dart';

import '../../../utils/color_app.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ✅ changed: access current theme
    final isDark = theme.brightness == Brightness.dark; // ✅ changed

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // ✅ changed: use cardColor instead of hard-coded white
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),

        // ✅ changed: adaptive shadow for light / dark
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON ----------------------------------------------------
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ✅ unchanged logic: primary tint works in both themes
              color: ColorApp.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dashboard_customize_rounded,
              color: ColorApp.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // TITLE ---------------------------------------------------
          Expanded(
            child: Text(
              "Your Ticket Overview",
              // ✅ changed: theme-based text color
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

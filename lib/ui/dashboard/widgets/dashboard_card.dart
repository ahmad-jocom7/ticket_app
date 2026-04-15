import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ✅ changed: access current theme
    final isDark = theme.brightness == Brightness.dark; // ✅ changed

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          // ✅ changed: use cardColor instead of Colors.white
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),

          // ✅ changed: adaptive shadow for dark / light
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : color.withValues(alpha: 0.03),
              blurRadius: isDark ? 8 : 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON ---------------------------------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ unchanged logic, but works fine in both themes
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width: 18),

            // TEXT ---------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    // ✅ changed: theme-based text color
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    // ✅ changed: secondary text color from theme
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),

            // ARROW --------------------------------------------------
            Icon(
              Icons.arrow_forward_ios_rounded,
              // ✅ changed: adaptive icon color
              color: theme.iconTheme.color?.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

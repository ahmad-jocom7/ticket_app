import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/ui/add_ticket/add_ticket_screen.dart';
import 'package:ticket_app/ui/dashboard/screens/dashboard_screen.dart';
import 'package:ticket_app/ui/profile/profile_screen.dart';
import 'package:ticket_app/ui/request/request_history_screen.dart';
import 'package:ticket_app/ui/request/request_parts_screen.dart';

import '../utils/color_app.dart';
import 'delivery_request/delivery_request_screen.dart';
import 'my_inventory/my_inventory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Menu")),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: ColorApp.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.menu_rounded,
                      color: ColorApp.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Main Menu",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Select an action to get started",
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            GridView.count(
              childAspectRatio: isTablet ? 1.2 : 1,
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _menuCard(
                  context,
                  title: "Add Ticket",
                  icon: Icons.add_circle_outline_rounded,
                  color: ColorApp.primary,
                  onTap: () => Get.to(() => AddTicketScreen()),
                ),
                _menuCard(
                  context,
                  title: "Dashboard",
                  icon: Icons.dashboard_customize_rounded,
                  color: Colors.deepPurple,
                  onTap: () => Get.to(() => const DashboardScreen()),
                ),
                _menuCard(
                  context,
                  title: "Request Parts",
                  icon: Icons.build_circle_outlined,
                  color: Colors.orange,
                  onTap: () => Get.to(() => RequestPartsScreen()),
                ),
                _menuCard(
                  context,
                  title: "Request History",
                  icon: Icons.history_toggle_off_rounded,
                  color: Colors.blueAccent,
                  onTap: () => Get.to(() => RequestHistoryScreen()),
                ),
                _menuCard(
                  context,
                  title: "My Custody",
                  icon: Icons.inventory_2_outlined,
                  color: Colors.indigo,
                  onTap: () => Get.to(() => MyCustodyScreen()),
                ),
                _menuCard(
                  context,
                  title: "Delivery Requests",
                  icon: Icons.handyman,
                  color: Colors.teal,
                  onTap: () => Get.to(() => DeliveryRequestScreen()),
                ),
                _menuCard(
                  context,
                  title: "Profile",
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFF43A047),
                  onTap: () => Get.to(() => const ProfileScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Menu Card (Theme-aware)
  Widget _menuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 30),
              ),
            ),
            const SizedBox(height: 18),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

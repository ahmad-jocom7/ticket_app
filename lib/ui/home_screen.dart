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

    return Scaffold(
      appBar: AppBar(title: const Text("Menu")),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Main Menu",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Select an action to get started",
                        style: TextStyle(fontSize: 13.5, color: Colors.black54),
                      ),
                    ],
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
                  title: "Add Ticket",
                  icon: Icons.add_circle_outline_rounded,
                  color: ColorApp.primary,

                  onTap: () => Get.to(() => AddTicketScreen()),
                ),
                _menuCard(
                  title: "Dashboard",
                  icon: Icons.dashboard_customize_rounded,
                  color: Colors.deepPurple,
                  onTap: () => Get.to(() => const DashboardScreen()),
                ),
                _menuCard(
                  title: "Request Parts",
                  icon: Icons.build_circle_outlined,
                  color: Colors.orange,
                  onTap: () {
                    Get.to(() => RequestPartsScreen());
                  },
                ),
                _menuCard(
                  title: "Request History",
                  icon: Icons.history_toggle_off_rounded,
                  color: Colors.blueAccent,
                  onTap: () {
                    Get.to(() => RequestHistoryScreen());
                  },
                ),
                _menuCard(
                  title: "My Custody",
                  icon: Icons.inventory_2_outlined,
                  color: Colors.indigo,
                  onTap: () {
                    Get.to(() => MyCustodyScreen());
                  },
                ),
                _menuCard(
                  title: "Delivery Requests",
                  icon: Icons.handyman,
                  color: Colors.teal,
                  onTap: () {
                    Get.to(() => const DeliveryRequestScreen());
                  },
                ),
                _menuCard(
                  title: "Profile",
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFF43A047),
                  onTap: () {
                    Get.to(() => ProfileScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
          // boxShadow: [
          //   BoxShadow(
          //     color: color.withValues(alpha: 0.007),
          //     blurRadius: 10,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
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

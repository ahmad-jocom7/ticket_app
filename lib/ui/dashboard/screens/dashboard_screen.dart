import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/color_app.dart';
import 'ticket_history_screen.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/dashboard_header_section.dart';
import 'accepted_ticket_screen.dart';
import 'new_ticket_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const HeaderSection(),
            const SizedBox(height: 25),
            DashboardCard(
              onTap: () => Get.to(() => AssignedTicketsScreen()),
              title: "New Assigned Tickets",
              subtitle: "View tickets assigned to you",
              icon: Icons.assignment_turned_in_outlined,
              color: ColorApp.primary,
            ),
            DashboardCard(
              onTap: () => Get.to(() => AcceptedTicketsScreen()),
              title: "Accepted Tickets",
              subtitle: "Tickets you are working on",
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            DashboardCard(
              onTap: () => Get.to(() => TicketHistoryScreen()),
              title: "Monthly Served Tickets",
              subtitle: "Closed tickets for this month",
              icon: Icons.task_alt_outlined,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

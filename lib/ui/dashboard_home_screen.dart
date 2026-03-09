import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:ticket_app/ui/login_screen.dart';
import '../controller/accepted_tickets_home_controller.dart';
import '../utils/color_app.dart';
import '../controller/assigned_tickets_controller.dart';
import '../utils/text_style.dart';
import 'dashboard/widgets/accepted_ticket_home_card.dart';
import 'dashboard/widgets/assigned_ticket_card.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final assignedController = Get.put(AssignedTicketController());
  final acceptedController = Get.put(AcceptedTicketHomeController());

  @override
  void initState() {
    super.initState();
    assignedController.fetchAssignedTickets();
    acceptedController.fetchAcceptedTickets();
  }

  void _showLogoutDialog() {
    final theme = Get.theme;
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔴 Icon
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: isDark ? 0.25 : 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Title
              Text(
                "Log out",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // 🔹 Subtitle
              Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        theme.colorScheme.onSurface,
                        side: BorderSide(
                          color: theme.dividerColor,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        mySharedPreferences.clearProfile();
                        Get.offAll(() => LoginScreen());
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(onPressed: _showLogoutDialog, icon: Icon(Icons.login)),
        ],
      ),
      body: RefreshIndicator(
        color: ColorApp.primary,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await Future.wait([
            assignedController.fetchAssignedTickets(),
            acceptedController.fetchAcceptedTickets(),
          ]);
        },
        child:Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              GetBuilder<AssignedTicketController>(
                builder: (_) {
                  return _sectionTitle(
                    "Assigned Tickets",
                    assignedController.data.length,
                    color: Colors.orange,
                    isOpen: assignedController.showAssigned,
                  );
                },
              ),

              Obx(() {
                if (!assignedController.showAssigned.value) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                if (assignedController.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: AssignedTicketShimmer(),
                    ),
                  );
                }

                if (assignedController.data.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text("No assigned tickets.")),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final ticket = assignedController.data[index];
                      return AssignedTicketCard(
                        data: ticket.ticketInfo,
                        assignId: ticket.intId,
                      );
                    },
                    childCount: assignedController.data.length,
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              GetBuilder<AcceptedTicketHomeController>(
                builder: (_) {
                  final count = acceptedController.data
                      .where((t) => t.ticketInfo.intServiceRecordID != 0)
                      .length;

                  return _sectionTitle(
                    "In Progress",
                    count,
                    color: Colors.blueAccent,
                    isOpen: acceptedController.showInProgress,
                  );
                },
              ),

              Obx(() {
                if (!acceptedController.showInProgress.value) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                if (acceptedController.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: AcceptedTicketShimmer(),
                    ),
                  );
                }

                final inProgressTickets = acceptedController.data
                    .where((t) => t.ticketInfo.intServiceRecordID != 0)
                    .toList();

                if (inProgressTickets.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text("No tickets in progress.")),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return AcceptedTicketHomeCard(
                        data: inProgressTickets[index],
                      );
                    },
                    childCount: inProgressTickets.length,
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              /// =========================
              /// 🟢 ACCEPTED TICKETS
              /// =========================
              GetBuilder<AcceptedTicketHomeController>(
                builder: (_) {
                  final count = acceptedController.data
                      .where((t) => t.ticketInfo.intServiceRecordID == 0)
                      .length;

                  return _sectionTitle(
                    "Accepted Tickets",
                    count,
                    color: Colors.green,
                    isOpen: acceptedController.showAccepted,
                  );
                },
              ),

              Obx(() {
                if (!acceptedController.showAccepted.value) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                if (acceptedController.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: AcceptedTicketShimmer(),
                    ),
                  );
                }

                final acceptedTickets = acceptedController.data
                    .where((t) => t.ticketInfo.intServiceRecordID == 0)
                    .toList();

                if (acceptedTickets.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text("No accepted tickets available."),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return AcceptedTicketHomeCard(
                        data: acceptedTickets[index],
                      );
                    },
                    childCount: acceptedTickets.length,
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionTitle(
    String title,
    int count, {
    required Color color,
    required RxBool isOpen,
  }) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () {
          isOpen.value = !isOpen.value;
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 18, right: 6, left: 6),
          child: Row(
            children: [
              // 🔹 Colored indicator (no change – UI color)
              Container(
                width: 6,
                height: 26,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(width: 10),

              // 🔹 Section title
              Expanded(child: Text(title, style: themed(context, bold18))),

              // 🔹 Counter badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  // ✅ changed: use shared style, keep functional color
                  style: semibold12.copyWith(color: color),
                ),
              ),

              const SizedBox(width: 10),

              // 🔹 Expand / Collapse arrow
              Obx(() {
                return AnimatedRotation(
                  turns: isOpen.value ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    // ✅ changed: icon color from theme instead of Colors.black87
                    color: Theme.of(context).iconTheme.color,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class AcceptedTicketShimmer extends StatelessWidget {
  const AcceptedTicketShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ changed: get theme & brightness once
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ changed: base shimmer colors depending on theme
    final baseColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final surfaceColor = isDark ? Colors.grey.shade800 : Colors.white;
    final borderColor = isDark ? Colors.grey.shade600 : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(milliseconds: 500),
        // ✅ changed: shimmer color adapts to theme
        color: baseColor,
        colorOpacity: 0.4,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          decoration: BoxDecoration(
            // ✅ changed: container background uses theme-aware color
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              // ✅ changed: border adapts to dark/light
              color: borderColor.withValues(alpha: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      // ✅ changed: avatar shimmer color
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 100,
                          // ✅ changed
                          color: baseColor,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 20,
                          width: 140,
                          decoration: BoxDecoration(
                            // ✅ changed
                            color: baseColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Info Rows (5 dummy rows)
              ...List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  height: 42,
                  decoration: BoxDecoration(
                    // ✅ changed
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      // ✅ changed
                      color: borderColor.withValues(alpha: 0.4),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ✅ changed: divider color from theme
              Divider(thickness: 0.8, color: Theme.of(context).dividerColor),

              const SizedBox(height: 8),

              // 🔹 Action buttons (2)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        // ✅ changed
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        // ✅ changed
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssignedTicketShimmer extends StatelessWidget {
  const AssignedTicketShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ changed: detect current theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ changed: theme-aware shimmer colors
    final baseColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final surfaceColor = isDark ? Colors.grey.shade800 : Colors.white;
    final borderColor = isDark ? Colors.grey.shade600 : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(milliseconds: 500),
        // ✅ changed: shimmer color adapts to theme
        color: baseColor,
        colorOpacity: 0.4,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          decoration: BoxDecoration(
            // ✅ changed: background adapts to dark/light
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              // ✅ changed
              color: borderColor.withValues(alpha: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      // ✅ changed
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 120,
                          // ✅ changed
                          color: baseColor,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 100,
                          // ✅ changed
                          color: baseColor,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      // ✅ changed
                      color: baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Buttons Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        // ✅ changed
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        // ✅ changed
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

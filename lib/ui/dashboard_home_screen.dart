import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:ticket_app/ui/login_screen.dart';
import '../utils/color_app.dart';
import '../controller/accepted_tickets_controller.dart';
import '../controller/assigned_tickets_controller.dart';
import 'dashboard/widgets/accepted_ticket_card.dart';
import 'dashboard/widgets/assigned_ticket_card.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final assignedController = Get.put(AssignedTicketController());
  final acceptedController = Get.put(AcceptedTicketController());

  @override
  void initState() {
    super.initState();
    assignedController.fetchAssignedTickets();
    acceptedController.fetchAcceptedTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              mySharedPreferences.clearProfile();
              Get.offAll(() => LoginScreen());
            },
            icon: Icon(Icons.login),
          ),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              GetBuilder<AssignedTicketController>(
                builder: (logic) {
                  final assignedCount = assignedController.data.length;

                  return _sectionTitle(
                    "Assigned Tickets",
                    assignedCount,
                    color: Colors.orange,
                    isOpen: assignedController.showAssigned,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  final isOpen = assignedController.showAssigned.value;

                  Widget content;

                  if (assignedController.isLoading.value) {
                    content = const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: AssignedTicketShimmer(),
                    );
                  } else if (assignedController.data.isEmpty) {
                    content = const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text("No assigned tickets.")),
                    );
                  } else {
                    content = Column(
                      children: assignedController.data.map((ticket) {
                        return AssignedTicketCard(
                          data: ticket.ticketInfo,
                          assignId: ticket.intId,
                        );
                      }).toList(),
                    );
                  }

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      opacity: isOpen ? 1 : 0,
                      child: isOpen ? content : const SizedBox.shrink(),
                    ),
                  );
                }),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ✅ قسم IN PROGRESS
              GetBuilder<AcceptedTicketController>(
                builder: (logic) {
                  final inProgressCount = acceptedController.data
                      .where((t) => t.ticketInfo.intServiceRecordID != 0)
                      .length;

                  return _sectionTitle(
                    "In Progress",
                    inProgressCount,
                    color: Colors.blueAccent,
                    isOpen: acceptedController.showInProgress,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  final isOpen = acceptedController.showInProgress.value;

                  Widget content;

                  if (acceptedController.isLoading.value) {
                    content = const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: AcceptedTicketShimmer(),
                    );
                  } else {
                    final inProgressTickets = acceptedController.data
                        .where((t) => t.ticketInfo.intServiceRecordID != 0)
                        .toList();

                    if (inProgressTickets.isEmpty) {
                      content = const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text("No tickets in progress.")),
                      );
                    } else {
                      content = Column(
                        children: inProgressTickets.map((ticket) {
                          return AcceptedTicketCard(data: ticket);
                        }).toList(),
                      );
                    }
                  }

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      opacity: isOpen ? 1 : 0,
                      child: isOpen ? content : const SizedBox.shrink(),
                    ),
                  );
                }),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              GetBuilder<AcceptedTicketController>(
                builder: (logic) {
                  final acceptedCount = acceptedController.data
                      .where((t) => t.ticketInfo.intServiceRecordID == 0)
                      .length;

                  return _sectionTitle(
                    "Accepted Tickets",
                    acceptedCount,
                    color: Colors.green,
                    isOpen: acceptedController.showAccepted,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  final isOpen = acceptedController.showAccepted.value;

                  Widget content;

                  if (acceptedController.isLoading.value) {
                    content = const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: AcceptedTicketShimmer(),
                    );
                  } else {
                    final acceptedTickets = acceptedController.data
                        .where((t) => t.ticketInfo.intServiceRecordID == 0)
                        .toList();

                    if (acceptedTickets.isEmpty) {
                      content = const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text("No accepted tickets available."),
                        ),
                      );
                    } else {
                      content = Column(
                        children: acceptedTickets.map((ticket) {
                          return AcceptedTicketCard(data: ticket);
                        }).toList(),
                      );
                    }
                  }

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      opacity: isOpen ? 1 : 0,
                      child: isOpen ? content : const SizedBox.shrink(),
                    ),
                  );
                }),
              ),

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
          isOpen.value = !isOpen.value; // بدون setState
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 18, right: 6, left: 6),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 26,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,

                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // العداد
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
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Obx(() {
                return AnimatedRotation(
                  turns: isOpen.value ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black87,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(milliseconds: 500),
        color: Colors.grey.shade300,
        colorOpacity: 0.4,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300.withValues(alpha: 0.5),
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
                      color: Colors.grey.shade300,
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
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 20,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 Info Rows (5 أسطر وهمية)
              ...List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300.withValues(alpha: 0.4),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Divider(thickness: 0.8, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 8),

              // 🔹 Action buttons (2)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 42,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(milliseconds: 500),
        color: Colors.grey.shade300,
        colorOpacity: 0.4,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300.withValues(alpha: 0.5),
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
                      color: Colors.grey.shade300,
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
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 100,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
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

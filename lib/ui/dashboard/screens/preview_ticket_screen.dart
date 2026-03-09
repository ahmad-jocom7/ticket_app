import 'package:flutter/material.dart';
import '../../../utils/color_app.dart';
import '../../../model/service_record/assign_ticket_model.dart';

class PreviewTicketScreen extends StatelessWidget {
  final LstTicket data;

  const PreviewTicketScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Preview Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? []
                : [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Header ----------------
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: ColorApp.primary.withValues(
                      alpha: isDark ? 0.25 : 0.12,
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: ColorApp.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ticket No. (${data.intTicketId})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: theme.dividerColor),

              // ---------------- Fields ----------------
              _readOnlyField(
                context,
                label: 'Ticket Type',
                icon: Icons.confirmation_number_outlined,
                value: data.ticketInfo.strTicketType,
              ),
              _readOnlyField(
                context,
                label: 'Customer Name',
                icon: Icons.person_outline,
                value: data.ticketInfo.strCustomerName,
              ),
              _readOnlyField(
                context,
                label: 'Caller Name',
                icon: Icons.phone_outlined,
                value: data.ticketInfo.strCallerName,
              ),
              _readOnlyField(
                context,
                label: 'Sub Product Name',
                icon: Icons.widgets_outlined,
                value: data.ticketInfo.strSubProductName,
              ),
              _readOnlyField(
                context,
                label: 'Device Ref. No.',
                icon: Icons.devices_outlined,
                value: data.ticketInfo.strCustomerRefNo,
              ),

              const SizedBox(height: 20),

              _readOnlyField(
                context,
                label: 'Area',
                icon: Icons.map_outlined,
                value: data.ticketInfo.strArea,
              ),
              _readOnlyField(
                context,
                label: 'Sub Area',
                icon: Icons.location_city_outlined,
                value: data.ticketInfo.strSubArea,
              ),
              _readOnlyField(
                context,
                label: 'S/N',
                icon: Icons.numbers_outlined,
                value: data.ticketInfo.strSerialNo,
              ),

              const SizedBox(height: 20),

              _readOnlyField(
                context,
                label: 'Fault',
                icon: Icons.error_outline,
                value: data.ticketInfo.strFault,
              ),
              _readOnlyField(
                context,
                label: 'Fault Note',
                icon: Icons.sticky_note_2_outlined,
                value: data.ticketInfo.strFaultNote,
              ),
              _readOnlyField(
                context,
                label: 'Note',
                icon: Icons.note_alt_outlined,
                value: data.ticketInfo.strNots,
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Read Only Field ----------------
  Widget _readOnlyField(
      BuildContext context, {
        required String label,
        required IconData icon,
        required String value,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        readOnly: true,
        initialValue: value.isEmpty ? "—" : value,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodySmall,
          prefixIcon: Icon(icon, color: ColorApp.primary),
          filled: true,
          fillColor: isDark
              ? theme.colorScheme.surface
              : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorApp.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

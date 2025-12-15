import 'package:flutter/material.dart';
import '../../../utils/color_app.dart';
import '../../../model/service_record/assign_ticket_model.dart'; // أو Controller خاص للعرض إن وجد

class PreviewTicketScreen extends StatelessWidget {
  final LstTicket data;

  const PreviewTicketScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: const Text('Preview Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(
                      Icons.receipt_long,
                      color: ColorApp.primary,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ticket No. (${data.intTicketId})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),

              // Ticket Type
              _readOnlyField(
                label: 'Ticket Type',
                icon: Icons.confirmation_number_outlined,
                value: data.ticketInfo.strTicketType,
              ),

              // Customer
              _readOnlyField(
                label: 'Customer Name',
                icon: Icons.person_outline,
                value: data.ticketInfo.strCustomerName,
              ),

              // Caller Name
              _readOnlyField(
                label: 'Caller Name',
                icon: Icons.phone_outlined,
                value: data.ticketInfo.strCallerName,
              ),

              // Received By
              // _readOnlyField(
              //   label: 'Received By',
              //   icon: Icons.mail_outline,
              //   value: "",
              // ),

              // Sub Product
              _readOnlyField(
                label: 'Sub Product Name',
                icon: Icons.widgets_outlined,
                value: data.ticketInfo.strSubProductName,
              ),

              // Device Ref
              _readOnlyField(
                label: 'Device Ref. No.',
                icon: Icons.devices_outlined,
                value: data.ticketInfo.strCustomerRefNo,
              ),
              const SizedBox(height: 20),
              // const Text(
              //   "Sub Product Location",
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Color(0xFF1565C0),
              //   ),
              // ),
              // const SizedBox(height: 10),

              // Area
              _readOnlyField(
                label: 'Area',
                icon: Icons.map_outlined,
                value: data.ticketInfo.strArea,
              ),

              // Sub Area
              _readOnlyField(
                label: 'Sub Area',
                icon: Icons.location_city_outlined,
                value: data.ticketInfo.strSubArea,
              ),

              // Zone
              // _readOnlyField(
              //   label: 'Zone',
              //   icon: Icons.place_outlined,
              //   value: "",
              // ),

              // Serial
              _readOnlyField(
                label: 'S/N',
                icon: Icons.numbers_outlined,
                value: data.ticketInfo.strSerialNo,
              ),
              const SizedBox(height: 20),

              // Fault
              _readOnlyField(
                label: 'Fault',
                icon: Icons.error_outline,
                value: data.ticketInfo.strFault,
              ),

              // Fault Note
              _readOnlyField(
                label: 'Fault Note',
                icon: Icons.sticky_note_2_outlined,
                value: data.ticketInfo.strFaultNote,
              ),

              // Note
              _readOnlyField(
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

  Widget _readOnlyField({
    required String label,
    required IconData icon,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        readOnly: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorApp.primary),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorApp.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

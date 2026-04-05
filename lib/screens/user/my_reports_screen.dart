import 'package:flutter/material.dart';
import '../../models/report_record.dart';
import '../../widgets/user_my_report_card.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  // ── Icon helpers ─────────────────────────────────────────────────────────────
  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'flood':
        return Icons.water_drop;
      case 'emergency':
        return Icons.emergency;
      case 'medical':
        return Icons.medical_services;
      case 'other':
        return Icons.report_sharp;
      default:
        return Icons.info_outline;
    }
  }

  Color _iconColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orange;
      case 'flood':
        return Colors.blue;
      case 'emergency':
        return Colors.red;
      case 'medical':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _iconBgForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFFF3E0);
      case 'flood':
        return const Color(0xFFE3F2FD);
      case 'emergency':
        return const Color(0xFFFFEBEE);
      case 'medical':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.grey;
      case 'IN PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Normalise legacy "ACKNOWLEDGED" → "IN PROGRESS"
  String _normalizeStatus(String status) {
    if (status.toUpperCase() == 'ACKNOWLEDGED') return 'IN PROGRESS';
    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Sample data — swap for a real provider / Firestore stream later
    // final ongoingReports = [
    //   const ReportRecord(
    //     incidentId: '#2024-10536',
    //     reportType: 'FIRE',
    //     barangay: 'Brgy. Sample',
    //     time: '2:30 PM',
    //     status: 'PENDING',
    //   ),
    //   const ReportRecord(
    //     incidentId: '#2024-10537',
    //     reportType: 'FLOOD',
    //     barangay: 'Brgy. Sample',
    //     time: '3:15 PM',
    //     status: 'IN PROGRESS',
    //   ),
    // ];

    // final resolvedReports = [
    //   const ReportRecord(
    //     incidentId: '#2024-10501',
    //     reportType: 'FIRE',
    //     barangay: 'Brgy. Sample',
    //     time: '1:10 PM',
    //     status: 'RESOLVED',
    //   ),
    // ];

    return const Center(
      child: Text("Testing Firestore..."),
    );
  }
}

// ── Section wrapper ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          ...children,
        ],
      ),
    );
  }
}

// ── Individual report card ─────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final ReportRecord record;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color statusColor;
  final String normalizedStatus;

  const _ReportCard({
    required this.record,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.statusColor,
    required this.normalizedStatus,
  });

  @override
  Widget build(BuildContext context) {
    final displayType =
        '${record.reportType[0]}${record.reportType.substring(1).toLowerCase()} Alert';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.barangay,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${record.incidentId}  ·  ${record.time}',
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: statusColor, width: 1.4),
              borderRadius: BorderRadius.circular(6),
              color: statusColor.withOpacity(0.07),
            ),
            child: Text(
              normalizedStatus,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
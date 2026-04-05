import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('incidents').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong while loading reports.'),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final allReports = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ReportRecord.fromMap(data, doc.id);
        }).toList();

        final ongoingReports = allReports.where((report) {
          final status = _normalizeStatus(report.status);
          return status == 'PENDING' || status == 'IN PROGRESS';
        }).toList();

        final resolvedReports = allReports.where((report) {
          final status = _normalizeStatus(report.status);
          return status == 'RESOLVED';
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Reports',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),



              _SectionCard(
                title: 'Ongoing Reports',
                children: ongoingReports.isEmpty
                    ? [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No ongoing reports yet.'),
                  ),
                ]
                    : ongoingReports.map((r) {
                  return UserMyReportCard(
                    record: r,     //make one UserReportCard per report
                    icon: _iconForType(r.reportType),
                    iconColor: _iconColorForType(r.reportType),
                    statusColor:
                    _statusColor(_normalizeStatus(r.status)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Resolved Reports',
                children: resolvedReports.isEmpty
                    ? [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No resolved reports yet.'),
                  ),
                ]
                    : resolvedReports.map((r) {
                  return UserMyReportCard(
                    record: r,    //make one UserReportCard per report
                    icon: _iconForType(r.reportType),
                    iconColor: _iconColorForType(r.reportType),
                    statusColor:
                    _statusColor(_normalizeStatus(r.status)),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
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
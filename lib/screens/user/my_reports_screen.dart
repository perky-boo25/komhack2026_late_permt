import 'dart:async';
import 'dart:math';
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
      case 'other':
        return Colors.black;
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

  // Normalise legacy variants → canonical values
  String _normalizeStatus(String status) {
    final s = status.toUpperCase();
    if (s == 'ACKNOWLEDGED' || s == 'IN_PROGRESS') return 'IN PROGRESS';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('incidents')
          .orderBy('createdAt', descending: true)
          .snapshots(),      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error in loading reports.'),
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
                    child: Text('Nothing to show here.'),
                  ),
                ]
                    : ongoingReports.map((r) {
                  return GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => _ReportDetailDialog(record: r),
                    ),
                    child: UserMyReportCard(
                      record: r,
                      icon: _iconForType(r.reportType),
                      iconColor: _iconColorForType(r.reportType),
                      statusColor:
                      _statusColor(_normalizeStatus(r.status)),
                    ),
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
                  return GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => _ReportDetailDialog(record: r),
                    ),
                    child: UserMyReportCard(
                      record: r,
                      icon: _iconForType(r.reportType),
                      iconColor: _iconColorForType(r.reportType),
                      statusColor:
                      _statusColor(_normalizeStatus(r.status)),
                    ),
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
// ── Report Detail Dialog ───────────────────────────────────────────────────────

class _ReportDetailDialog extends StatefulWidget {
  final ReportRecord record;
  const _ReportDetailDialog({required this.record});

  @override
  State<_ReportDetailDialog> createState() => _ReportDetailDialogState();
}

class _ReportDetailDialogState extends State<_ReportDetailDialog> {

  StreamSubscription<DocumentSnapshot>? _sub;

  String       _status        = '';
  String       _sentTime      = '';
  String       _specification = '';
  String       _description   = '';

  @override
  void initState() {
    super.initState();
    _status        = widget.record.status.toUpperCase();
    _sentTime      = widget.record.time;
    _specification = widget.record.specification;
    _description   = widget.record.description;

    _sub = FirebaseFirestore.instance
        .collection('incidents')
        .doc(widget.record.incidentId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final data = snap.data()!;
      setState(() {
        _status        = (data['status']        as String? ?? _status).toUpperCase();
        _sentTime      =  data['time']          as String? ?? _sentTime;
        _specification =  data['specification'] as String? ?? '';
        _description   =  data['description']  as String? ?? '';
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String get _normalizedStatus {
    if (_status == 'ACKNOWLEDGED' || _status == 'IN_PROGRESS' || _status == 'IN PROGRESS') return 'IN PROGRESS';
    return _status;
  }

  bool get _isActive =>
      _normalizedStatus == 'IN PROGRESS' || _normalizedStatus == 'RESOLVED';

  bool get _isResolved => _normalizedStatus == 'RESOLVED';

  Color get _statusDotColor {
    switch (_normalizedStatus) {
      case 'IN PROGRESS': return Colors.orange;
      case 'RESOLVED':    return Colors.green;
      default:            return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (_normalizedStatus) {
      case 'IN PROGRESS': return 'Na-assign na ang responder';
      case 'RESOLVED':    return 'Natugunan';
      default:            return 'Naghihintay ng kumpirmasyon';
    }
  }

  Color get _bgColor {
    if (_isResolved)  return const Color(0xFFF0FFF4); // light green tint
    if (_isActive)    return const Color(0xFFFFFBF0); // light amber tint
    return const Color(0xFFFFF0F0);                   // default red tint
  }

  Color get _accentColor {
    if (_isResolved) return Colors.green;
    if (_isActive)   return Colors.orange;
    return Colors.red;
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':      return Icons.local_fire_department;
      case 'flood':     return Icons.water_drop;
      case 'emergency': return Icons.emergency;
      case 'medical':   return Icons.medical_services;
      case 'other':     return Icons.report_sharp;
      default:          return Icons.info_outline;
    }
  }

  Color _iconColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':      return Colors.orange;
      case 'flood':     return Colors.blue;
      case 'emergency': return Colors.red;
      case 'medical':   return Colors.green;
      case 'other':     return Colors.black;
      default:          return Colors.grey;
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.record.reportType;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Type icon circle
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: _iconColorForType(type).withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _iconColorForType(type), width: 2),
                ),
                child: Icon(
                  _iconForType(type),
                  color: _iconColorForType(type),
                  size: 44,
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                type.toUpperCase(),
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4),
              ),
              const SizedBox(height: 4),
              Text(
                widget.record.barangay.isNotEmpty
                    ? widget.record.barangay
                    : 'Unknown location',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 14),

              // Status card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isActive
                        ? _accentColor
                        : const Color(0xFFEEEEEE),
                    width: 1.4,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Status dot + label
                    Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusDotColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: _statusDotColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_sentTime.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Oras naisumite: $_sentTime',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],

                    const SizedBox(height: 4),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Report details section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detalye ng Report',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              _row('ID ng insidente',
                  '#${widget.record.incidentId.substring(0, min(10, widget.record.incidentId.length))}'),
              _row('Uri ng Emergency', type),
              _row('Status', _normalizedStatus),
              _row('Espesipikasyon',
                  _specification.isNotEmpty ? _specification : '–'),
              _row('Deskripsyon',
                  _description.isNotEmpty ? _description : '–'),

              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'I-CLOSE',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
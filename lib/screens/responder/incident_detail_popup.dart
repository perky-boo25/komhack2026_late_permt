// ignore_for_file: unused_element, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'alert_data.dart';
import 'responder_shell.dart'; // gives access to AppState

// ── IncidentDetailPopup ───────────────────────────────────────────────────────
//
// Dialog wrapper used by HomeTab's showDialog call.
// Accepts lat/lng/location/time/description/specification so all sections
// show real data from alert_data.dart.

class IncidentDetailPopup extends StatelessWidget {
  final String alertId;
  final DateTime? alertDate;
  final String alertType;
  final double alertLat;
  final double alertLng;
  final String alertLocation;
  final String alertTime;
  final String? alertDescription;
  final String? alertSpecification;
  final bool isAlreadyAssigned;
  final bool isInProgress;
  final bool isResolved;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncidentDetailPopup({
    super.key,
    required this.alertId,
    this.alertDate,
    required this.alertType,
    required this.alertLat,
    required this.alertLng,
    required this.alertLocation,
    required this.alertTime,
    this.alertDescription,
    this.alertSpecification,
    required this.isAlreadyAssigned,
    required this.isInProgress,
    this.isResolved = false,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: IncidentDetailScreen(
          alertId: alertId,
          alertDate: alertDate,
          alertType: alertType,
          alertLat: alertLat,
          alertLng: alertLng,
          alertLocation: alertLocation,
          alertTime: alertTime,
          alertDescription: alertDescription,
          alertSpecification: alertSpecification,
          isAccepted: isInProgress,
          isResolved: isResolved,
          embeddedMode: true,
          onAccept: onAccept,
          onDecline: onDecline,
        ),
      ),
    );
  }
}

// ── IncidentDetailScreen ──────────────────────────────────────────────────────
//
// Two modes:
//   • Full page  (embeddedMode: false) — pushed via Navigator
//   • Embedded   (embeddedMode: true)  — inside a Dialog / Alerts tab

class IncidentDetailScreen extends StatefulWidget {
  final String alertId;
  final DateTime? alertDate;
  final String alertType;
  final double alertLat;
  final double alertLng;
  final String alertLocation;
  final String alertTime;
  final String? alertDescription;
  final String? alertSpecification;
  final bool isAccepted;
  final bool isResolved;
  final bool embeddedMode;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const IncidentDetailScreen({
    super.key,
    required this.alertId,
    this.alertDate,
    required this.alertType,
    required this.alertLat,
    required this.alertLng,
    required this.alertLocation,
    required this.alertTime,
    this.alertDescription,
    this.alertSpecification,
    required this.isAccepted,
    this.isResolved = false,
    this.embeddedMode = false,
    this.onAccept,
    this.onDecline,
  });

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  // Fetched from Firestore — same pattern as ProfileTab
  String _initials   = '';
  String _unit       = '';
  String _department = '';

  @override
  void initState() {
    super.initState();
    _loadResponderInfo();
  }

  /// Queries `responders` collection by the logged-in user's UID,
  /// exactly the same way ProfileTab does.
  Future<void> _loadResponderInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('responders')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (!mounted || query.docs.isEmpty) return;

    final data = query.docs.first.data();
    final name       = (data['name']        as String? ?? '').trim();
    final unit       = (data['responderId'] as String? ?? '').trim();
    final department = (data['department']  as String? ?? '').trim();

    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts.isNotEmpty
            ? parts[0][0].toUpperCase()
            : '?';

    setState(() {
      _initials   = initials;
      _unit       = unit;
      _department = department;
    });
  }

  // ── Type helpers ─────────────────────────────────────────────────────────────

  IconData get _icon {
    switch (widget.alertType) {
      case 'fire':      return Icons.local_fire_department;
      case 'flood':     return Icons.water_drop;
      case 'emergency': return Icons.emergency;
      case 'medical':   return Icons.medical_services;
      default:          return Icons.info_outline;
    }
  }

  Color get _color {
    switch (widget.alertType) {
      case 'fire':      return Colors.orange;
      case 'flood':     return Colors.blue;
      case 'emergency': return Colors.red;
      case 'medical':   return Colors.green;
      default:          return Colors.grey;
    }
  }

  String get _title {
    switch (widget.alertType) {
      case 'fire':      return 'Fire Alert';
      case 'flood':     return 'Flood Alert';
      case 'emergency': return 'Emergency Alert';
      case 'medical':   return 'Medical Alert';
      default:          return 'Alert';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) =>
      widget.embeddedMode ? _buildContent(context) : _buildAsPage(context);

  Widget _buildAsPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: 200,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.black87),
          label: const Text(
            '<- Back to Dashboard',
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F9),
      child: Column(
        children: [
          _buildHeaderBanner(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMiniMap(),
                  if (widget.isAccepted && !widget.isResolved) _buildTabBar(),
                  _buildDetailsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // ── Header banner ─────────────────────────────────────────────────────────────

  Widget _buildHeaderBanner() {
    final Color bg;
    final Color textColor;
    final Color subColor;
    final Color iconBg;
    final Color iconColor;

    if (widget.isResolved) {
      bg        = Colors.grey.shade100;
      textColor = Colors.black54;
      subColor  = Colors.black38;
      iconBg    = Colors.grey.shade200;
      iconColor = Colors.grey;
    } else if (widget.isAccepted) {
      bg        = _color;
      textColor = Colors.white;
      subColor  = Colors.white70;
      iconBg    = Colors.white.withValues(alpha:0.25);
      iconColor = Colors.white;
    } else {
      bg        = Colors.white;
      textColor = Colors.black87;
      subColor  = Colors.black45;
      iconBg    = _color.withValues(alpha:0.12);
      iconColor = _color;
    }

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(_icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                Text(
                  '${widget.alertLocation} • ${widget.alertTime}',
                  style: TextStyle(fontSize: 12, color: subColor),
                ),
              ],
            ),
          ),
          if (widget.isResolved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Text(
                'Resolved',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            )
          else if (widget.isAccepted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white54),
              ),
              child: const Text(
                'In Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Mini map (real OSM, centred on this alert) ────────────────────────────────

  Widget _buildMiniMap() {
    final alertPoint = LatLng(widget.alertLat, widget.alertLng);

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          IgnorePointer(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: alertPoint,
                initialZoom: 15.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.responder_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: alertPoint,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(_icon, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.alertLat.toStringAsFixed(4)}, ${widget.alertLng.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
        ],
      ),
    );
  }

  Widget _tab(String label, {required bool active}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: active
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1A1A2E), width: 2),
                ),
              )
            : null,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFF1A1A2E) : Colors.black38,
          ),
        ),
      ),
    );
  }

  // ── Details section ───────────────────────────────────────────────────────────

  Widget _buildDetailsSection() {
    final String specValue =
        (widget.alertSpecification != null && widget.alertSpecification!.isNotEmpty)
            ? widget.alertSpecification!
            : '–';

    final String descriptionText =
        (widget.alertDescription != null && widget.alertDescription!.isNotEmpty)
            ? widget.alertDescription!
            : 'Walang detalyeng binigay.';

    // Use the responder info fetched from Firestore in initState
    final String responderLabel =
        [_unit, _department].where((s) => s.isNotEmpty).join(' • ');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalye ng Insidente',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _detailRow('ID ng insidente', widget.alertId),
          _detailRow('Petsa', formatDate(widget.alertDate)),
          _detailRow('Uri ng Emergency', _title),
          _detailRow('Oras naisumite', widget.alertTime),
          _detailRow(
              'Coordinates',
              '${widget.alertLat.toStringAsFixed(4)}, ${widget.alertLng.toStringAsFixed(4)}'),
          _detailRow('Espesipakasyon', specValue),
          const SizedBox(height: 12),

          // Description box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Deskripsyon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  descriptionText,
                  style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Responder/s assigned box ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Na-assign na Responder:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                if (widget.isAccepted || widget.isResolved)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _initials.isNotEmpty ? _initials : '?',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          responderLabel.isNotEmpty
                              ? responderLabel
                              : 'Responder na-assigned',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'WALA PANG NA-ASSIGN',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context) {
    // Resolved → just a close button, no actions
    if (widget.isResolved) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () =>
                widget.embeddedMode ? widget.onDecline?.call() : Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ),
        ),
      );
    }

    if (widget.isAccepted) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    widget.embeddedMode ? widget.onDecline?.call() : Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Tanggihan',
                  style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline,
                        color: Colors.grey.shade400, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      widget.isAlreadyAssigned
                          ? 'May Aktibong Alert'
                          : 'Already Assigned',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  widget.embeddedMode ? widget.onDecline?.call() : Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Tanggihan',
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () =>
                  widget.embeddedMode ? widget.onAccept?.call() : Navigator.pop(context),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Tugunan',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
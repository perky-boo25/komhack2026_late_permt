// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'incident_detail_popup.dart';
import 'responder_shell.dart';
import 'alert_data.dart';



class HomeTab extends StatefulWidget {
  final void Function(int) onSwitchTab;

  const HomeTab({super.key, required this.onSwitchTab});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Pull from shared sources so MapTab and HomeTab stay in sync.
  // Replace with Firebase streams later — keep the same map shape.
  List<Map<String, dynamic>> get _activeAlerts {
    final list = sharedAlerts.where((a) => a['status'] != 'resolved').toList();
    list.sort((a, b) {
      // 'respond' floats to the top, 'inProgress' sinks below
      final aScore = a['status'] == 'respond' ? 0 : 1;
      final bScore = b['status'] == 'respond' ? 0 : 1;
      return aScore.compareTo(bScore);
    });
    return list;
  }


  List<Map<String, dynamic>> get _resolved => resolvedAlerts;

  // Bounding centre of Santa Barbara, Iloilo
  static const LatLng _mapCenter = LatLng(10.8310, 122.5290);
  
  // ── Getters ──────────────────────────────────────────────────────────────────

  int get _respondCount =>
      _activeAlerts.where((a) => a['status'] == 'respond').length;

  int get _inProgressCount =>
      _activeAlerts.where((a) => a['status'] == 'inProgress').length;

  // ── Helpers ──────────────────────────────────────────────────────────────────

  IconData _iconForType(String type) {
    switch (type) {
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

  Color _colorForType(String type) {
    switch (type) {
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

  // ── Show pop-up (active alerts) ───────────────────────────────────────────────

  void _showIncidentPopup(BuildContext context, Map<String, dynamic> alert) {
    final bool alreadyAssigned = AppState.assignedAlert != null;
    final bool isInProgress = alert['status'] == 'inProgress';

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => IncidentDetailPopup(
        alertType: alert['type'] as String,
        alertLat: alert['lat'] as double,
        alertLng: alert['lng'] as double,
        alertLocation: alert['location'] as String,
        alertTime: alert['time'] as String? ?? '–',
        alertDescription: alert['description'] as String?,
        alertSpecification: alert['specification'] as String?,
        isAlreadyAssigned: alreadyAssigned,
        isInProgress: isInProgress,
        isResolved: false,
        onAccept: () {
          setState(() {
            AppState.assignedAlert = alert;
            alert['status'] = 'inProgress';
          });
          Navigator.of(context).pop();
          widget.onSwitchTab(1);
        },
        onDecline: () => Navigator.of(context).pop(),
      ),
    );
  }

  // ── Show pop-up (resolved — view only) ───────────────────────────────────────

  void _showResolvedPopup(BuildContext context, Map<String, dynamic> alert) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => IncidentDetailPopup(
        alertType: alert['type'] as String,
        alertLat: alert['lat'] as double,
        alertLng: alert['lng'] as double,
        alertLocation: alert['location'] as String,
        alertTime: alert['time'] as String? ?? '–',
        alertDescription: alert['description'] as String?,
        alertSpecification: alert['specification'] as String?,
        isAlreadyAssigned: false,
        isInProgress: false,
        isResolved: true,
        onAccept: () {},
        onDecline: () => Navigator.of(context).pop(),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────


  // @override
  // void initState() {
  //   super.initState();
  //   _getUserRole();
  // }

//to get current logged in user's role:
  // void _getUserRole() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final doc = await FirebaseFirestore.instance
  //         .collection('responders')
  //         .doc(user.uid)
  //         .get();
  //     if (mounted) {
  //       setState(() {
  //         _userRole = doc.data()?['role'] ?? 'responder';
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMapCard(context),
          _buildSummaryRow(),

          // ── Active Alerts ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Text(
              'Active Alerts (${_activeAlerts.length})',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (_activeAlerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'No active alerts at the moment.',
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
            )
          else
            ..._activeAlerts.map((a) => _buildAlertCard(context, a)),

          // ── Resolved Reports ─────────────────────────────────────────────
          if (_resolved.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 2),
              child: Divider(thickness: 1, color: Colors.black12),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Text(
                'Resolved Reports (${_resolved.length})',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._resolved.map((a) => _buildResolvedCard(context, a)),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Map Card (mini preview) ───────────────────────────────────────────────────

  Widget _buildMapCard(BuildContext context) {
    // Only show active (non-resolved) alerts on the map
    final markers = _activeAlerts.map((alert) {
      final color = _colorForType(alert['type'] as String);
      final icon = _iconForType(alert['type'] as String);
      return Marker(
        point: LatLng(alert['lat'] as double, alert['lng'] as double),
        width: 32,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 3, offset: Offset(0, 1))
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      );
    }).toList();

    return GestureDetector(
      onTap: () => widget.onSwitchTab(0),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Live map Santa Barbara',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Spacer(),
                  _statusBadge('$_respondCount Respond', Colors.red),
                  const SizedBox(width: 6),
                  _statusBadge(
                      '$_inProgressCount In progress', Colors.orange),
                ],
              ),
            ),
            // Mini map
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    IgnorePointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _mapCenter,
                          initialZoom: 13.8,
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
                          MarkerLayer(markers: markers),
                        ],
                      ),
                    ),
                    const Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(child: _ExpandHint()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  // ── Summary Row ───────────────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    int countByType(String type) =>
        _activeAlerts.where((a) => a['type'] == type).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _summaryCard('Emergency', '${countByType('emergency')}', Colors.red),
          const SizedBox(width: 10),
          _summaryCard('Fire', '${countByType('fire')}', Colors.orange),
          const SizedBox(width: 10),
          _summaryCard('Flood', '${countByType('flood')}', Colors.blue),
          const SizedBox(width: 10),
          _summaryCard('Medical', '${countByType('medical')}', Colors.green),
          const SizedBox(width: 10),
          _summaryCard('Other', '${countByType('other')}', Colors.black),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  // ── Active Alert Card ─────────────────────────────────────────────────────────

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> alert) {
    final String type = alert['type'] as String;
    final String status = alert['status'] as String;
    final icon = _iconForType(type);
    final color = _colorForType(type);

    return GestureDetector(
      onTap: () {
          _showIncidentPopup(context, alert);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert['location'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  alert['time'] as String? ?? '–',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black38),
                ),
                const SizedBox(height: 6),
                status == 'inProgress'
                    ? _inProgressBadge()
                    : _respondBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Resolved Report Card ──────────────────────────────────────────────────────

  Widget _buildResolvedCard(BuildContext context, Map<String, dynamic> alert) {
    return GestureDetector(
      onTap: () => _showResolvedPopup(context, alert),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert['location'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  alert['time'] as String? ?? '–',
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Text(
                    'Resolved',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _respondBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red),
        ),
        child: const Text(
          'Respond',
          style: TextStyle(
              color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );

  Widget _inProgressBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orange),
        ),
        child: const Text(
          'In Progress',
          style: TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      );
}

// ── Expand Hint ───────────────────────────────────────────────────────────────

class _ExpandHint extends StatelessWidget {
  const _ExpandHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Tap to expand map',
        style: TextStyle(fontSize: 11, color: Colors.black54),
      ),
    );
  }
}
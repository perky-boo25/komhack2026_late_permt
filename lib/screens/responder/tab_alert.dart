import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'responder_shell.dart';
import 'alert_data.dart';

/// Alert tab
/// • If the responder has an assigned alert → shows full incident detail view
/// • Otherwise → "No Alert Assigned" empty state
class AlertTab extends StatefulWidget {
  final void Function(int) onSwitchTab;
  

  const AlertTab({super.key, required this.onSwitchTab});


  @override
  State<AlertTab> createState() => _AlertTabState();
}

class _AlertTabState extends State<AlertTab> {
  @override
  Widget build(BuildContext context) {
    final assigned = AppState.assignedAlert;
    return assigned == null ? _buildEmpty() : _buildAssignedDetail(assigned);
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 48, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            'No Alert Assigned',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Assigned incident detail ──────────────────────────────────────────────

  Widget _buildAssignedDetail(Map<String, dynamic> alert) {
    return _AssignedIncidentView(
      alert: alert,
      alertType: alert['type'] as String,
      onResolve: () => _confirmResolve(alert),
    );
  }

  // ── Resolve confirmation dialog ───────────────────────────────────────────

  Future<void> _confirmResolve(Map<String, dynamic> alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
            SizedBox(width: 8),
            Text(
              'Mark as Resolved?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'Are you sure this incident has been fully resolved? '
          'This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'No, go back',
              style: TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Yes, resolve',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        // Mark resolved in-place — keep in sharedAlerts so HomeTab can
        // still open the popup from the Resolved Reports list.
        alert['status'] = 'resolved';
        alert['resolvedAt'] = TimeOfDay.now().format(context);
        if (!resolvedAlerts.contains(alert)) {
          resolvedAlerts.insert(0, alert);
        }
        AppState.assignedAlert = null;
      });
    }
  }
}

// ── Full assigned-incident view ───────────────────────────────────────────────

class _AssignedIncidentView extends StatelessWidget {
  final Map<String, dynamic> alert;
  final String alertType;
  final VoidCallback onResolve;

  const _AssignedIncidentView({
    required this.alert,
    required this.alertType,
    required this.onResolve,
  });

  // ── Type helpers ─────────────────────────────────────────────────────────

  IconData get _icon {
    switch (alertType) {
      case 'fire':      return Icons.local_fire_department;
      case 'flood':     return Icons.water_drop;
      case 'emergency': return Icons.emergency;
      case 'medical':   return Icons.medical_services;
      default:          return Icons.info_outline;
    }
  }

  Color get _color {
    switch (alertType) {
      case 'fire':      return Colors.orange;
      case 'flood':     return Colors.blue;
      case 'emergency': return Colors.red;
      case 'medical':   return Colors.green;
      default:          return Colors.grey;
    }
  }

  String get _title {
    switch (alertType) {
      case 'fire':      return 'Fire Alert';
      case 'flood':     return 'Flood Alert';
      case 'emergency': return 'Emergency Alert';
      case 'medical':   return 'Medical Alert';
      default:          return 'Alert';
    }
  }

  // ── Safe field reads ──────────────────────────────────────────────────────
  // 'time' is the new key; 'timeAgo' is the old key — fall back gracefully.

  String get _time {
    final t = alert['time'];
    if (t is String && t.isNotEmpty) return t;
    final ta = alert['timeAgo'];
    if (ta is String && ta.isNotEmpty) return ta;
    return '–';
  }

  String get _description {
    final d = alert['description'];
    if (d is String && d.isNotEmpty) return d;
    return 'No description provided.';
  }

  String get _specification {
    final s = alert['specification'];
    if (s is String && s.isNotEmpty) return s;
    return '–';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double lat = (alert['lat'] as num).toDouble();
    final double lng = (alert['lng'] as num).toDouble();
    final alertPoint = LatLng(lat, lng);

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${alert['location']} • $_time',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: const Text(
                  'In Progress',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable body ─────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Real OSM mini map ──────────────────────────────────────
                SizedBox(
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
                              userAgentPackageName:
                                  'com.example.responder_app',
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
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(_icon,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Coordinates label
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
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
                ),

                // ── Incident details ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Incident Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _detailRow('Incident ID',
                          alert['id'] as String? ?? '–'),
                      _detailRow('Emergency Type',
                          _title.replaceAll(' Alert', '')),
                      _detailRow('Time Reported', _time),
                      _detailRow('Specification', _specification),
                      const SizedBox(height: 12),

                      // ── Description box ────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 14,
                                    color: Colors.amber.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Description',
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
                              _description,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber.shade900),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Responder assigned box ─────────────────────────
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
                              'Responder/s assigned:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.green.shade300),
                                  ),
                                  child: Text(
                                    'UI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'UNIT 01 • Fire Truck dispatched',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom action bar ───────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // In Progress status bar (non-tappable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_run,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'In Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Mark as Resolved button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onResolve,
                  icon: const Icon(Icons.verified_outlined,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'Mark as Resolved',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
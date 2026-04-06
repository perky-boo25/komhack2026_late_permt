import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'alert_data.dart';

/// Full-screen live map tab powered by OpenStreetMap (flutter_map).
/// - Plots only active (non-resolved) incidents from Firestore.
/// - Tapping a marker opens a small bottom-sheet summary.
class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  // Centre of Santa Barbara, Iloilo — used as the fixed initial view
  static const LatLng _defaultCenter = LatLng(10.8272, 122.5314);

  // ── Helpers ──────────────────────────────────────────────────────────────────

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
      default:
        return Colors.black54;
    }
  }

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
      default:
        return Icons.report_sharp;
    }
  }

  // ── Markers ───────────────────────────────────────────────────────────────────

  List<Marker> _buildAlertMarkers(List<Map<String, dynamic>> alerts) {
    return alerts.map((alert) {
      final color = _colorForType(alert['type'] as String);
      final icon = _iconForType(alert['type'] as String);
      final point = LatLng(alert['lat'] as double, alert['lng'] as double);

      return Marker(
        point: point,
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () => _showAlertSheet(alert),
          child: Container(
            decoration: BoxDecoration(
              color: color,
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
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      );
    }).toList();
  }

  // ── Bottom sheet on marker tap ────────────────────────────────────────────────

  void _showAlertSheet(Map<String, dynamic> alert) {
    final color = _colorForType(alert['type'] as String);
    final icon = _iconForType(alert['type'] as String);
    final status = alert['status'] as String;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert['location'] as String,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${alert['lat']}, ${alert['lng']}',
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: status == 'inProgress'
                    ? Colors.orange.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: status == 'inProgress' ? Colors.orange : Colors.red,
                ),
              ),
              child: Text(
                status == 'inProgress' ? 'In Progress' : 'Respond',
                style: TextStyle(
                  color: status == 'inProgress' ? Colors.orange : Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  // Tracks the last centred alert id so we only move when a NEW alert arrives
  String? _lastCentredId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: activeAlertsStream(),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];
        final respondCount = alerts
            .where((a) => a['status'] == 'respond')
            .length;
        final inProgressCount = alerts
            .where((a) => a['status'] == 'inProgress')
            .length;

        // Centre on the most recent alert whenever it changes
        if (alerts.isNotEmpty) {
          final newest = alerts.first; // stream is sorted newest-first
          final newestId = newest['id'] as String?;
          if (newestId != null && newestId != _lastCentredId) {
            _lastCentredId = newestId;
            // Use addPostFrameCallback so the map is already laid out
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(
                LatLng(newest['lat'] as double, newest['lng'] as double),
                15.0,
              );
            });
          }
        }

        return Stack(
          children: [
            // ── OpenStreetMap ──────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 14.5,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.responder_app',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: _buildAlertMarkers(alerts)),
              ],
            ),

            // ── Header strip ───────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      'OpenStreetMap',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else ...[
                      _statusDot('$respondCount Respond', Colors.red),
                      const SizedBox(width: 10),
                      _statusDot('$inProgressCount In progress', Colors.orange),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statusDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'alert_data.dart';

/// Full-screen live map tab powered by OpenStreetMap (flutter_map).
/// - Plots only active (non-resolved) alerts from [sharedAlerts].
/// - Tapping a marker opens a small bottom-sheet summary.
/// - No GPS / device location is used.
class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  // Centre of Santa Barbara, Iloilo — used as the fixed initial view
  static const LatLng _defaultCenter = LatLng(10.8272, 122.5314);

  // Only show alerts that are NOT resolved on the map
  List<Map<String, dynamic>> get _visibleAlerts =>
      sharedAlerts.where((a) => a['status'] != 'resolved').toList();

  // ── Helpers ──────────────────────────────────────────────────────────────────

  int get _respondCount =>
      _visibleAlerts.where((a) => a['status'] == 'respond').length;

  int get _inProgressCount =>
      _visibleAlerts.where((a) => a['status'] == 'inProgress').length;

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

  /// Builds one marker per active alert using the lat/lng stored in [sharedAlerts].
  List<Marker> _buildAlertMarkers() {
    return _visibleAlerts.map((alert) {
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
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert['location'] as String,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${alert['lat']}, ${alert['lng']}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: status == 'inProgress'
                    ? Colors.orange.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      status == 'inProgress' ? Colors.orange : Colors.red,
                ),
              ),
              child: Text(
                status == 'inProgress' ? 'In Progress' : 'Respond',
                style: TextStyle(
                  color: status == 'inProgress'
                      ? Colors.orange
                      : Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── OpenStreetMap ────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: 14.5,
            interactionOptions:
                InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.responder_app',
              maxZoom: 19,
            ),
            MarkerLayer(markers: _buildAlertMarkers()),
          ],
        ),

        // ── Header strip ─────────────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Live map',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                _statusDot('$_respondCount Respond', Colors.red),
                const SizedBox(width: 10),
                _statusDot('$_inProgressCount In progress', Colors.orange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}
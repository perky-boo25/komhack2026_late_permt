import 'dart:convert';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';



class HomeScreen extends StatefulWidget {
  final ValueChanged<bool>? onGpsChanged;
  final ValueChanged<String>? onBarangayDetected;
  const HomeScreen({
    super.key,
    this.onGpsChanged,
    this.onBarangayDetected
    });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Location State ---
  LatLng? _currentLatLng;
  String _locationLabel = 'Detecting location...';
  String _streetLabel = '';
  bool _locationLoading = true;
  bool _locationError = false;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  // --- GEOLOCATION ---
  Future<void> _fetchLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = false;
      _locationLabel = 'Detecting location...';
      _streetLabel = '';
    });

    try {
      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
            //GPS is not active nor usable
            widget.onGpsChanged?.call(false);
        setState(() {
          _locationLoading = false;
          _locationError = true;
          _locationLabel = 'Location permission denied.';
        });
        return;
      }

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        //tell MainScreen that GPS is not active/usable
        widget.onGpsChanged?.call(false);

        setState(() {
          _locationLoading = false;
          _locationError = true;
          _locationLabel = 'Location services are disabled.';
        });
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latlng = LatLng(position.latitude, position.longitude);

      // Reverse geocode using Nominatim (OpenStreetMap)
      final address =
          await _reverseGeocode(position.latitude, position.longitude);

      setState(() {
        _currentLatLng = latlng;
        _locationLoading = false;
        _locationError = false;
        _locationLabel = address['barangay'] ?? 'Unknown Barangay';
        _streetLabel = address['street'] ?? '';
      });

      //GPS/locataion successfully worked, so chip can turn green
      widget.onGpsChanged?.call(true);

      //sends barangay to MainScreen so it can listen to Firestore safety
      final barangay = address['barangay'];
      if (barangay !=null && barangay.trim().isNotEmpty){
        widget.onBarangayDetected?.call(barangay);
      }

      // Move map to current position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(latlng, 16.0);
      });
    } catch (e) {
      //tell mainscreen that gps isn't active/usable if something went wrong
      widget.onGpsChanged?.call(false);
      setState(() {
        _locationLoading = false;
        _locationError = true;
        _locationLabel = 'Could not detect location.';
      });
    }
  }

  // --- REVERSE GEOCODING via Nominatim ---
  // Returns only 'street' and 'barangay' fields.
  Future<Map<String, String?>> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'EmergencyApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final addr = data['address'] as Map<String, dynamic>?;

        if (addr != null) {
          // Barangay — Philippine admin structure
          final barangay = addr['village'] ??
              addr['suburb'] ??
              addr['quarter'] ??
              addr['neighbourhood'] ??
              addr['city_district'] ??
              addr['county'] ??
              addr['city'] ??
              'Unknown Barangay';

          // Street name only
          final street = addr['road'] ??
              addr['pedestrian'] ??
              addr['footway'] ??
              addr['path'] ??
              '';

          return {'barangay': barangay, 'street': street};
        }
      }
    } catch (_) {}
    return {'barangay': null, 'street': null};
  }

  // --- MAP WIDGET ---
  // Full-width, no rounded corners.
  Widget _buildMap() {
    final center = _currentLatLng ?? const LatLng(10.6770, 122.9511);

    return SizedBox(
      width: double.infinity,
      height: 270,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _currentLatLng != null ? 16.0 : 6.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              // OpenStreetMap tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.emergencyapp',
              ),
              // Pin marker
              if (_currentLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLatLng!,
                      width: 48,
                      height: 56,
                      child: const _PinMarker(),
                    ),
                  ],
                ),
            ],
          ),

          // Loading overlay on map
          if (_locationLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- LOCATION LABEL ---
  // Shows "Street, Barangay" below the map.
  Widget _buildLocationLabel() {
    if (_locationLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Detecting location...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Build "Street, Barangay" or just "Barangay" if no street
    final displayText = _locationError
        ? _locationLabel
        : [
            if (_streetLabel.isNotEmpty) _streetLabel,
            if (_locationLabel.isNotEmpty) _locationLabel,
          ].join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _fetchLocation,
            child: Icon(
              _locationError ? Icons.location_off : Icons.location_on,
              color: _locationError ? Colors.grey : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _locationError ? displayText : 'You are in: $displayText',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _locationError ? Colors.redAccent : Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _fetchLocation,
            child: const Icon(
              Icons.refresh,
              size: 16,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Map — full width, no top spacing
            _buildMap(),

            // Location label below the map
            _buildLocationLabel(),

            const SizedBox(height: 50),

            // Big emergency button — no border, with shadow
            GestureDetector(
              onLongPress: _handleHold,
              onTap: _handleTap,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Main drop shadow below the button
                    BoxShadow(
                      color: Colors.red.withOpacity(0.55),
                      blurRadius: 30,
                      spreadRadius: 6,
                      offset: const Offset(0, 16),
                    ),
                    // Subtle dark shadow for depth
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Hold to send an emergency signal",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Tap 1 time to report an incident",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // POP UP AND FUNCTIONS
  void _handleTap() async {
    //   print("tap detected yey");
    final type = await _showSelection();
    //   print("type $type");
    if (type == null) return;

    final confirmed = await _showConfirmDialog();
    //   print("yis $confirmed");
    if (confirmed) {
      await _saveReportToDatabase(type);
      await _showSignalSent();
      // insert responder ui update here
      // TODO: replace this with real Firestore incident submission
      // Example real code later:
      // await FirebaseFirestore.instance.collection('incidents').add({
      //   'incidentId': generatedId,
      //   'createdBy': currentUserId,
      //   'emergencyType': type,
      //   'barangay': normalizedBarangay,
      //   'status': 'pending',
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
    }
  }



  void _handleHold() async {
    //   print("long press detected");
    final confirmed = await _showConfirmDialog();
    //   print("noice $confirmed");
    if (confirmed) {
      await _saveReportToDatabase('EMERGENCY');
      await _showSignalSent();
      // insert responder ui update here
      // TODO: replace this with real Firestore emergency signal submission
      // Example real code later:
      // await FirebaseFirestore.instance.collection('incidents').add({
      //   'incidentId': generatedId,
      //   'createdBy': currentUserId,
      //   'emergencyType': 'Emergency',
      //   'barangay': normalizedBarangay,
      //   'status': 'pending',
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
    }
  }





  Future<String?> _showSelection() async {
    return showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("Select Emergency Type"),
        children: [
          _option("Fire"),
          _option("Flood"),
          _option("Crime"),
          _option("Others"),
        ],
      ),
    );
  }

  Widget _option(String type) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, type),
      child: Text(type),
    );
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("This will notify responders right away."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showSignalSent() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Signal Sent"),
        content:
            const Text("Your emergency alert has been sent to responders."),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // STORING OF DATA TO FIRESTORE
  Future<void> _saveReportToDatabase(String type) async {
    //try {
//      print("gumana sha");
    await FirebaseFirestore.instance.collection('incidents').add({
      'reportType': type,
      'barangay': _locationLabel,
      'street': _streetLabel,
      'time': TimeOfDay.now().format(context),
      'status': 'PENDING',
      'specification': '',
      'description': '',
      'latitude': _currentLatLng?.latitude,
      'longitude': _currentLatLng?.longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });
    //    print("galing gumana i2 ${docRef.id}");
    // }
    // catch (e) {
    //     print("bakit ayaq n sau$e");
    //     }

  }
}

// --- Custom Red Pin Marker Widget ---
class _PinMarker extends StatelessWidget {
  const _PinMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 20,
          ),
        ),
        // Pin tail
        CustomPaint(
          size: const Size(12, 10),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTailPainter oldDelegate) => false;


}
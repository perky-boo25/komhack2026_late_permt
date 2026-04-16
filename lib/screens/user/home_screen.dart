// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const Duration _kCooldown     = Duration(minutes: 3);
const Duration _kHoldDuration = Duration(seconds: 3);

const List<List<double>> _kPanayPolygon = [
  [121.838899, 12.064466], 
  [123.410848, 11.638368],
  [123.122122, 11.045237],
  [122.741738, 10.752719],
  [121.705994, 10.139773],
  [121.838899, 12.064466],
];

/// Ray-casting algorithm — returns true when [lat],[lon] is inside Panay.
bool _isInsidePanay(double lat, double lon) {
  int crosses = 0;
  final n = _kPanayPolygon.length;
  for (int i = 0, j = n - 1; i < n; j = i++) {
    final xi = _kPanayPolygon[i][0], yi = _kPanayPolygon[i][1];
    final xj = _kPanayPolygon[j][0], yj = _kPanayPolygon[j][1];
    if (((yi > lat) != (yj > lat)) &&
        (lon < (xj - xi) * (lat - yi) / (yj - yi) + xi)) {
      crosses++;
    }
  }
  return crosses.isOdd;
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen widget
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool>?      onGpsChanged;
  final ValueChanged<String>?    onBarangayDetected;
  final DateTime?                cooldownDeadline;
  final ValueChanged<DateTime>?  onCooldownStarted;

  const HomeScreen({
    super.key,
    this.onGpsChanged,
    this.onBarangayDetected,
    this.cooldownDeadline,
    this.onCooldownStarted,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  // ── Location ───────────────────────────────────────────────────────────────
  LatLng? _currentLatLng;
  String  _locationLabel   = 'Detecting location...';
  String  _streetLabel     = '';
  bool    _locationLoading = true;
  bool    _locationError   = false;

  final MapController _mapController = MapController();

  // ── SOS hold animation ─────────────────────────────────────────────────────
  AnimationController? _progressController;
  bool _controllersReady = false;
  bool _isHolding        = false;
  bool _sosTriggered     = false;

  // ── Cooldown ───────────────────────────────────────────────────────────────
  Timer? _cooldownTimer;
  int    _cooldownSecondsLeft = 0;

  bool   get _isCoolingDown   => _cooldownSecondsLeft > 0;

  /// True when location was fetched but the user is outside Panay Island.
  bool   get _isOutsidePanay  =>
      !_locationLoading && _locationError &&
      _locationLabel == 'Out of bounds';

  String get _cooldownLabel {
    final m = _cooldownSecondsLeft ~/ 60;
    final s = _cooldownSecondsLeft % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: _kHoldDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && !_sosTriggered) {
              _sosTriggered = true;
              _onHoldComplete();
            }
          });
    _controllersReady = true;
    _fetchLocation();
    _restoreCooldown(); // restore timer if we came back from role selector
  }

  // Restores the cooldown from shared_preferences (survives full nav stack destruction)
  Future<void> _restoreCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMs = prefs.getInt('sos_cooldown_deadline_ms');
    if (savedMs == null) return;
    final deadline = DateTime.fromMillisecondsSinceEpoch(savedMs);
    final remaining = deadline.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      await prefs.remove('sos_cooldown_deadline_ms');
      return;
    }
    if (!mounted) return;
    setState(() => _cooldownSecondsLeft = remaining);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cooldownSecondsLeft--;
        if (_cooldownSecondsLeft <= 0) {
          _cooldownSecondsLeft = 0;
          t.cancel();
          prefs.remove('sos_cooldown_deadline_ms');
        }
      });
    });
  }

  @override
  void dispose() {
    _progressController?.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ── Cooldown ───────────────────────────────────────────────────────────────

  Future<void> _startCooldown() async {
    _cooldownSecondsLeft = _kCooldown.inSeconds;
    _cooldownTimer?.cancel();

    // Persist deadline FIRST before starting the timer
    final deadline = DateTime.now().add(_kCooldown);
    widget.onCooldownStarted?.call(deadline);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sos_cooldown_deadline_ms', deadline.millisecondsSinceEpoch);

    if (!mounted) return;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cooldownSecondsLeft--;
        if (_cooldownSecondsLeft <= 0) {
          _cooldownSecondsLeft = 0;
          t.cancel();
          prefs.remove('sos_cooldown_deadline_ms'); // clean up when done
        }
      });
    });
  }

  // ── SOS hold helpers ───────────────────────────────────────────────────────

  void _startHold() {
    if (_isHolding || !_controllersReady || _isCoolingDown) return;
    setState(() {
      _isHolding    = true;
      _sosTriggered = false;
    });
    HapticFeedback.mediumImpact();
    _progressController!.forward(from: 0);
  }

  void _cancelHold() {
    if (!_isHolding || !_controllersReady) return;
    _progressController!.stop();
    _progressController!.reset();
    setState(() => _isHolding = false);
  }

  void _onHoldComplete() {
    if (!_controllersReady) return;
    HapticFeedback.heavyImpact();
    _progressController!.reset();
    setState(() => _isHolding = false);
    _handleHold();
  }

  // ── Geolocation ────────────────────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError   = false;
      _locationLabel   = 'Detecting location...';
      _streetLabel     = '';
    });

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        widget.onGpsChanged?.call(false);
        setState(() {
          _locationLoading = false;
          _locationError   = true;
          _locationLabel   = 'Location permission denied.';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        widget.onGpsChanged?.call(false);
        setState(() {
          _locationLoading = false;
          _locationError   = true;
          _locationLabel   = 'Location services are disabled.';
        });
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ── Panay Island geofence ──────────────────────────────────────────────
      if (!_isInsidePanay(pos.latitude, pos.longitude)) {
        widget.onGpsChanged?.call(false);
        setState(() {
          _locationLoading = false;
          _locationError   = true;
          _locationLabel   = 'Out of bounds';
        });
        return;
      }
      // ───────────────────────────────────────────────────────────────────────

      final latlng  = LatLng(pos.latitude, pos.longitude);
      final address = await _reverseGeocode(pos.latitude, pos.longitude);

      setState(() {
        _currentLatLng   = latlng;
        _locationLoading = false;
        _locationError   = false;
        _locationLabel   = address['barangay'] ?? 'Unknown Barangay';
        _streetLabel     = address['street']   ?? '';
      });

      widget.onGpsChanged?.call(true);

      final brgy = address['barangay'];
      if (brgy != null && brgy.trim().isNotEmpty) {
        widget.onBarangayDetected?.call(brgy);
      }

      WidgetsBinding.instance.addPostFrameCallback((d) {
        _mapController.move(latlng, 16.0);
      });
    } catch (e) {
      widget.onGpsChanged?.call(false);
      setState(() {
        _locationLoading = false;
        _locationError   = true;
        _locationLabel   = 'Could not detect location.';
      });
    }
  }

  Future<Map<String, String?>> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );
      final resp = await http.get(uri, headers: {'User-Agent': 'EmergencyApp/1.0'});
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final barangay = addr['village']       ??
                           addr['suburb']        ??
                           addr['quarter']       ??
                           addr['neighbourhood'] ??
                           addr['city_district'] ??
                           addr['county']        ??
                           addr['city']          ??
                           'Unknown Barangay';
          final street = addr['road']       ??
                         addr['pedestrian'] ??
                         addr['footway']    ??
                         addr['path']       ??
                         '';
          return {'barangay': barangay, 'street': street};
        }
      }
    } catch (e) {
      // ignore
    }
    return {'barangay': null, 'street': null};
  }

  // ── Firestore ──────────────────────────────────────────────────────────────

  Future<DocumentReference?> _saveReport({
    required String type,
    String specification = '',
    String description   = '',
  }) async {
    try {
    //   final user = FirebaseAuth.instance.currentUser;
    //
    //   // check f the user is null, they aren't authorized if so
    //   if (user == null) {
    //     debugPrint("Cannot save: User is not authenticated.");
    //     return null;
    //   }
      return await FirebaseFirestore.instance.collection('incidents').add({
        // 'userId':        user.uid,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'reportType':    type,
        'barangay':      _locationLabel,
        'street':        _streetLabel,
        'time':          TimeOfDay.now().format(context),
        'status':        'PENDING',
        'specification': specification,
        'description':   description,
        'latitude':      _currentLatLng?.latitude,
        'longitude':     _currentLatLng?.longitude,
        'responders':    [],
        'createdAt':     FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving report: $e");
      return null;
    }
  }

  // ── Dialog flow — TAP ──────────────────────────────────────────────────────

  Future<void> _handleTap() async {
    if (_isCoolingDown) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _EmergencyTypeDialog(),
    );
    if (result == null || !mounted) return;

    final docRef = await _saveReport(
      type:          result['type']!,
      specification: result['specification'] ?? '',
      description:   result['description']   ?? '',
    );
    if (docRef == null || !mounted) return;

    await _startCooldown();

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SignalSentDialog(
        incidentId:    docRef.id,
        emergencyType: result['type']!,
        getCooldown:   () => _cooldownSecondsLeft,
      ),
    );
  }

  // ── Dialog flow — HOLD ─────────────────────────────────────────────────────

  Future<void> _handleHold() async {
    if (_isCoolingDown) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _HoldConfirmDialog(),
    );
    if (confirmed != true || !mounted) return;

    final docRef = await _saveReport(type: 'EMERGENCY');
    if (docRef == null || !mounted) return;

    await _startCooldown();

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SignalSentDialog(
        incidentId:    docRef.id,
        emergencyType: 'EMERGENCY',
        getCooldown:   () => _cooldownSecondsLeft,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMap(),
            _buildLocationLabel(),
            const SizedBox(height: 36),

            // ── SOS button ─────────────────────────────────────────────────
            if (!_controllersReady)
              const SizedBox(width: 216, height: 216)
            else
              AnimatedBuilder(
                animation: _progressController!,
                builder: (context, child) {
                  final progress = _progressController!.value;
                  final disabled = _isCoolingDown || _isOutsidePanay || _locationLoading;
                  final btnColor = disabled ? Colors.grey : Colors.red;

                  return GestureDetector(
                    onLongPressStart:  disabled ? null : (d) => _startHold(),
                    onLongPressEnd:    (d) => _cancelHold(),
                    onLongPressCancel: () => _cancelHold(),
                    onTap: (_isHolding || disabled) ? null : _handleTap,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 216, height: 216,
                          child: CustomPaint(
                            painter: _ArcPainter(
                              progress:    progress,
                              color:       btnColor,
                              trackColor:  btnColor.withOpacity(0.15),
                              strokeWidth: 4,
                            ),
                          ),
                        ),
                        Container(
                          width: 200, height: 200,
                          decoration: BoxDecoration(
                            color: btnColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:        btnColor.withOpacity(0.55),
                                blurRadius:   30,
                                spreadRadius: 6,
                                offset:       const Offset(0, 16),
                              ),
                              BoxShadow(
                                color:        Colors.black.withOpacity(0.18),
                                blurRadius:   12,
                                spreadRadius: 2,
                                offset:       const Offset(0, 8),
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
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 28),

            // ── Hint / cooldown label ──────────────────────────────────────
            if (_locationLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24, height: 24,
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 4),
                  ],
                ),
              )
            else if (_isCoolingDown)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Next report available in: $_cooldownLabel',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (_isOutsidePanay)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Icon(Icons.location_off, color: Colors.grey, size: 28),
                    SizedBox(height: 6),
                    Text(
                      'Hindi available sa labas ng Panay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              )
            else ...[
              const Text(
                'I-hold para magsend ng SOS signal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'I-tap para magreport ng insidente',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 19),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Map ────────────────────────────────────────────────────────────────────

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
                       InteractiveFlag.drag      |
                       InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.emergencyapp',
              ),
              if (_currentLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point:  _currentLatLng!,
                      width:  48,
                      height: 56,
                      child:  const _PinMarker(),
                    ),
                  ],
                ),
            ],
          ),
          if (_locationLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // ── Location label ─────────────────────────────────────────────────────────

  Widget _buildLocationLabel() {
    if (_locationLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14, height: 14,
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

    final displayText = _locationError
        ? _locationLabel
        : [
            if (_streetLabel.isNotEmpty)   _streetLabel,
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
              _locationError ? displayText : 'Ikaw ay nasa: $displayText',
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
            child: const Icon(Icons.refresh, size: 16, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmergencyTypeDialog  (tap flow)
// ─────────────────────────────────────────────────────────────────────────────

class _EmergencyTypeDialog extends StatefulWidget {
  const _EmergencyTypeDialog();

  @override
  State<_EmergencyTypeDialog> createState() => _EmergencyTypeDialogState();
}

class _EmergencyTypeDialogState extends State<_EmergencyTypeDialog> {

  String? _selectedType;
  final TextEditingController _specCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

    static const List<Map<String, Object>> _types = [
    {
      'value': 'Fire',
      'label': 'Sunog',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFFF6B35)
    },
    {
      'value': 'Flood',
      'label': 'Baha',
      'icon': Icons.water_drop,
      'color': Color(0xFF29B6F6)
    },
    {
      'value': 'Medical',
      'label': 'Medikal',
      'icon': Icons.medical_services,
      'color': Color(0xFF43A047)
    },
    {
      'value': 'Other',
      'label': 'Iba pa',
      'icon': Icons.report_sharp,
      'color': Color(0xFF000000)
    },
  ];

  @override
  void dispose() {
    _specCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(<String, String>{
      'type':          _selectedType!,
      'specification': _specCtrl.text.trim(),
      'description':   _descCtrl.text.trim(),
    });
  }

  void _cancel() => Navigator.of(context).pop(null);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title row with icon
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'I-KUMPIRMA AND REPORT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Sigurado ka bang gusto mo magreport?',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),

            // Type label
            const Text(
              'Pumili ng kategorya ng emergency:',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // 2×2 grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: _types.map((t) {
                final value = t['value']! as String;
                final label = t['label']! as String;
                final icon = t['icon']! as IconData;
                final color = t['color']! as Color;
                final isSelected = _selectedType == value;

                return GestureDetector(
                  onTap: () => setState(() => _selectedType = value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFDDDDDD),
                        width: isSelected ? 2.2 : 1.2,
                      ),
                      color: isSelected
                          ? color.withOpacity(0.18)
                          : const Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: color, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Specification — only visible when "Other" is selected
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _selectedType == 'Other'
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: _specCtrl,
                        decoration: InputDecoration(
                          hintText: 'Pakitukoy (opsyonal)',
                          hintStyle: const TextStyle(
                              color: Colors.black38, fontSize: 15),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 14),

            // Description
            const Text(
              'Karagdagang Impormasyon',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Opsyonal',
                hintStyle: const TextStyle(
                    color: Colors.black38, fontSize: 13),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _cancel,
                    child: const Text(
                      'I-KANSELA',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType != null
                          ? Colors.red
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _selectedType != null ? _submit : null,
                    child: const Text(
                      'ISUMITE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HoldConfirmDialog  (hold flow — simple confirm only)
// ─────────────────────────────────────────────────────────────────────────────

class _HoldConfirmDialog extends StatelessWidget {
  const _HoldConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                const Text( 
                  'I-KUMPIRMA ANG REPORT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 8), 
            const Text(
              'Sigurado ka bang gusto mo magreport?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'SEND',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// _SignalSentDialog  (live responder status)
// ─────────────────────────────────────────────────────────────────────────────

class _SignalSentDialog extends StatefulWidget {
  final String         incidentId;
  final String         emergencyType;
  final int Function() getCooldown;

  const _SignalSentDialog({
    required this.incidentId,
    required this.emergencyType,
    required this.getCooldown,
  });

  @override
  State<_SignalSentDialog> createState() => _SignalSentDialogState();
}

class _SignalSentDialogState extends State<_SignalSentDialog> {

  StreamSubscription<DocumentSnapshot>? _firestoreSub;
  Timer? _uiTimer;

  String       _status        = 'PENDING';
  String       _sentTime      = '';
  String       _sentDate      = '';
  String       _specification = '';
  String       _description   = '';
  int          _secondsLeft   = 0;

  @override
  void initState() {
    super.initState();

    _secondsLeft = widget.getCooldown();

    // Tick every second to refresh the cooldown label
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft = widget.getCooldown());
    });

    // Live Firestore listener
    _firestoreSub = FirebaseFirestore.instance
        .collection('incidents')
        .doc(widget.incidentId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final data = snap.data()!;

      // Derive a readable date from createdAt Timestamp
      String dateStr = '';
      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      }

      setState(() {
        _status        = (data['status']        as String? ?? 'PENDING').toUpperCase();
        _sentTime      =  data['time']          as String? ?? '';
        _sentDate      =  dateStr;
        _specification =  data['specification'] as String? ?? '';
        _description   =  data['description']  as String? ?? '';
      });
    });
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _uiTimer?.cancel();
    super.dispose();
  }

  bool get _isAcknowledged =>
      _status == 'IN_PROGRESS'  ||
      _status == 'IN PROGRESS'  ||
      _status == 'ACKNOWLEDGED' ||
      _status == 'RESOLVED';

  String get _cooldownLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Bell icon
            Container(
              width: 90, height: 90,
              decoration: const BoxDecoration(
                color: Colors.red, shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications, color: Colors.white, size: 48,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'EMERGENCY NAIREPORT',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4),
            ),
            const SizedBox(height: 4),
            Text(
              _isAcknowledged
                  ? 'Papunta na ang mga responder!'
                  : 'Naipaalam na sa mga responder!',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 14),

            // Status card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAcknowledged
                      ? Colors.green
                      : const Color(0xFFEEEEEE),
                  width: 1.4,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Dot + status text
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isAcknowledged
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isAcknowledged
                              ? 'Na-assign na ang responder'
                              : 'Naghihintay ng kumpirmasayon...',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _isAcknowledged
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_sentTime.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Oras naisumite: $_sentTime',
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black54),
                    ),
                  ],

                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Report details
            const Text(
              'Detalye ng Report',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _row('ID ng insidente',
                '#${widget.incidentId.substring(0, min(10, widget.incidentId.length))}'),
            _row('Uri ng Emergency', widget.emergencyType),
            _row('Petsa', _sentDate.isNotEmpty ? _sentDate : '–'),
            _row('Espesipikasyon',
                _specification.isNotEmpty ? _specification : '–'),
            _row('Deskripsyon',
                _description.isNotEmpty ? _description : '–'),

            const SizedBox(height: 14),

            // Cooldown countdown
            if (_secondsLeft > 0)
              Text(
                'Makakareport uli sa: $_cooldownLabel',
                style: const TextStyle(
                    fontSize: 15, color: Colors.black45),
              ),

            const SizedBox(height: 16),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black45)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map pin
// ─────────────────────────────────────────────────────────────────────────────

class _PinMarker extends StatelessWidget {
  const _PinMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36, height: 36,
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
          child: const Icon(Icons.person_pin, color: Colors.white, size: 20),
        ),
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
  bool shouldRepaint(_PinTailPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Arc progress painter
// ─────────────────────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color  color;
  final Color  trackColor;
  final double strokeWidth;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color       = trackColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap   = StrokeCap.round,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      rect, -pi / 2, 2 * pi * progress, false,
      Paint()
        ..color       = color
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap   = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
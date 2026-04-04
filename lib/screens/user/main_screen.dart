import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _kActiveColor = Color(0xFF000000);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  bool gpsActive = false;
  bool networkActive = false;
  bool isSafe = false;

  //TODO: replace later with actual logged-in na UID
  final String userId = '00001';

  //subscription for device connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _networkSub;

  //
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _safeSub;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      HomeScreen(
        //send GPS status back to MainScreen
        onGpsChanged: _updateGpsStatus,

        //send detected barangay back to MainScreen
        onBarangayDetected: _listenToAreaSafety,
      ),
      const MyReportsScreen(),
    ];
    _checkInitialNetworkStatus();
    _listenToNetworkStatus();
  }

    //updates GPS chip and optionally saves it to Firestore
  Future<void> _updateGpsStatus(bool active) async {
    if (!mounted) return;

    setState(() {
      gpsActive = active;
    });

    try {
      await FirebaseFirestore.instance.collection('status').doc(userId).set({
        'gpsActive': active,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }catch(e){
      //ignore error for now
    }
  }

  // New: checks current network state once during startup
  Future<void> _checkInitialNetworkStatus() async {
    final result = await Connectivity().checkConnectivity();
    final bool online = result != ConnectivityResult.none;

    if (!mounted) return;

    setState(() {
      networkActive = online;
    });

    try {
      await FirebaseFirestore.instance.collection('status').doc(userId).set({
        'networkActive': online,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // optional only; ignore Firestore write errors for now
    }
  }

  // New: listens to actual device internet/network connectivity
  void _listenToNetworkStatus() {
    _networkSub = Connectivity().onConnectivityChanged.listen((result) async {
      // Device is considered online if connectivity is not none
      final bool online = result != ConnectivityResult.none;

      if (!mounted) return;

      setState(() {
        networkActive = online;
      });

      try {
        await FirebaseFirestore.instance.collection('status').doc(userId).set({
          'networkActive': online,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        // optional only; ignore Firestore write errors for now
      }
    });
  }

    // New: listens to Firestore safety status of the detected barangay in real time
  Future<void> _listenToAreaSafety(String barangay) async {
    // cancel previous listener first so only one barangay listener is active
    await _safeSub?.cancel();

    // normalize barangay name for safer document ids
    final normalizedBarangay = barangay.trim().toLowerCase().replaceAll(' ', '_');

    try {
      // optional: save the user's detected barangay
      await FirebaseFirestore.instance.collection('status').doc(userId).set({
        'barangay': normalizedBarangay,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // optional only; ignore Firestore write errors for now
    }

    _safeSub = FirebaseFirestore.instance
        .collection('areas')
        .doc(normalizedBarangay)
        .snapshots()
        .listen((doc) {
      final data = doc.data();

      if (!mounted) return;

      setState(() {
        // if document does not exist yet, default to false for now
        isSafe = data?['isSafe'] == true;
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children:  [
            ClipRRect(
              borderRadius: BorderRadius.circular(6), // rounded logo
              child: SizedBox(
              width: 34,
              height: 34,
              child: Image.asset('images/logo.jpg', fit: BoxFit.cover), // app logo
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Application Name',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E0E0), height: 1),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),
          // ── Status chips ───────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatusChip(
                  label: 'GPS active',
                  isActive: gpsActive,
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Network',
                  isActive: networkActive,
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Safe',
                  isActive: isSafe,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),

      // ── Bottom nav ─────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () => setState(() => selectedIndex = 0),
            ),
            _NavItem(
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              label: 'My Reports',
              isSelected: selectedIndex == 1,
              onTap: () => setState(() => selectedIndex = 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status chip ────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        color: const Color(0xFFFAFAFA),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}

// ── Nav item ───────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _kActiveColor : Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 36 : 0,
              decoration: BoxDecoration(
                color: _kActiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
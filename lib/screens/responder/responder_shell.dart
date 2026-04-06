import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:komhack2026_late_permt/screens/responder/tab_map.dart';
import 'package:komhack2026_late_permt/screens/responder/tab_alert.dart';
import 'package:komhack2026_late_permt/screens/responder/tab_home.dart';
import 'package:komhack2026_late_permt/screens/responder/tab_teams.dart';
import 'package:komhack2026_late_permt/screens/responder/tab_profile.dart';



class AppState {
  /// null  = no alert assigned to this responder yet
  /// non-null = the alert that was accepted
  static Map<String, dynamic>? assignedAlert;
}

class ResponderShell extends StatefulWidget {
  const ResponderShell({super.key});

  @override
  State<ResponderShell> createState() => ResponderShellState();
}

class ResponderShellState extends State<ResponderShell> {
  int _selectedIndex = 2; // Home is the centre button
  // String _userRole = 'responder';

  void switchTab(int index) => setState(() => _selectedIndex = index);
  
  void _loadUserRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final query = await FirebaseFirestore.instance
        .collection('responders')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (mounted && query.docs.isNotEmpty) {
      final docData = query.docs.first.data();
      debugPrint("Logged in user data: $docData");
      
      // setState(() {
      //   _userRole = docData['role'] ?? 'responder';
      // });
    }
  }
}


  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      //hides app bar if current page is in account creation, it ugly
      appBar: _selectedIndex == 5 ? null : _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 16,
      title: Row(
        children: [
          // Logo placeholder – replace with Image.asset('assets/logo.png')
          ClipRRect(
              borderRadius: BorderRadius.circular(6), // rounded logo
              child: SizedBox(
              width: 34,
              height: 34,
              child: Image.asset('images/logo.jpg', fit: BoxFit.cover), // app logo
              ),
            ),
          const SizedBox(width: 10),
          const Text(
            'Application Name',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.black54),
          onPressed: () => switchTab(4), // jump to Profile
        ),
      ],
    );
  }

  // ── BODY ────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return const MapTab();
      case 1: return AlertTab(onSwitchTab: switchTab);
      case 2: return HomeTab(onSwitchTab: switchTab);
      case 3: return const TeamsTab();
      case 4: return const ProfileTab();
      default: return HomeTab(onSwitchTab: switchTab);
    }
  }



  // ── BOTTOM NAV ──────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.map_outlined, 'Map'),
              
              // checks user role to see whether to present manage or alert
              _navItem(1, Icons.notifications_outlined, 'Alert'),
              
              _homeButton(),
              _navItem(3, Icons.groups_outlined, 'Teams'),
              _navItem(4, Icons.person_outlined, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? const Color(0xFF1A1A2E) : Colors.black38,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF1A1A2E) : Colors.black38,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeButton() {
    final isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : Colors.black54,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
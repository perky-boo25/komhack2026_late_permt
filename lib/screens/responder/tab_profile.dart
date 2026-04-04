import 'package:flutter/material.dart';

/// Profile tab – displays the logged-in responder's profile.
/// Replace the static data with a Firebase auth + Firestore fetch later.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Placeholder profile data – replace with Firebase user document
  static const Map<String, String> _profile = {
    'initials': 'UI',
    'unit': 'UNIT 01',
    'team': 'Fire Team',
    'id': '#RSP-000-001',
    'name': 'Bruce Wayne',
    'specialization': 'General',
    'email': 'brucewayne@responder.com',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade300, width: 2),
            ),
            child: Center(
              child: Text(
                _profile['initials']!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Unit / Team
          Text(
            '${_profile['unit']} • ${_profile['team']}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 24),

          // Info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _infoRow('Responder ID', _profile['id']!),
                _divider(),
                _infoRow('Name', _profile['name']!),
                _divider(),
                _infoRow('Specialization', _profile['specialization']!),
                _divider(),
                _infoRow('Email', _profile['email']!),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Log out button placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Firebase sign-out + navigate to login screen
                Navigator.pushReplacementNamed(context, '/responder-login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }
}
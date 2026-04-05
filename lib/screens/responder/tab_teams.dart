import 'package:flutter/material.dart';

/// Teams tab – lists responders currently on duty.
/// Replace the static list with a Firebase stream later.
class TeamsTab extends StatelessWidget {
  const TeamsTab({super.key});

  // Placeholder data – replace with Firestore collection
  static const List<Map<String, String>> _responders = [
    {'initials': 'UI', 
    'unit': 'UNIT 01', 
    'team': 'Fire Team'},
    // Add more responders here when wiring up Firebase
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text(
            'Responders on Duty',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _responders.isEmpty
              ? const Center(
                  child: Text(
                    'No responders on duty',
                    style: TextStyle(color: Colors.black45, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _responders.length,
                  itemBuilder: (context, i) => _responderCard(_responders[i]),
                ),
        ),
      ],
    );
  }

  Widget _responderCard(Map<String, String> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade300, width: 1.5),
            ),
            child: Center(
              child: Text(
                r['initials']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${r['unit']} • ${r['team']}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
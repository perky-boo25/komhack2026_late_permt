import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:komhack2026_late_permt/screens/responder/admin/new_responder.dart';
import 'package:komhack2026_late_permt/widgets/ResponderTile.dart';

class TeamsTab extends StatefulWidget {
  const TeamsTab ({super.key});

  @override
  State<TeamsTab> createState() => TeamsTabState();
}

class TeamsTabState extends State<TeamsTab> {
  

  // AppBar _buildAppBar() {
  //   return AppBar(
  //     title: const Text(
  //       "Manage Responders",
  //       style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
  //     ),
  //     backgroundColor: Colors.white,
  //     elevation: 1,
  //   );
  // }

  Widget _buildResponderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('responders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No responders near you"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index]; // Use doc to get the ID
            final data = doc.data() as Map<String, dynamic>;
            
            return ResponderTile(
              rID: data['responderId'] ?? 'N/A',
              name: data['name'] ?? 'Unknown',
              loc: data['department'] ?? 'General',
              dept: data['department'] ?? 'gen',
              isActive: data['status'] == true,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      // appBar: _buildAppBar(),
      body: Column(
        children: [
            Expanded(
                child: _buildResponderList(),
              ),
        ],
      ),
    );
  }
}

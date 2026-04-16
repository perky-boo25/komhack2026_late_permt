// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:komhack2026_late_permt/screens/responder/admin/new_responder.dart';
import 'package:komhack2026_late_permt/widgets/responder_tile.dart';

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

            final String role = data['role'] ?? 'responder';
            final bool isAdmin = role == 'admin';


            if (isAdmin){
              return const SizedBox.shrink(); //skipp all admins
            }
            
            return ResponderTile(
              rID: data['responderId'] ?? 'N/A',
              name: data['name'] ?? 'Unknown',
              loc: data['location'] ?? 'General', // Fixed mapping
              dept: data['department'] ?? 'gen',
              isActive: data['status'] == true,
              
              // HIDES ADMIN ONLY FUNCTIONS
              isAdmin: false,
              canDelete: false,
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

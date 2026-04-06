import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:komhack2026_late_permt/screens/responder/admin/new_responder.dart';
import 'package:komhack2026_late_permt/widgets/ResponderTile.dart';

class ManageTab extends StatefulWidget {
  const ManageTab({super.key});

  @override
  State<ManageTab> createState() => ManageTabState();
}

class ManageTabState extends State<ManageTab> {
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Manage Responders",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
    );
  }

  Widget _buildResponderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('responders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No responders registered yet."));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
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

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewAcctPage()),
            );
          },
          child: Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(204, 239, 239, 239),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: const Center(
              child: Text(
                "+ Add new responder",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.transparent, Colors.transparent, Colors.white],
                stops: [0.0, 0.1, 0.9, 1.0],
              ).createShader(rect);
            },
          ),
          Expanded(child: _buildResponderList()),
          _buildAddButton(),
        ],
      ),
    );
  }
}

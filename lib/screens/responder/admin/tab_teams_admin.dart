import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:komhack2026_late_permt/screens/responder/admin/newAcctPage.dart'; 
import 'package:komhack2026_late_permt/widgets/ResponderTile.dart';

//just for tests

class ManageTab extends StatefulWidget {
  const ManageTab ({super.key});

  @override
  State<ManageTab> createState() => ManageTabState();
}

class ManageTabState extends State<ManageTab> {
  // // List<Map<String, dynamic>> responderList = [
  // //   // {
  // //   //   'rID': 'RSP-324123',
  // //   //   'name': "Bruce Wayne",
  // //   //   'loc': "Brgy. Mat-y, Hollywood St.",
  // //   //   'dept' : "general",
  // //   //   'status' : "active"
  // //   //
  // //   // },
  // //   // {
  // //   //   'rID': 'RSP-234325',
  // //   //   'name': "Peter Parker",
  // //   //   'loc': "Brgy. Mat-y, Hollywood St.",
  // //   //   'dept' : "police",
  // //   //   'status' : "idle"
  // //   //
  // //   // },


  // ];

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Column(
          children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('responders').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(child: Text("Something went wrong"));
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                            if (docs.isEmpty) {
                              return const Center(child: Text("No responders registered yet."));
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 10),
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
                        ),
                      ),
                    
                  SizedBox(height: 15),
                  //TODO: fix layout
                  Center(
                    child: Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        
                          color: const Color.fromARGB(204, 239, 239, 239),
                          
                        ),  
                            child: GestureDetector(
                                child: Center(
                                        child: Text(
                                                "+ Add new responder",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Montserrat",
                                                ),
                                              ),
                                      ),

                                onTap: () async {

                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const newAcctPage()),
                                  );
                                },
                                
                            )
                        )
                    ),
          ],
        ),

      ),
    );
  }
}

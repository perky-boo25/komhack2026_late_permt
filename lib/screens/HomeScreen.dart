import 'package:flutter/material.dart';

// TODO: add nav for switching from home to my reports and vice versa
//       popups for hazards and emergency button click
//       maybe the safe one could also update (?)
//       unify colors, fontstyle, fontsize

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void testonly() {
    print('is working'); //for testing lng
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),


          //placeholder for loc
          Center(
            child: SizedBox(
              width: 390,
              height: 270,
              child: Placeholder(),
            ),
          ),

          SizedBox(height: 30),
          //space between loc img and quick rep text

          // //quickreport section
          // Column(
          //   children: [
          //     Text(
          //         'Quick Report',
          //         style: TextStyle(
          //         fontSize: 22,
          //         fontWeight: FontWeight.bold,
          //       )
          //
          //     ),
          //
          //     SizedBox(height: 20), //space between quick rep text and reports
          //
          //     // fire and flood buttons
          //     Row(
          //       children: [
          //         const SizedBox(width: 20),
          //         //fire
          //         SizedBox(
          //           width: 180,
          //           height: 55,
          //           child: OutlinedButton(
          //             style: OutlinedButton.styleFrom(
          //               backgroundColor: Colors.grey[200],
          //               side: const BorderSide(color: Colors.black, width: 2),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //             ),
          //             onPressed:testonly,
          //             child: const Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Icon(
          //                   Icons.local_fire_department,
          //                   color: Colors.orange,
          //                   size: 35,
          //                 ),
          //                 SizedBox(width: 10),
          //                 Text(
          //                   "FIRE",
          //                   style: TextStyle(
          //                     fontSize: 24,
          //                     color: Colors.black,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //
          //         const Spacer(), //space between fire and flood
          //       //flood
          //         SizedBox(
          //           width: 180,
          //           height: 55,
          //           child: OutlinedButton(
          //             style: OutlinedButton.styleFrom(
          //               backgroundColor: Colors.grey[200],
          //               side: const BorderSide(color: Colors.black, width: 2),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //             ),
          //             onPressed: testonly,
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Icon(
          //                   Icons.waves,
          //                   color: Colors.blue[700],
          //                   size: 35,
          //                 ),
          //
          //                 SizedBox(width: 10),
          //                 Text(
          //                   "FLOOD",
          //                   style: TextStyle(
          //                     fontSize: 24,
          //                     color: Colors.black,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //
          //         const SizedBox(width: 20),
          //       ],
          //     ),
          //
          //     SizedBox(height: 20), //space between two rows
          //
          //     // medical and other buttons
          //     Row(
          //       children: [
          //         const SizedBox(width: 20),
          //         //med
          //         SizedBox(
          //           width: 180,
          //           height: 55,
          //           child: OutlinedButton(
          //             style: OutlinedButton.styleFrom(
          //               backgroundColor: Colors.grey[200],
          //               side: const BorderSide(color: Colors.black, width: 2),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //             ),
          //             onPressed: testonly,
          //             child: const Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Icon(
          //                   Icons.medical_services,
          //                   color: Colors.red,
          //                   size: 35,
          //                 ),
          //                 SizedBox(width: 10),
          //                 Text(
          //                   "MEDICAL",
          //                   style: TextStyle(
          //                     fontSize: 24,
          //                     color: Colors.black,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //
          //         const Spacer(), // space between medical and other
          //
          //         //other
          //         SizedBox(
          //           width: 180,
          //           height: 55,
          //           child: OutlinedButton(
          //             style: OutlinedButton.styleFrom(
          //               backgroundColor: Colors.grey[200],
          //               side: const BorderSide(color: Colors.black, width: 2),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //             ),
          //             onPressed: testonly,
          //             child: const Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Icon(
          //                   Icons.warning,
          //                   color: Colors.grey,
          //                   size: 35,
          //                 ),
          //                 SizedBox(width: 10),
          //                 Text(
          //                   "OTHER",
          //                   style: TextStyle(
          //                     fontSize: 24,
          //                     color: Colors.black,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //
          //         const SizedBox(width: 20),
          //       ],
          //     ),
          //   ]
          // ),

          SizedBox(height: 55),
          //space above emergency btn

          //big ass emergency btn
          GestureDetector(
            onLongPress: _handleHold,
            onTap: _handleTap,
            child: Container(
              width: 300,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red[900]!,
                  width: 7,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          Text(
            "Hold to send emergency an emergency signal.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Tap 1 time to report an incident.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
          ),
        ],

      ),
    );
  }

  // POP UP AND FUNCTIONS
  // cooldown
  DateTime? _lastSentTime;
  final Duration _cooldownDuration = Duration(minutes: 3);

  bool _isOnCooldown(){
    if (_lastSentTime == null) return false;
    return DateTime.now().difference(_lastSentTime!) < _cooldownDuration;
  }

  int _leftCooldownSeconds(){
    if (_lastSentTime == null) return 0;
    final remain = _cooldownDuration - DateTime.now().difference(_lastSentTime!);
    return remain.inSeconds > 0 ? remain.inSeconds : 0;
  }

  Future<void> _showCooldownDialog() async {
    final secs = _leftCooldownSeconds();
    final mins = (secs / 60).ceil();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Cooldown Active"),
        content: Text("Please wait $mins minute(s) before sending another alert."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // tap
  void _handleTap() async {
    if (_isOnCooldown()){
      await _showCooldownDialog();
      return;
    }

    final result = await _showSelection();
    if (result == null) return;

    _lastSentTime = DateTime.now();
    await _showSignalSent();
    // insert responder ui update here
  }

  // hold
  void _handleHold() async {
    if (_isOnCooldown()){
      await _showCooldownDialog();
      return;
    }

    final result = await _showSelection(isUrgent: true);
    if (result == null) return;

    _lastSentTime = DateTime.now();
    await _showSignalSent();
    // insert responder ui update here
  }

  // main dialogs
  Future<Map<String, String>?> _showSelection({bool isUrgent = false}) async {
    String? selectedType;
    final otherController = TextEditingController();
    final locController = TextEditingController();

      Widget buildTypeButton(String label, IconData icon, Color color) {
        final isSelected = selectedType == label;

        return GestureDetector(
            onTap: () {
              selectedType = label;
            },
            child: StatefulBuilder(
              onTap: () => setState(() => selectedType = label),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 28),
                    SizedBox(height: 5),
                    Text(label),
                  ],
                ),
              ),
            );
        ),
      },
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context){
        return StatefulBuilder(
            builder: (context, setState){
              return AlertDialog(
                title: Text("Confirm Emergency"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // type of emergency
                      Text("Type of Emergency", style: TextStyle(fontWeight: FontWeight.bold)),
                      RadioListTile(
                        title: Text("Fire"),
                        value: "Fire",
                        groupValue: selectedType,
                        onChanged: (val) => setState(() => selectedType = val),
                      ),
                      RadioListTile(
                        title: Text("Flood"),
                        value: "Flood",
                        groupValue: selectedType,
                        onChanged: (val) => setState(() => selectedType = val),
                      ),
                      RadioListTile(
                        title: Text("Medical"),
                        value: "Medical",
                        groupValue: selectedType,
                        onChanged: (val) => setState(() => selectedType = val),
                      ),
                      RadioListTile(
                        title: Text("Other"),
                        value: "Other",
                        groupValue: selectedType,
                        onChanged: (String? val) => setState(() => selectedType = val),
                      ),

                      // other input
                      TextField(
                        controller: otherController,
                        enabled: selectedType == "Other",
                        decoration: InputDecoration(
                          hintText: "please specify (optional)",
                        ),
                      ),

                      SizedBox(height: 16),

                      // location details
                      Text("Add Location Details", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: locController,
                        decoration: InputDecoration(
                          hintText: "please specify (optional)",
                        ),
                      ),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      if (selectedType == null) return;

                      Navigator.pop(context, {
                        "type": selectedType == "Other"
                          ? otherController.text
                          : selectedType!,
                        "location": locController.text, // only what is typed in optional loc field
                        "urgent": isUrgent.toString(),
                      });
                    },
                    child: Text("Send"),
                  ),
                ],
              );
            },
        );
      },
    );
  }

  // signal sent
  Future<void> _showSignalSent() async {
    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Signal Sent"),
            content: Text("Your emergency alert has been sent to responders."),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }
}

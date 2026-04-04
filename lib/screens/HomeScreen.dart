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
    await _showSignalSent(result);
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
    await _showSignalSent(result);
    // insert responder ui update here
  }

  // main dialogs
  Future<Map<String, String>?> _showSelection({bool isUrgent = false}) async {
    String? selectedType;
    final otherController = TextEditingController();
    final descController = TextEditingController();

    Widget buildTypeButton(String label, IconData icon, Color color, void Function(void Function()) setState) {
      final isSelected = selectedType == label;

      return GestureDetector(
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
    }

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "CONFIRM EMERGENCY",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Are you sure you want to send a report?",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),

                    // TYPE TITLE
                    Text(
                      "Select type of emergency:",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    // GRID
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        buildTypeButton("Fire", Icons.local_fire_department, Colors.red, setState),
                        buildTypeButton("Flood", Icons.water_drop, Colors.blue, setState),
                        buildTypeButton("Medical", Icons.medical_services, Colors.green, setState),
                        buildTypeButton("Other", Icons.error, Colors.black, setState),
                      ],
                    ),

                    SizedBox(height: 10),

                    // OTHER FIELD
                    if (selectedType == "Other")
                      TextField(
                        controller: otherController,
                        decoration: InputDecoration(
                          hintText: "Please specify (optional)",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                    SizedBox(height: 10),

                    // DESCRIPTION
                    Text("Description"),
                    SizedBox(height: 5),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Optional",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text("CANCEL"),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              if (selectedType == null) return;

                              Navigator.pop(context, {
                                "type": selectedType == "Other"
                                    ? (otherController.text.isEmpty
                                    ? "Other"
                                    : otherController.text)
                                    : selectedType!,
                                "description": descController.text,
                                "urgent": isUrgent.toString(),
                              });
                            },
                            child: Text("SEND"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // signal sent
  Future<void> _showSignalSent(Map<String, String> data) async {
    bool isAssigned = false; // simulate state change

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool startedTimer = false;
            // simulate responder assignment after 3 sec (testing only)

            if (!startedTimer) {
              startedTimer = true;

              Future.delayed(Duration(seconds: 3), () {
                if (context.mounted) {
                  setState(() => isAssigned = true);
                }
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // 🔴 ICON
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.notifications, color: Colors.white, size: 40),
                    ),

                    SizedBox(height: 20),

                    // TITLE
                    Text(
                      "EMERGENCY SIGNAL SENT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      isAssigned
                          ? "Responders are en route!"
                          : "Responders have been notified",
                      style: TextStyle(color: Colors.grey),
                    ),

                    SizedBox(height: 15),

                    // STATUS CARD
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isAssigned ? Colors.green : Colors.orange,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isAssigned ? Icons.check_circle : Icons.hourglass_top,
                                color: isAssigned ? Colors.green : Colors.orange,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text(
                                isAssigned
                                    ? "Responder has been assigned"
                                    : "Waiting for acknowledgement...",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          Text("Type: ${data["type"]}"),
                          if (data["description"]!.isNotEmpty)
                            Text("Description: ${data["description"]}"),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),

                    // COOLDOWN TEXT
                    Text(
                      "Next report available in 3 minutes",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    SizedBox(height: 15),

                    // BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

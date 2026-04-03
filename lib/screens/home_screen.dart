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
  void _handleTap() async {
    final type = await _showSelection();
    if (type == null) return;

    final confirmed = await _showConfirmDialog();
    if (confirmed) {
      await _showSignalSent();
      // insert responder ui update here
    }
  }

  void _handleHold() async {
    final confirmed = await _showConfirmDialog();
    if (confirmed) {
      await _showSignalSent();
      // insert responder ui update here
    }
  }

  Future<String?> _showSelection() async {
    return showDialog<String>(
      context: context,
      builder: (_) =>
        SimpleDialog(
          title: Text("Select Emergency Type"),
          children: [
            _option("Fire"),
            _option("Flood"),
            _option("Crime"),
            _option("Others"),
          ],
        ),
    );
  }

  Widget _option(String type) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, type),
      child: Text(type),
    );
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) =>
        AlertDialog(
          title: Text("Are you sure?"),
          content: Text("This will notify responders right away."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes"),
            ),
          ],
        ),
    );
    return result ?? false;
  }

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
//this is for handling the switch of body within homepage from home to myreports vice versa
//Notes: placed here the elements that is both in home and my reports
//       remove lang and lipat sa home or my reports if hindi pang both
//common between home and my reports: appbar, gps, network, safe

//TODO: add functions for updating gps, network, and safe

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override
  State<MainScreen> createState()=> _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0; //default: home

  //for updating functions later; default off
  bool gpsActive = false;
  bool networkActive = false;
  bool isSafe = false;

  // initialize index for 2 pages
  final List<Widget> pages=const [
    HomeScreen(), MyReportsScreen(), //0:home, 1:My reports
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Placeholder(
              fallbackHeight: 20,
              fallbackWidth: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Appliction Name',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: gpsActive ? Colors.green : Colors.grey,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text('GPS active'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: networkActive ? Colors.green : Colors.grey,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text('Network:'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: isSafe ? Colors.green : Colors.grey,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text('safe'),
                  ],
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),

      //bott nav
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    color: selectedIndex == 0 ? Colors.black : Colors.grey,
                    size: 35,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedIndex == 0 ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    color: selectedIndex == 1 ? Colors.black : Colors.grey,
                    size: 35,
                  ),
                  Text(
                    'My Reports',
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedIndex == 1 ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



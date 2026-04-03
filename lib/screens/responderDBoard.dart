import 'package:flutter/material.dart';
import 'package:komhack2026_late_permt/widgets/AlertTile.dart';
import 'package:komhack2026_late_permt/widgets/NumTile.dart';

//just for tests
 void main() {
   runApp(ResponderDBoard());
 }

class ResponderDBoard extends StatefulWidget {
  const ResponderDBoard({super.key});

  @override
  State<ResponderDBoard> createState() => ResponderDBoardState();
}

class ResponderDBoardState extends State<ResponderDBoard> {
  //list goes here, current list is for example, but should be dynamic to the db (kill me)
  List<Map<String, dynamic>> alerts = [
    {
      'type': 'Fire',
      'location': "Brgy. Mat-y, Hollywood St.",
      'whenMade': "2m ago",
      'inProg': false,
    },
    {
      'type': 'Flood',
      'location': "location",
      'whenMade': "3m ago",
      'inProg': false,
    },
    {
      'type': 'Medic',
      'location': "Brgy. Mat-y, Hollywood St.",
      'whenMade': "1h ago",
      'inProg': true,
    },
    {
      'type': 'Other',
      'location': "Brgy. Mat-y, Hollywood St.",
      'whenMade': "1m ago",
      'inProg': true,
    },
    {
      'type': 'Medic',
      'location': "Brgy. Mat-y, Hollywood St.",
      'whenMade': "1h ago",
      'inProg': false,
    },
    {
      'type': 'Medic',
      'location': "Brgy. Mat-y, Hollywood St.",
      'whenMade': "1h ago",
      'inProg': false,
    },
    {
      'type': 'SOS',
      'location': "Brgy. Mat-y, Hollywood St.",
      'whenMade': "1h ago",
      'inProg': false,
    },
    
  ];

  int get numAlerts => alerts.length;
  //will also change depending on number of alert type
  int sosAlerts = 3;
  int fireAlerts = 1;
  int fldAlerts= 8;
  int medAlerts = 7;
  int othAlerts = 6;

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(218, 245, 246, 250),
            elevation: 0,
            shape:  Border(
              bottom: BorderSide(color: Color.fromARGB(255, 130, 130, 130), width: 1),
            ),
            leading: Center( //I FIX THIS THING LATER
              child: Icon(
              Icons.add_alert_sharp,
              size: 50,
              ),
            ),
            leadingWidth: 70, 
            title: Container(
              margin: EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                "APP NAME",
                style: TextStyle(
                  fontFamily: "RobotoFlex",
                  fontSize: 30,
                ),
              ),
            ),
        ),

        body: Column(
          children: [
                    Container( //TODO: incorporate map widget in this area (good luck erine i have no idea how to do this)
                      height: 280,
                      child: const Image(
                          image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7D7qeC0vw3AHdP5dqw-CrVJqjSwf3J-gYWw&s',

                              ),
                          )
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child:
                        Row(
                          children: [
                            NumTile(type: 'SOS', value: '$sosAlerts'),
                            NumTile(type: 'Fire', value: '$fireAlerts'),
                            NumTile(type: 'Flood', value: '$fldAlerts'),
                            NumTile(type: 'Medic', value: '$medAlerts'),
                            NumTile(type: 'Other', value: '$othAlerts'),
                          ],
                        )
                    ),

                    SizedBox(height: 8),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Active Alerts ($numAlerts)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return AlertTile(
                              type: alert['type'],
                              location: alert['location'],
                              whenMade: alert['whenMade'],
                              inProg: alert['inProg'],
                              onBtnPressed: () {
                                //TODO: incorp db somehow to this shit
                                setState(() {
                                  alerts[index]['inProg'] = true;
                                });
                                print('${alert['type']} marked as in progress');
                              },
                            );
                          }
                        )
                    ),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(//TODO: design, add navagation to other pages, and add home page
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Map",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Alert",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_2),
              label: "Teams",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            )
          ]
        )
      ),
    );
  }
}

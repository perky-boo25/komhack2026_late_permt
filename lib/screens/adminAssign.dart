import 'package:flutter/material.dart';

//just for tests
//  void main() {
//    runApp(AdminAssign());
//  }

class AdminAssign extends StatelessWidget{


  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 4, 82, 138),
            title: Container(
              margin: EdgeInsets.only(left: 10, bottom: 5),
              child: Text(
                "ADMIN",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "RobotoFlex",
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  fixedSize: const Size(110, 5),
                  
                ),
                onPressed: (){}, //TODO: add nav to tasks page
                child: Text(
                  "TASKS",
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  ),
                ),
              ),

              const SizedBox(width: 8), //gap

              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  fixedSize: const Size(110, 5),
                ),
                onPressed: (){}, //TODO: add nav to accounts page
                child: Text(
                  "ACCOUNTS",
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              
            ]
        ),
        body: Column(
          children: [
                    Container(
                      height: 280,
                      child: const Image(
                          image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7D7qeC0vw3AHdP5dqw-CrVJqjSwf3J-gYWw&s',
                          
                              ),
                          )
                    ),
                    Expanded(
                      child: ListView.builder(  //allows scrolling for the list while retaining the map in the upper half
                        itemCount: 20, //sample list
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                                    tileColor: Colors.grey[300],
                                    leading: Icon(Icons.fireplace_outlined),
                                      title: Text('Location Name'),
                                      subtitle: Text('lat: 40.7128 long: -74.0060'),
                                      trailing: ElevatedButton(
                                        onPressed: () {},
                                        child: Text('Assign'),
                                      ),
                            ),
                          );
                        },
                      ),
                    
                    ),
          ],
        ),

        bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(255, 4, 82, 138),
          child: Text(" "),
        ),
      ),
    );
  }
}

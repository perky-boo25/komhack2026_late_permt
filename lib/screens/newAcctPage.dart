import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(home: newAcctPage(),
      debugShowCheckedModeBanner: false,),
  );
}

const List<String> list = <String>['Fire', 'Medical', 'Police', 'General'];

class newAcctPage extends StatefulWidget{
  const newAcctPage({super.key});

  @override
  State<newAcctPage> createState() => _newAcctPageState();
}

class _newAcctPageState extends State<newAcctPage>{
  //controllers for user input to code logic
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedDept = list.first;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose(); //when widget is destroy, destroy controllers
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xfff5f6fa),
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton(
          onPressed: () {
            print("Go Back clicked");
            //should lead back to Admin Dashboard
          },
          child: Text(
            "< Back to Dashboard",
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 40, 0, 10),
                child:
                Text(
                  "Register new Responder account",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),

                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 35, left: 20, right: 30),
                child:
                Column(
                    children:[
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Name",
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email",
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),

                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ]
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 35, left: 20, right: 30),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDept,

                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Department",
                  ),

                  items: list.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),

                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDept = newValue!;
                      print("User selected: $newValue");
                    });
                  },
                ),
              ),

              SizedBox(height: 75),
              Center(
                child: Container(
                    height: 50,
                    width: 250,
                    child: Material(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xff0f2339),
                        child: GestureDetector(
                            onTap: (){
                              final responderData = {
                                //add input logic later, im TIRED
                                "name": _nameController.text,
                                "email": _emailController.text,
                                "password": _passwordController.text,
                                "department": _selectedDept,
                                "role": "responder", //automatic ? can admins make new admins?
                                // "status": "active", //sample, handled by DB
                                //"responderID" can be handled by Firebase
                              };
                              print("Sent to DB! Full: $responderData");

                            },
                            child: Center(
                                child: Text(
                                    "REGISTER",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Montserrat",
                                    )
                                )
                            )
                        )
                    )
                ),
              )
            ]
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(//will update this from rine's footer, its nice HAHAHAH
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
    );
  }
}
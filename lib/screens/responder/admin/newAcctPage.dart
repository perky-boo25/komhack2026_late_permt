import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:komhack2026_late_permt/screens/responder/admin/tab_teams_admin.dart'; 


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(
//     MaterialApp(
//       home: newAcctPage(),
//       //debugShowCheckedModeBanner: false,
//     ),
//   );
// }

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
  
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _success = false;
  String? _errorMessage;
  
  set _selectedDept(String _selectedDept) {}

//so responder ids are incremented accordingly
  Future<String> generateNextRspId() async {
  final counterRef = FirebaseFirestore.instance.collection('metadata').doc('responders_id');

  return FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot snapshot = await transaction.get(counterRef);

    if (!snapshot.exists) {
      throw Exception("Document missisng");
    }

    int newCount = snapshot['last_id'] + 1;

    transaction.update(counterRef, {'last_id': newCount});

    return "RSP-${newCount.toString().padLeft(6, '0')
    }";
  });
}


  signUp() async{
    setState(() => _errorMessage = null);

    //clean up
    final name =  _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    String _selectedDept = list.first;
    

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
    setState(() => _errorMessage = 'Please fill in all required fields.');
    return;

    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
    UserCredential userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

    String rID = await generateNextRspId();
    

    await FirebaseFirestore.instance
        .collection('responders')
        .doc(rID) //para same lang sa responder id
        .set({
      "name": name,
      "email": email,
      "department": _selectedDept,
      "role": "responder",
      "status": true, //should dynamically change, idk how to do it tho :skull emoji:
      "responderId": rID,
      "uid": userCredential.user!.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
    

    _success = true;
    } on FirebaseAuthException catch (e) {
    setState(() {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          _errorMessage = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          _errorMessage = 'The password provided is too weak.';
          break;
        default:
          _errorMessage = 'Registration failed. Please try again.';
      }
    });
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
}

  

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose(); //destroy controllers
  }
  

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xfff5f6fa),
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageTab()),
              );
            //should lead back to Admin Dashboard, but i guess it doesnt call the builders because it fucks up the app layout
            //TODO: fix that shit
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
                      //error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      if (_success == true)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            "Account created successfully!",
                            style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),

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
                        obscureText: _obscurePass,
                      
                        decoration: InputDecoration(
                          
                          border: OutlineInputBorder(),

                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey,
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined, // eye icon
                              color: const Color(0xFF9E9E9E),
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass), // toggle eye
                          ),
                        ),
                      ),
                    ]
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 35, left: 20, right: 30),
                child: DropdownButtonFormField<String>(
                  

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
                            child: Center(
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : Text(
                                            "REGISTER",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                  ),

                            onTap: () async {

                              await signUp();
                              print("Sent to DB!");

                            },
                            
                        )
                    )
                ),
              )
            ]
        ),
      ),
    );
  }
}

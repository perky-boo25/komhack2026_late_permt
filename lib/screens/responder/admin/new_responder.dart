import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


const List<String> _deptList = ['Fire', 'Medical', 'Police', 'General'];

class NewAcctPage extends StatefulWidget {
  const NewAcctPage({super.key});

  @override
  State<NewAcctPage> createState() => _NewAcctPageState();
}

class _NewAcctPageState extends State<NewAcctPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedDept = _deptList.first;
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _success = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String> _generateNextRspId() async {
    final counterRef = FirebaseFirestore.instance.collection('metadata').doc('responders_id');
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterRef);
      if (!snapshot.exists) throw Exception("Metadata document missing");

      int newCount = snapshot['last_id'] + 1;
      transaction.update(counterRef, {'last_id': newCount});
      return "RSP-${newCount.toString().padLeft(6, '0')}";
    });
  }

    Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final String? adminUid = FirebaseAuth.instance.currentUser?.uid;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
    });

    FirebaseApp? tempApp; // Temporary secondary app

    try {
      // Initialize the secondary app to prevent Admin logout
      tempApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      // Create the user using the secondary app instance
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      String rID = await _generateNextRspId();

      await FirebaseFirestore.instance.collection('responders').doc(rID).set({
        "name": name,
        "email": email,
        "department": _selectedDept,
        "role": "responder",
        "status": false,
        "responderId": rID,
        "uid": userCredential.user!.uid,
        "createdAt": FieldValue.serverTimestamp(),
        'createdBy': adminUid,       //for admin access
      });

      // Cleanup: Delete the secondary app instance
      await tempApp.delete();

      setState(() {
        _success = true;
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
      });

      if (mounted) {
        bool dialogObscure = true;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text('Account Created', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                //POP UP AFTER ACCT CREATION
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Share these credentials with the responder:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 16),
                    _infoRow(Icons.badge_outlined, 'Responder ID', rID),
                    const SizedBox(height: 10),
                    _infoRow(Icons.person_outline, 'Name', name),
                    const SizedBox(height: 10),
                    _infoRow(Icons.local_hospital_outlined, 'Department', _selectedDept),
                    const SizedBox(height: 10),
                    _infoRow(Icons.email_outlined, 'Email', email),
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.lock_outline,
                      'Password',
                      password,
                      isPassword: true,
                      isObscured: dialogObscure,
                      onToggle: () => setDialogState(() => dialogObscure = !dialogObscure),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Save these details (especially the password) now. — it cannot be retrieved later.',
                              style: TextStyle(fontSize: 11, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0f2339),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (tempApp != null) await tempApp.delete();
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (tempApp != null) await tempApp.delete();
      setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: isPassword && isObscured ? '••••••••' : value,
                ),
              ],
            ),
          ),
        ),
        if (isPassword)
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: const Color.fromARGB(255, 187, 187, 187),
            ),
          ),
      ],
    );
  }


  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: Text(
        "Register new Responder",
        style: TextStyle(
          fontFamily: "Montserrat",
          fontSize: 36,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Montserrat', color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePass,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: "Password",
          suffixIcon: IconButton(
            icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
      ),
    );
  }

  Widget _buildDeptDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDept,
      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Select Department"),
      items: _deptList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
      onChanged: (val) => setState(() => _selectedDept = val!),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: 250,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0f2339),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isLoading ? null : _signUp,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context), // Standard pop back to Manage Page
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.black),
          label: const Text("Back", style: TextStyle(color: Colors.black)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (_errorMessage != null)
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  if (_success)
                    const Text("Account created successfully!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  _buildTextField("Full Name", _nameController),
                  _buildTextField("Email Address", _emailController, isEmail: true),
                  _buildPasswordField(),
                  _buildDeptDropdown(),
                  const SizedBox(height: 50),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
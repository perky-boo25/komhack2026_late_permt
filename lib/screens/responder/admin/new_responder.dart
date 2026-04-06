import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String rID = await _generateNextRspId();

      await FirebaseFirestore.instance.collection('responders').doc(rID).set({
        "name": name,
        "email": email,
        "department": _selectedDept,
        "role": "responder",
        "status": true,
        "responderId": rID,
        "uid": userCredential.user!.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _success = true;
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      value: _selectedDept,
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

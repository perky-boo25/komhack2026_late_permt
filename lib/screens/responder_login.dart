import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:komhack2026_late_permt/screens/responder/admin/tab_teams_admin.dart';

class ResponderLogin extends StatefulWidget {
  const ResponderLogin({super.key});

  @override
  State<ResponderLogin> createState() => _ResponderLoginState();
}

class _ResponderLoginState extends State<ResponderLogin> {
  final TextEditingController _responderId = TextEditingController(); // id input
  final TextEditingController _password = TextEditingController(); // password input

  bool _isLoading = false; // loading state
  bool _obscurePass = true; // hide password
  String? _errorMessage; // error text

  // app colors
  static const _red = Colors.red;
  static final _orange = Colors.orange.shade400;
  static const _black = Colors.black;
  static const _white = Colors.white;

  @override
  void dispose() {
    _responderId.dispose(); // clear id
    _password.dispose(); // clear password
    super.dispose();
  }

  // login flow: FIXED DEAD CODE AND ADJUSTED MESSAGES
 Future<void> _onLoginPressed() async {
  setState(() {
    _errorMessage = null; //clear error message when clicked
  });

  if (_responderId.text.trim().isEmpty || _password.text.trim().isEmpty) {
    setState(() {
      _errorMessage = 'Please fill in all required fields.';
    });
    return;
  }

  setState(() => _isLoading = true);

  try {
    final password = _password.text.trim();
    String rawId = _responderId.text.trim().toUpperCase();
    String digits = rawId.replaceAll(RegExp(r'[^0-9]'), '');
    String paddedDigits = digits.padLeft(6, '0');
    final id = 'RSP-$paddedDigits';

    debugPrint('typed id: $id');

    final doc = await FirebaseFirestore.instance
        .collection('responders')
        .doc(id)
        .get();

    debugPrint('doc exists: ${doc.exists}');
    debugPrint('doc data: ${doc.data()}');

    //is not in responder collection
    if (!doc.exists) {
      setState(() => _errorMessage =
          'Account does not exist. Please contact your supervisor.');
      return;
    }

    final data = doc.data();

    //just to be safe
    if (data == null || !data.containsKey('email')) {
      setState(() => _errorMessage =
          'Account does not exist. Please contact your supervisor.');
      return;
    }

    final email = data['email'] as String;
    final role = data['role'] as String? ?? 'responder';

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (mounted) {
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ManageTab(),
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/responder-dashboard');
      }
    }

  } on FirebaseAuthException catch (e) {
    setState(() {
      switch (e.code) {
        //deleted some error messages as it is redundant/unnecessary
        // case 'wrong-password':
        //   _errorMessage = 'Incorrect password. Please try again.';
        //   break;
        // case 'user-not-found':
        //   _errorMessage = 'No account found for this Responder ID.';
        //   break;
        case 'too-many-requests':
          _errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          _errorMessage = 'Network error. Check your connection.';
          break;
        default:
          _errorMessage = 'Login failed. Please try again.';
      }
    });
  } catch (e) {
    setState(() => _errorMessage = 'An unexpected error occurred.');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // test helpers

  /// Call this in initState or a test button to verify the widget mounts.
  void _testMount() {
    debugPrint('[ResponderLogin] ✅ Widget mounted successfully.'); // mount check
  }

  @override
  void initState() {
    super.initState();
    _testMount(); // dev only
  }

  // page ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white, // white page
      body: SafeArea(
        child: Column(
          children: [

            // top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  // back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _black), // back icon
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context), // go back
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6), // rounded logo
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: Image.asset('images/logo.jpg', fit: BoxFit.cover), // app logo
                    ),
                  ),
                  const SizedBox(width: 8), // small gap
                  const Text(
                    'Application Name', // app name
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _black,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE0E0E0)), // top line

            // main form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28), // side padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height:54 ), // top space

                    // shield badge
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: _white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 20), // gap

                    // page title
                    const Text(
                      'Responder\nLogin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: _black,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 15), // gap

                    // small note
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Use your '), // intro text
                          TextSpan(
                            text: 'pre-issued credentials', // highlighted text
                            style: TextStyle(
                              color: _orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                              text: ' to access the\nresponder dashboard.'), // subtitle end
                        ],
                      ),
                    ),

                    const SizedBox(height: 56), // form gap

                    // id label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _fieldLabel('Responder ID'),
                    ),
                    const SizedBox(height: 6), // label gap
                    _buildTextField(
                      controller: _responderId,
                      hint: 'RSP-XXXXXX',
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                    ),

                    const SizedBox(height: 20), // field gap

                    // password label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _fieldLabel('Password'),
                    ),
                    const SizedBox(height: 6), // label gap
                    _buildTextField(
                      controller: _password,
                      hint: '••••••••',
                      obscureText: _obscurePass,
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

                    // error box
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16), // error gap
                      _ErrorBanner(
                        message: _errorMessage!,
                        onDismiss: () => setState(() => _errorMessage = null), // close error
                      ),
                    ],

                    const SizedBox(height: 28), // button gap

                    // login button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onLoginPressed, // disable while loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _red,
                          disabledBackgroundColor: _red.withOpacity(0.5), // faded red
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // rounded button
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _white,
                                ),
                              ) // loading spinner
                            : const Text(
                                'Log In', // button text
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16), // note gap

                    // contact note
                    Center(
                      child: Text(
                        "Don't have credentials? Contact your supervisor.", // help note
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // dev buttons - for testing lang sa error message hehe
                    /*
                    const SizedBox(height: 32), // dev gap
                    const Divider(color: Color(0xFFE0E0E0)), // divider line
                    const SizedBox(height: 8), // small gap
                    const Text(
                      'Dev Test Buttons — remove before release', // dev label
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBDBDBD),
                      ),
                    ),
                    const SizedBox(height: 8), // small gap
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _testBtn('Wrong ID', _testWrongId), // test wrong id
                        _testBtn('Wrong Password', _testWrongPassword), // test bad password
                        _testBtn('No Account', _testNoAccount), // test no account
                        _testBtn(
                          'Clear Error',
                          () => setState(() => _errorMessage = null), // clear error
                        ),
                      ],
                    ), */
                    const SizedBox(height: 32), // bottom gap
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // field label
  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _black,
          letterSpacing: 0.2,
        ),
      );

  // text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool autocorrect = true,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller, // text controller
      obscureText: obscureText, // hide text
      keyboardType: keyboardType, // keyboard type
      textCapitalization: textCapitalization, // caps style
      autocorrect: autocorrect, // autocorrect toggle
      style: const TextStyle(fontSize: 14, color: _black), // input text style
      decoration: InputDecoration(
        hintText: hint, // hint text
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14), // hint style
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14), // inner padding
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 2.5), // idle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 3.0), // active border
        ),
        suffixIcon: suffixIcon, // trailing icon
        filled: false, // no fill
      ),
    );
  }

  /* UI: For testing purposes only
  Widget _testBtn(String label, VoidCallback onTap) => OutlinedButton(
        onPressed: onTap, // test action
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // button padding
          side: const BorderSide(color: Color(0xFFBDBDBD)), // border line
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // rounded edge
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // compact tap area
        ),
        child: Text(
          label, // button label
          style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
        ),
      );
    */
}

// error banner
class _ErrorBanner extends StatelessWidget {
  final String message; // error text
  final VoidCallback onDismiss; // close action

  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // banner padding
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // soft red
        border: Border.all(color: const Color(0xFFEF9A9A), width: 1.2), // red border
        borderRadius: BorderRadius.circular(8), // rounded box
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // error icon
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFD32F2F),
              size: 18,
            ),
          ),
          const SizedBox(width: 10), // icon gap
          // error message
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB71C1C),
                height: 1.4,
              ),
            ),
          ),
          // close icon
          GestureDetector(
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.only(left: 8, top: 1),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
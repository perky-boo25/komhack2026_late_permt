import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// import screens here (one file per screen)
import 'screens/role_selector.dart';
import 'screens/HomeScreen.dart';
import 'screens/responder_login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //initialization of firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wala pa kita name',
      debugShowCheckedModeBanner: false,

      // starting screen
      home: const RoleSelectionScreen(),

      // routes for navigation
      // use navigator.pushNamed(context, '/route-name');
      routes: {
        // shared
        '/role-select': (context) => const RoleSelectionScreen(),

        // first screen: choose resident or responder

        // ================ R E S I D E N T F L O W =========================
        //you can change/ add if you want guys haha

        // '/location-picker': (context) => const LocationPickerScreen(),
        // detect and confirm location
        '/home': (context) => const MainScreen(),

        // map, reports, emergency button

        // '/signal-sent': (context) => const SignalSentScreen(),
        // after emergency button

        // '/confirm-emergency': (context) => const ConfirmEmergencyScreen(),
        // choose type and send

        // '/my-reports': (context) => const MyReportsScreen(),
        // view reports

        // =============== R E S P O N D E R F L O W =====================
        '/responder-login': (context) => const ResponderLogin(),
        // login screen
        '/responder-dashboard': (context) => const ResponderShell(),
        // map, incidents, tasks

        // =============== A D M I N F L O W =====================
        // '/admin': (context) => const AdminScreen(),
        // manage users and tasks
      },
    );
  }
}

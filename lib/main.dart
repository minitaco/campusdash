import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Activate App Check with Debug Provider
  // This is CRITICAL for testing authentication on an emulator.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    // If you ever test on iOS, you'll need to add the appleProvider here too,
    // but for now, this handles your Android emulator.
  );

  runApp(const CampusDashApp());
}

class CampusDashApp extends StatelessWidget {
  const CampusDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusDash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEEF1F7),
      ),
      home: const LoginScreen(),
    );
  }
}

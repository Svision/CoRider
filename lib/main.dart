import 'package:corider/screens/dashboard.dart';
import 'package:corider/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoRider',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: LoginScreen(),
      routes: {
        "/login": (context) => LoginScreen(),
        "/dashboard": (context) => const NavigationView(),
      },
    );
  }
}

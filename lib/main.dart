import 'package:corider/screens/dashboard.dart';
import 'package:corider/screens/login/login.dart';
import 'package:corider/screens/login/user_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserState(), 
      child: const MyApp(),
    ),
  );
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
      home: const LoginScreen(),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/dashboard": (context) => const NavigationView(),
      },
    );
  }
}

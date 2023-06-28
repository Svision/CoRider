import 'package:corider/screens/dashboard.dart';
import 'package:corider/screens/login/login.dart';
import 'package:corider/providers/user_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cloud_functions/firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  UserState userState = UserState();

  await userState.loadData();

  runApp(
    ChangeNotifierProvider(
      create: (_) => userState,
      child: MyApp(userState: userState),
    ),
  );
}

class MyApp extends StatefulWidget {
  final UserState userState;

  const MyApp({Key? key, required this.userState}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    return MaterialApp(
      title: 'CoRider',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: userState.currentUser == null
          ? LoginScreen(userState: widget.userState)
          : RootNavigationView(userState: widget.userState),
      routes: {
        "/login": (context) => LoginScreen(userState: widget.userState),
        "/dashboard": (context) => RootNavigationView(userState: widget.userState),
      },
    );
  }
}

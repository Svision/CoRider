import 'dart:convert';
import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/screens/dashboard.dart';
import 'package:corider/screens/login/login.dart';
import 'package:corider/models/user_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences sharedUser = await SharedPreferences.getInstance();
  final currentUserString = sharedUser.getString('currentUser');
  final currentOffersString = sharedUser.getString('offers');
  List<RideOfferModel> currentOffers = [];
  UserModel? currentUser;
  if (currentUserString != null) {
    try {
      currentUser = UserModel.fromJson(jsonDecode(currentUserString));
      // fetch user from firebase
      FirebaseFunctions.fetchUserFromFirebase(currentUser.email).then((user) {
        // compare currentUser with user
        if (jsonEncode(currentUser!.toJson()) != jsonEncode(user.toJson())) {
          // print different
          debugPrint(
              'difference: ${jsonEncode(currentUser.toJson())} != ${jsonEncode(user.toJson())}');
          // if different, update currentUser
          UserState(currentUser, currentOffers).setUser(user);
        }
        debugPrint('currentUser: ${currentUser.toJson().toString()}');
      });
      if (currentOffersString != null) {
        try {
          currentOffers = (jsonDecode(currentOffersString) as List<dynamic>)
              .map((e) => RideOfferModel.fromJson(e))
              .toList();
          if (currentOffers.isEmpty) {
            FirebaseFunctions.fetchOffersFromFirebase(currentUser)
                .then((offers) {
              UserState(currentUser, currentOffers).setOffers(offers);
            });
          }
          debugPrint('currentOffer: ${currentOffers.toString()}');
        } catch (e) {
          debugPrint('Error parsing currentOfferString: $e');
        }
      } else {
        // fetch offers from firebase
        FirebaseFunctions.fetchOffersFromFirebase(currentUser).then((offers) {
          UserState(currentUser, currentOffers).setOffers(offers);
        });
      }
    } catch (e) {
      debugPrint('Error parsing currentUserString: $e');
    }
  } else {
    debugPrint('currentUserString is null');
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserState(currentUser, currentOffers),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          ? const LoginScreen()
          : const NavigationView(),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/dashboard": (context) => const NavigationView(),
      },
    );
  }
}

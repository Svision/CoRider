import 'dart:convert';

import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/login/login.dart';
import 'package:corider/screens/ride/exploreRides/explore_rides.dart';
import 'package:corider/screens/home/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'profile/profile_screen.dart';

class RootNavigationView extends StatefulWidget {
  final UserState userState;
  const RootNavigationView({super.key, required this.userState});

  @override
  State<RootNavigationView> createState() => _RootNavigationViewState();
}

class _RootNavigationViewState extends State<RootNavigationView> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      RemoteNotification? notification = message?.notification!;

      debugPrint(notification != null ? notification.title : '');
    });

    FirebaseMessaging.onMessage.listen((message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && (android != null)) {
        String action = jsonEncode(message.data);

        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                priority: Priority.high,
                importance: Importance.max,
                channelShowBadge: true,
                autoCancel: true,
              ),
            ),
            payload: action);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('onMessageOpenedApp: $message');
    });
  }

  void changePageIndex(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.commute),
            icon: Icon(Icons.commute_outlined),
            label: 'Ride',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          alignment: Alignment.center,
          child: HomeScreen(
            userState: userState,
            changePageIndex: changePageIndex,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ExploreRidesScreen(
            userState: userState,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ProfileScreen(),
        ),
      ][currentPageIndex],
    );
  }
}

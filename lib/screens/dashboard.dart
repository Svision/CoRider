import 'package:corider/models/user_model.dart';
import 'package:corider/models/user_state.dart';
import 'package:corider/screens/Ride/find_ride.dart';
import 'package:corider/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile/profile_screen.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int currentPageIndex = 0;

  void changePageIndex(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = Provider.of<UserState>(context).currentUser!;
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
            currentUser: currentUser,
            changePageIndex: changePageIndex,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: const RideOfferScreen(),
        ),
        Container(
          alignment: Alignment.center,
          child: const ProfileScreen(),
        ),
      ][currentPageIndex],
    );
  }
}

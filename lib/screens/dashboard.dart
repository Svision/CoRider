import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/ride/exploreRides/explore_rides.dart';
import 'package:corider/screens/home/home.dart';
import 'package:flutter/material.dart';
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

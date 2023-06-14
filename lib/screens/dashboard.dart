import 'package:corider/models/user_state.dart';
import 'package:corider/screens/Ride/find_ride.dart';
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
  bool showMap = false;

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            showMap = false;
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
          child: const Text('Home'),
        ),
        Container(
          alignment: Alignment.center,
          child: const RideOfferList(),
        ),
        Container(
          alignment: Alignment.center,
          child: ProfileScreen(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/login');
              userState.signOff();
            },
          ),
        ),
      ][currentPageIndex],
    );
  }
}

class ShowMapButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShowMapButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Show Map'),
    );
  }
}

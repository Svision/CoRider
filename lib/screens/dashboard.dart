import 'package:corider/screens/findRide/find_ride.dart';
import 'package:flutter/material.dart';
import 'package:corider/widgets/googleMap.dart';
import 'profile/profile.dart';

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
            label: 'Offer Ride',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Find Ride',
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
          child: showMap ? const MapWidget() : ShowMapButton(
            onPressed: () {
              setState(() {
                showMap = true;
              });
            },
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: RideOfferList(),
        ),
        Container(
          alignment: Alignment.center,
          child: SignOffButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/login');
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
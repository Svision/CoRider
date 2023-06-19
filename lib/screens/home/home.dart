import 'package:corider/models/user_state.dart';
import 'package:corider/screens/home/upcoming_rides.dart';
import 'package:corider/screens/home/my_offers.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changePageIndex;
  UserState userState;
  HomeScreen({Key? key, required this.userState, required this.changePageIndex})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch upcoming rides and my rides data from your data source or API
    // Assign the fetched data to the upcomingRides and myRides lists
    // You can use setState() to update the UI once the data is fetched
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoRider'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              // Perform action when chat button is pressed
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Upcoming Rides',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Expanded(
            child: UpcomingRides(
                userState: widget.userState,
                changePageIndex: widget.changePageIndex),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Ride Offers',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Expanded(child: MyOffers(userState: widget.userState)),
        ],
      ),
    );
  }
}

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/models/user_state.dart';
import 'package:corider/screens/home/upcoming_rides.dart';
import 'package:corider/screens/home/my_offers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changePageIndex;
  final UserModel currentUser;
  const HomeScreen(
      {Key? key, required this.currentUser, required this.changePageIndex})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RideOfferModel> upcomingRides = []; // List of upcoming rides
  List<RideOfferModel> myOffers = []; // List of your rides
  late UserState userState;
  bool isMyOffersFetched = false;

  @override
  void initState() {
    super.initState();
    // Fetch upcoming rides and my rides data from your data source or API
    // Assign the fetched data to the upcomingRides and myRides lists
    // You can use setState() to update the UI once the data is fetched
    FirebaseFunctions.fetchUserOffersbyUser(widget.currentUser).then((offers) {
      setState(() {
        myOffers = offers;
        isMyOffersFetched = true;
      });
    });
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
                rideOffers: upcomingRides,
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
          Expanded(
            child: isMyOffersFetched
                ? MyOffers(myOffers: myOffers)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/Ride/createRideOffer/create_ride_offer_screen.dart';
import 'package:corider/screens/Ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class MyOffers extends StatefulWidget {
  final UserState userState;
  const MyOffers({Key? key, required this.userState}) : super(key: key);

  @override
  MyOffersState createState() => MyOffersState();
}

class MyOffersState extends State<MyOffers> {
  GlobalKey<RefreshIndicatorState> refreshMyOffersIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<RideOfferModel> myOffers = [];
  bool isMyOffersFetched = false;

  void _fetchOffers() {
    FirebaseFunctions.fetchUserOffersbyUser(widget.userState.currentUser!)
        .then((offers) {
      setState(() {
        myOffers = offers;
        isMyOffersFetched = true;
      });
    });
  }

  void triggerRefresh() {
    setState(() {
      isMyOffersFetched = false;
    });
    _fetchOffers();
  }

  Future<void> asyncRefresh() async {
    final offers = await FirebaseFunctions.fetchUserOffersbyUser(
        widget.userState.currentUser!);
    setState(() {
      myOffers = offers;
      isMyOffersFetched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.userState.offers == null || widget.userState.offers!.isEmpty) {
      _fetchOffers();
    } else {
      myOffers = widget.userState.offers!
          .where(
              (offer) => offer.driverId == widget.userState.currentUser!.email)
          .toList();
      isMyOffersFetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isMyOffersFetched) {
      _fetchOffers();
      return const Center(child: CircularProgressIndicator());
    }

    if (myOffers.isEmpty) {
      // Show a message when there are no ride offers
      return Center(
        child: Column(
          children: [
            IconButton(
              onPressed: triggerRefresh,
              icon: const Icon(Icons.refresh, color: Colors.blue),
              iconSize: 32,
            ),
            const Text(
              'No offers created',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const CreateRideOfferScreen()))
                    .then((_) => _fetchOffers());
              },
              child: const Text('Create Ride Offer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
        key: refreshMyOffersIndicatorKey,
        onRefresh: () => asyncRefresh(),
        child: ListView.builder(
          itemCount: myOffers.length,
          itemBuilder: (context, index) {
            final rideOffer = myOffers[index];

            return ListTile(
              title: Text(rideOffer.driverLocationName),
              subtitle: Text(
                  '${rideOffer.proposedDepartureTime!.format(context)} - ${rideOffer.proposedBackTime!.format(context)}'),
              // Customize the tile as needed with other ride offer information
              // For example, add buttons or icons to edit or delete the ride offer
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => RideOfferDetailScreen(
                            rideOffer: rideOffer,
                            refreshOffersKey: refreshMyOffersIndicatorKey,
                          )),
                );
              },
            );
          },
        ));
  }
}

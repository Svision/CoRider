import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/ride/createRideOffer/create_ride_offer_screen.dart';
import 'package:corider/screens/ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class MyOffers extends StatefulWidget {
  final UserState userState;
  final Function() fetchAllOffers;
  const MyOffers({Key? key, required this.userState, required this.fetchAllOffers}) : super(key: key);

  @override
  MyOffersState createState() => MyOffersState();
}

class MyOffersState extends State<MyOffers> {
  GlobalKey<RefreshIndicatorState> refreshMyOffersIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<RideOfferModel> myOffers = [];

  Future<void> fetchMyOffers() async {
    await widget.fetchAllOffers();
  }

  void getMyOffers() {
    final myOffers = widget.userState.storedOffers.entries
        .where((offer) => widget.userState.currentUser!.myOfferIds.contains(offer.key))
        .map((offer) => offer.value)
        .toList();
    setState(() {
      this.myOffers = myOffers;
    });
  }

  @override
  void initState() {
    super.initState();
    getMyOffers();
  }

  @override
  Widget build(BuildContext context) {
    if (myOffers.isEmpty) {
      // Show a message when there are no ride offers
      return Center(
        child: Column(
          children: [
            IconButton(
              onPressed: fetchMyOffers,
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
                    .push(MaterialPageRoute(builder: (context) => const CreateRideOfferScreen()))
                    .then((_) => fetchMyOffers());
              },
              child: const Text('Create Ride Offer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
        key: refreshMyOffersIndicatorKey,
        onRefresh: fetchMyOffers,
        child: ListView.builder(
          itemCount: myOffers.length,
          itemBuilder: (context, index) {
            final rideOffer = myOffers[index];

            return ListTile(
              title: Text(Utils.getShortLocationName(rideOffer.driverLocationName)),
              subtitle: Text(
                  '${rideOffer.proposedLeaveTime!.format(context)} - ${rideOffer.proposedBackTime!.format(context)}'),
              // Customize the tile as needed with other ride offer information
              // For example, add buttons or icons to edit or delete the ride offer
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => RideOfferDetailScreen(
                            userState: widget.userState,
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

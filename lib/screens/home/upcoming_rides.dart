import 'package:corider/models/types/requested_offer_status.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class UpcomingRides extends StatefulWidget {
  final UserState userState;
  final Function() fetchAllOffers;
  final Function(int) changePageIndex;

  const UpcomingRides({Key? key, required this.userState, required this.fetchAllOffers, required this.changePageIndex})
      : super(key: key);

  @override
  UpcomingRidesState createState() => UpcomingRidesState();
}

class UpcomingRidesState extends State<UpcomingRides> {
  GlobalKey<RefreshIndicatorState> refreshMyRequestedOfferIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<RideOfferModel> myRequestedOffers = [];

  Future<void> fetchMyRequestedOffers() async {
    await widget.fetchAllOffers();
  }

  void getMyRequestedOffers() {
    final requestedOffers = widget.userState.storedOffers
        .where((offer) => offer.requestedUserIds.containsKey(widget.userState.currentUser!.email))
        .toList();
    setState(() {
      myRequestedOffers = requestedOffers;
    });
  }

  @override
  void initState() {
    super.initState();
    getMyRequestedOffers();
  }

  @override
  Widget build(BuildContext context) {
    if (myRequestedOffers.isEmpty) {
      // Show a message when there are no upcoming ride offers
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: fetchMyRequestedOffers,
              icon: const Icon(Icons.refresh, color: Colors.blue),
              iconSize: 32,
            ),
            const Text(
              'No upcoming rides',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.changePageIndex(1);
              },
              child: const Text('Explore Rides'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      key: refreshMyRequestedOfferIndicatorKey,
      onRefresh: fetchMyRequestedOffers,
      child: ListView.builder(
        itemCount: myRequestedOffers.length,
        itemBuilder: (context, index) {
          final rideOffer = myRequestedOffers[index];
          final requestedOfferStatus = rideOffer.requestedUserIds[widget.userState.currentUser!.email]!;

          if (requestedOfferStatus == RequestedOfferStatus.INVALID) {
            return ListTile(
              title: const Text('Offer not available'),
              subtitle: const Text('This offer is deleted by the user.'),
              trailing: const Icon(Icons.error, color: Colors.orange),
              onTap: () {
                widget.userState.currentUser!.withdrawRequestRide(widget.userState, rideOffer.id);
              },
            );
          }

          return ListTile(
            title: Text(Utils.getShortLocationName(rideOffer.driverLocationName)),
            subtitle: Text(
                '${rideOffer.proposedDepartureTime!.format(context)} - ${rideOffer.proposedBackTime!.format(context)}'),
            trailing: requestedOfferStatus == RequestedOfferStatus.ACCEPTED
                ? const Icon(Icons.check, color: Colors.green)
                : requestedOfferStatus == RequestedOfferStatus.REJECTED
                    ? const Icon(Icons.close, color: Colors.red)
                    : requestedOfferStatus == RequestedOfferStatus.PENDING
                        ? const Icon(Icons.pending, color: Colors.grey)
                        : const Icon(Icons.error, color: Colors.orange),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => RideOfferDetailScreen(
                          rideOffer: rideOffer,
                          refreshOffersKey: refreshMyRequestedOfferIndicatorKey,
                        )),
              );
            },
          );
        },
      ),
    );
  }
}

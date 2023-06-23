import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/types/requested_offer_status.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class UpcomingRides extends StatefulWidget {
  final UserState userState;
  final Function(int) changePageIndex;

  const UpcomingRides({Key? key, required this.userState, required this.changePageIndex}) : super(key: key);

  @override
  UpcomingRidesState createState() => UpcomingRidesState();
}

class UpcomingRidesState extends State<UpcomingRides> {
  GlobalKey<RefreshIndicatorState> refreshMyRequestedOfferIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Map<RideOfferModel, RequestedOfferStatus> myRequestedOffers = {};
  bool isMyRequestedOffersFetched = false;

  void triggerRefresh() {
    setState(() {
      isMyRequestedOffersFetched = false;
    });
    fetchMyRequestedOffers();
  }

  Future<void> fetchMyRequestedOffers() async {
    final myRequestedOffersStatusMap =
        await FirebaseFunctions.fetchReqeustedOffersStatusByUser(widget.userState.currentUser!);
    debugPrint('myRequestedOffersStatusMap: $myRequestedOffersStatusMap');
    setState(() {
      myRequestedOffers = myRequestedOffersStatusMap.map((key, value) => MapEntry(
          widget.userState.currentOffers!.firstWhere(
            (offer) => offer.id == key,
            orElse: () => RideOfferModel.generateUnknown(),
          ),
          value));
      isMyRequestedOffersFetched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.userState.currentUser!.requestedOfferIds.isEmpty) {
      isMyRequestedOffersFetched = true;
    } else {
      fetchMyRequestedOffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isMyRequestedOffersFetched) {
      fetchMyRequestedOffers();
      return const Center(child: CircularProgressIndicator());
    }
    if (myRequestedOffers.isEmpty) {
      // Show a message when there are no upcoming ride offers
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: triggerRefresh,
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
          final rideOffer = myRequestedOffers.keys.toList()[index];
          final requestedOfferStatus = myRequestedOffers[rideOffer];

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

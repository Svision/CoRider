import 'package:corider/providers/user_state.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class UpcomingRides extends StatefulWidget {
  UserState userState;
  final Function(int) changePageIndex;

  UpcomingRides(
      {Key? key, required this.userState, required this.changePageIndex})
      : super(key: key);

  @override
  _UpcomingRidesState createState() => _UpcomingRidesState();
}

class _UpcomingRidesState extends State<UpcomingRides> {
  List<RideOfferModel> rideOffers = [];
  @override
  Widget build(BuildContext context) {
    if (rideOffers.isEmpty) {
      // Show a message when there are no upcoming ride offers
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    return ListView.builder(
      itemCount: rideOffers.length,
      itemBuilder: (context, index) {
        final rideOffer = rideOffers[index];

        return ListTile(
          title: Text(rideOffer.driverLocationName),
          subtitle: Text(
              rideOffer.proposedDepartureTime?.format(context) ?? 'Unknown'),
          // Customize the tile as needed with other ride offer information
          // For example, add buttons or icons to perform actions on the ride offer
          onTap: () {
            // Handle the tap on the ride offer tile
            // You can navigate to a ride offer details screen or perform any other action
          },
        );
      },
    );
  }
}

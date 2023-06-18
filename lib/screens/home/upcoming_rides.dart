import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class UpcomingRides extends StatelessWidget {
  final List<RideOfferModel> rideOffers;
  final Function(int) changePageIndex;

  const UpcomingRides(
      {Key? key, required this.rideOffers, required this.changePageIndex})
      : super(key: key);

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
              onPressed: () => {changePageIndex(1)},
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
          subtitle:
              Text(rideOffer.proposedStartTime?.format(context) ?? 'Unknown'),
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

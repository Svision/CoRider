import 'package:corider/screens/Ride/offerRide/create_ride_offer_screen.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class MyOffers extends StatelessWidget {
  final List<RideOfferModel> myOffers;

  const MyOffers({Key? key, required this.myOffers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (myOffers.isEmpty) {
      // Show a message when there are no ride offers
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No offers created',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CreateRideOfferScreen()));
              },
              child: const Text('Create Ride Offer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: myOffers.length,
      itemBuilder: (context, index) {
        final rideOffer = myOffers[index];

        return ListTile(
          title: Text(rideOffer.driverLocationName),
          subtitle:
              Text(rideOffer.proposedStartTime?.format(context) ?? 'Unknown'),
          // Customize the tile as needed with other ride offer information
          // For example, add buttons or icons to edit or delete the ride offer
          onTap: () {
            // Handle the tap on the ride offer tile
            // You can navigate to an edit screen or perform any other action
          },
        );
      },
    );
  }
}

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:provider/provider.dart';

class RideOfferDetailPage extends StatelessWidget {
  final RideOfferModel rideOffer;
  final GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey;

  const RideOfferDetailPage(
      {Key? key,
      required this.rideOffer,
      required this.refreshOffersIndicatorKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final UserModel currentUser = userState.currentUser!;
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Offer Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Driver Id: ${rideOffer.driverId}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Ride Offer Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Proposed Departure Time: \n${rideOffer.proposedDepartureTime!.format(context)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Proposed Back Time: \n${rideOffer.proposedBackTime!.format(context)}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Availibility: \n${rideOffer.proposedWeekdays.map((i) => weekdays[i]).join(', ')}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Driver Location Name: \n${rideOffer.driverLocationName}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Driver Location: \n(${rideOffer.driverLocation.latitude}, ${rideOffer.driverLocation.longitude})',
              style: TextStyle(fontSize: 16.0),
            ),
            // Add more details as needed
            SizedBox(height: 32.0),
            currentUser.email != rideOffer.driverId
                ? ElevatedButton(
                    onPressed: () {},
                    child: const Text('Request Ride'),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      await FirebaseFunctions.deleteUserRideOfferByOfferId(
                          currentUser, rideOffer.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ride offer deleted!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      Navigator.of(context).pop();
                      refreshOffersIndicatorKey.currentState?.show();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete Ride'),
                  ),
          ],
        ),
      ),
    );
  }
}

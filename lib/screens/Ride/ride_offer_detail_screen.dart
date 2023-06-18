import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';

class RideOfferDetailPage extends StatelessWidget {
  final RideOfferModel rideOffer;

  const RideOfferDetailPage({Key? key, required this.rideOffer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              'Proposed Start Time: \n${rideOffer.proposedStartTime!.format(context)}',
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
          ],
        ),
      ),
    );
  }
}

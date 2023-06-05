import 'package:flutter/material.dart';

class RideOfferCard extends StatelessWidget {
  final String rideOffer;

  const RideOfferCard({super.key, required this.rideOffer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              // Replace with offer person's avatar
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(
              rideOffer,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Proposed Time: 9:00 AM', // Replace with proposed time
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            height: 200.0,
            color: Colors.grey,
            // Replace with map view for pickup location
            // Map view implementation goes here
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Location:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  '123 Main St, City, State', // Replace with pickup location
                ),
                SizedBox(height: 16.0),
                Text(
                  'Additional Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                ),
                // Add more details as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

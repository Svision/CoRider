import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/screens/Ride/ride_offer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideOfferCard extends StatefulWidget {
  final RideOfferModel rideOffer;

  const RideOfferCard({Key? key, required this.rideOffer}) : super(key: key);

  @override
  _RideOfferCardState createState() => _RideOfferCardState();
}

class _RideOfferCardState extends State<RideOfferCard> {
  Widget _buildListView() {
    return ListTile(
      leading: const CircleAvatar(
        // Replace with offer person's avatar
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(
        widget.rideOffer.driver.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proposed Time: ${widget.rideOffer.proposedStartTime!.format(context)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: _buildProposedWeekdays(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(LatLng driverLocation) {
    return Container(
      height: 200.0,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: driverLocation,
          zoom: 15.0,
        ),
        markers: Set<Marker>.from([
          Marker(
            markerId: MarkerId('driverLocationMarker'),
            position: driverLocation,
          ),
        ]),
        myLocationButtonEnabled: false, // Disable the "Locate Me" button
        mapToolbarEnabled: false, // Disable the map toolbar
        zoomControlsEnabled: false, // Disable the zoom controls
      ),
    );
  }

  List<Widget> _buildProposedWeekdays(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final selectedWeekdays = widget.rideOffer.proposedWeekdays;

    return weekdays.asMap().entries.map((entry) {
      final index = entry.key;
      final weekday = entry.value;
      final isWeekdaySelected = selectedWeekdays.contains(index);

      return Container(
        width: 32.0,
        height: 32.0,
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isWeekdaySelected ? Colors.blue : Colors.transparent,
        ),
        child: Center(
          child: Text(
            weekday,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWeekdaySelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Navigate to ride offer details page
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RideOfferDetailPage(rideOffer: widget.rideOffer)),
          );
        },
        child: Card(
          elevation: 2.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListView(),
              _buildMapView(widget.rideOffer.driverLocation),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Location:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${widget.rideOffer.driverLocationName}\n(${widget.rideOffer.driverLocation.latitude}, ${widget.rideOffer.driverLocation.longitude})',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/Ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RideOfferCard extends StatefulWidget {
  final UserState userState;
  final RideOfferModel rideOffer;
  final GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey;

  const RideOfferCard(
      {Key? key,
      required this.userState,
      required this.rideOffer,
      required this.refreshOffersIndicatorKey})
      : super(key: key);

  @override
  _RideOfferCardState createState() => _RideOfferCardState();
}

class _RideOfferCardState extends State<RideOfferCard> {
  String? driverProfileImageUrl;

  void getUserProfileImageUrl() {
    widget.userState
        .getDriverImageUrlByEmail(widget.rideOffer.driverId)
        .then((profileImageUrl) => {
              if (profileImageUrl != null)
                {
                  setState(() {
                    driverProfileImageUrl = profileImageUrl;
                  })
                }
              else
                {
                  FirebaseFunctions.fetchUserProfileImageByEmail(
                          widget.rideOffer.driverId)
                      .then((profileImageUrl) {
                    setState(() {
                      driverProfileImageUrl = profileImageUrl;
                      if (driverProfileImageUrl != null) {
                        widget.userState.setOfferDriverImageUrlWithEmail(
                            widget.rideOffer.driverId, driverProfileImageUrl!);
                      }
                    });
                  })
                }
            });
  }

  @override
  void initState() {
    super.initState();
    getUserProfileImageUrl();
  }

  Widget _buildListView() {
    return ListTile(
      leading: CircleAvatar(
        maxRadius: 25,
        backgroundColor: driverProfileImageUrl == null ? Colors.grey : null,
        child: driverProfileImageUrl == null
            ? const Icon(
                Icons.person,
                color: Colors.white,
              )
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: driverProfileImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
      ),
      title: Text(
        widget.rideOffer.driverId,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Start: ${widget.rideOffer.proposedDepartureTime!.format(context)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Back: ${widget.rideOffer.proposedBackTime!.format(context)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
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
    return SizedBox(
      height: 200.0,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: driverLocation,
          zoom: 15.0,
        ),
        markers: <Marker>{
          Marker(
            markerId: const MarkerId('driverLocationMarker'),
            position: driverLocation,
          ),
        },
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
                builder: (context) => RideOfferDetailScreen(
                      rideOffer: widget.rideOffer,
                      refreshOffersKey: widget.refreshOffersIndicatorKey,
                    )),
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

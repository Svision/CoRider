import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/profile/user_profile_screen.dart';
import 'package:corider/screens/ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RideOfferCard extends StatefulWidget {
  final UserState userState;
  final RideOfferModel rideOffer;
  final LatLng? currentLocation;
  final GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey;

  const RideOfferCard(
      {Key? key,
      required this.userState,
      required this.rideOffer,
      required this.currentLocation,
      required this.refreshOffersIndicatorKey})
      : super(key: key);

  @override
  State<RideOfferCard> createState() => _RideOfferCardState();
}

class _RideOfferCardState extends State<RideOfferCard> {
  UserModel? driver;

  Future<void> getDriver() async {
    if (widget.rideOffer.driverId == widget.userState.currentUser!.email) {
      setState(() {
        driver = widget.userState.currentUser!;
      });
      return;
    }

    UserModel? fetchedDriver;
    if (widget.userState.storedUsers.containsKey(widget.rideOffer.driverId)) {
      fetchedDriver = widget.userState.storedUsers[widget.rideOffer.driverId];
    } else {
      fetchedDriver = await widget.userState.getStoredUserByEmail(widget.rideOffer.driverId);
    }
    setState(() {
      driver = fetchedDriver;
    });
  }

  @override
  void initState() {
    super.initState();
    // print(widget.currentLocation);
    getDriver();
  }

  Widget _buildListView() {
    return ListTile(
      leading: driver == null
          ? const CircularProgressIndicator()
          : GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                            user: driver!,
                          )),
                );
              },
              child: CircleAvatar(
                maxRadius: 25,
                backgroundColor:
                    driver!.profileImage == null ? Utils.getUserAvatarNameColor(widget.rideOffer.driverId) : null,
                child: driver!.profileImage == null
                    ? Text(
                        '${driver!.firstName[0].toUpperCase()}${driver!.lastName[0].toUpperCase()}',
                        style: const TextStyle(color: Colors.white),
                      )
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: driver!.profileImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
              )),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.rideOffer.driverId == widget.userState.currentUser!.email
                ? 'You'
                : driver == null
                    ? 'Loading...'
                    : driver!.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (widget.currentLocation != null)
            Text(Utils.getDistanceByTwoLocation(widget.currentLocation!, widget.rideOffer.driverLocation),
                style: const TextStyle(color: Colors.grey))
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flight_takeoff,
                    size: 16.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    widget.rideOffer.proposedLeaveTime!.format(context),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8.0),
                  const Icon(
                    Icons.flight_land,
                    size: 16.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    widget.rideOffer.proposedBackTime!.format(context),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                widget.rideOffer.price == 0.0 ? 'Free' : '\$${widget.rideOffer.price}',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false, // Disable the "Locate Me" button
        mapToolbarEnabled: false, // Disable the map toolbar
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
                      userState: widget.userState,
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
                    Text(widget.rideOffer.driverLocationName),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

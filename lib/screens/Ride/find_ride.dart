import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/models/user_state.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:corider/screens/Ride/offerRide/offer_ride_screen.dart';
import 'package:flutter/material.dart';
import 'package:corider/widgets/offer_ride_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class RideOfferList extends StatefulWidget {
  const RideOfferList({Key? key}) : super(key: key);

  @override
  _RideOfferListState createState() => _RideOfferListState();
}

class _RideOfferListState extends State<RideOfferList> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  List<RideOfferModel> offers = [];

  final LatLng _center = const LatLng(43.7720940, -79.3453741);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    for (int i = 0; i < offers.length; i++) {
      LatLng location = offers[i].driverLocation; // Replace with real location
      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: location,
        infoWindow: InfoWindow(title: offers[i].driverId),
      );
      _markers.add(marker);
    }
  }

  void _onMapCreated(GoogleMapController controller) {}

  Future<void> _handleRefresh(UserModel user) async {
    setState(() {
      _isLoading = true;
    });

    offers = await FirebaseFunctions.fetchOffersFromFireBase(user);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final UserModel currentUser = userState.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Offers'),
        leading: IconButton(
          onPressed: () {
            setState(() {
              _selectedIndex = _selectedIndex == 0 ? 1 : 0;
            });
          },
          icon: Icon(
            _selectedIndex == 0 ? Icons.map : Icons.list,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateRideOfferPage()),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
              onRefresh: () => _handleRefresh(currentUser),
              child: offers.isEmpty
                  ? ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return const Center(
                          child: Text('No offers found'),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        return RideOfferCard(rideOffer: offers[index]);
                      },
                    )),
          CustomCustomMapWidget(
            markers: _markers,
            initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    );
  }
}

class CustomCustomMapWidget extends StatefulWidget {
  final Set<Marker> markers;
  final CameraPosition initialCameraPosition;
  final void Function(GoogleMapController) onMapCreated;

  const CustomCustomMapWidget({
    required this.markers,
    required this.initialCameraPosition,
    required this.onMapCreated,
    Key? key,
  }) : super(key: key);

  @override
  _CustomCustomMapWidgetState createState() => _CustomCustomMapWidgetState();
}

class _CustomCustomMapWidgetState extends State<CustomCustomMapWidget> {
  late GoogleMapController mapController;
  late CameraPosition cameraPosition;

  @override
  void initState() {
    super.initState();
    cameraPosition = widget.initialCameraPosition;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      mapType: MapType.normal,
      initialCameraPosition: cameraPosition,
      markers: widget.markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}

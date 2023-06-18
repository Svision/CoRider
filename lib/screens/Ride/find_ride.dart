import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/models/user_state.dart';
import 'package:corider/screens/Ride/offerRide/offer_ride_screen.dart';
import 'package:flutter/material.dart';
import 'package:corider/widgets/offer_ride_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class RideOfferScreen extends StatefulWidget {
  const RideOfferScreen({Key? key}) : super(key: key);

  @override
  _RideOfferScreenState createState() => _RideOfferScreenState();
}

class _RideOfferScreenState extends State<RideOfferScreen> {
  int _selectedIndex = 0;
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
    final userState = Provider.of<UserState>(context, listen: false);

    offers = await FirebaseFunctions.fetchOffersFromFireBase(user);
    userState.setOffers(offers);
    _addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final UserModel currentUser = userState.currentUser!;
    offers = userState.offers;
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
              child: RideOfferList(
                offers: offers,
              )),
          CustomCustomMapWidget(
            markers: _markers,
            initialCameraPosition: CameraPosition(target: _center),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    );
  }
}

class RideOfferList extends StatelessWidget {
  final List<RideOfferModel> offers;

  const RideOfferList({
    required this.offers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return offers.isEmpty
        ? ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No offers found'),
                    Text('Pull down to refresh')
                  ],
                ),
              );
            },
          )
        : ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, index) {
              return RideOfferCard(rideOffer: offers[index]);
            },
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

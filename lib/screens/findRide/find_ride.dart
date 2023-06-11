import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:corider/widgets/offer_ride_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideOfferList extends StatefulWidget {
  const RideOfferList({Key? key}) : super(key: key);

  @override
  _RideOfferListState createState() => _RideOfferListState();
}

class _RideOfferListState extends State<RideOfferList> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  List<RideOfferModel> mockOffers = [
    RideOfferModel(
      driver: UserModel(email: 'abc@abc.com', name: 'John Doe', age: 30),
      vehicle: VehicleModel(make: 'Toyota', model: 'Camry'),
      proposedTime: const TimeOfDay(hour: 9, minute: 0),
      proposedWeekdays: [1, 3, 5],
      driverLocationName: 'Port Royal Park',
      driverLocation: const LatLng(43.7728065 + 0.045, -79.3337945 + 0.045),
      price: 25.0,
      additionalDetails:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    ),
    RideOfferModel(
      driver: UserModel(email: 'abc@abc.com', name: 'Jane Smith', age: 28),
      vehicle: VehicleModel(make: 'Honda', model: 'Civic'),
      proposedTime: const TimeOfDay(hour: 14, minute: 30),
      proposedWeekdays: [2, 4],
      driverLocationName: '3401 Dufferin St, Toronto, ON M6A 2T9',
      driverLocation: const LatLng(43.723821, -79.452058),
      price: 20.0,
      additionalDetails:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    ),
    RideOfferModel(
      driver: UserModel(email: 'abc@abc.com', name: 'Alex Johnson', age: 35),
      vehicle: VehicleModel(make: 'Ford', model: 'Mustang'),
      proposedTime: const TimeOfDay(hour: 11, minute: 15),
      proposedWeekdays: [1, 3, 5],
      driverLocationName: 'Empire State Building',
      driverLocation: const LatLng(43.7728065 - 0.045, -79.3337945 - 0.045),
      price: 30.0,
      additionalDetails:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    ),
    RideOfferModel(
      driver: UserModel(email: 'abc@abc.com', name: 'Emily Wilson', age: 32),
      vehicle: VehicleModel(make: 'Chevrolet', model: 'Silverado'),
      proposedTime: const TimeOfDay(hour: 17, minute: 45),
      proposedWeekdays: [2, 4],
      driverLocationName: 'Brooklyn Bridge',
      driverLocation: const LatLng(43.7728065 - 0.09, -79.3337945 - 0.09),
      price: 22.0,
      additionalDetails:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    ),
    RideOfferModel(
      driver: UserModel(email: 'abc@abc.com', name: 'Michael Brown', age: 29),
      vehicle: VehicleModel(make: 'Tesla', model: 'Model 3'),
      proposedTime: const TimeOfDay(hour: 13, minute: 20),
      proposedWeekdays: [1, 3, 5],
      driverLocationName: '131 McMahon Dr, North York, ON M2K 1C2',
      driverLocation: const LatLng(43.767148, -79.373519),
      price: 35.0,
      additionalDetails:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    ),
  ];

  final LatLng _center = const LatLng(43.7720940, -79.3453741);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    for (int i = 0; i < mockOffers.length; i++) {
      LatLng location =
          mockOffers[i].driverLocation; // Replace with real location
      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: location,
        infoWindow: InfoWindow(title: '${mockOffers[i].driver.name}'),
      );
      _markers.add(marker);
    }
  }

  void _onMapCreated(GoogleMapController controller) {}

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Add refresh logic here
    // This method will be called when the user performs the "drag down to refresh" action
    // You can fetch new data or update the existing data in this method

    // Simulating a delay for demonstration purposes
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Offers'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedIndex = _selectedIndex == 0 ? 1 : 0;
              });
            },
            icon: Icon(
              _selectedIndex == 0 ? Icons.map : Icons.list,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                itemCount: mockOffers.length,
                itemBuilder: (context, index) {
                  return RideOfferCard(rideOffer: mockOffers[index]);
                },
              )
            ),
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
